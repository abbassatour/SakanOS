//lib\settings\cubit\settings_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesHistoryCompanion, MaterialPricesHistoryData;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState()) {
    _startWatchingPrices(); 
  }

  final ErpRepository _erpRepository;
  StreamSubscription<MaterialPricesHistoryData?>? _pricesSubscription;

  void _startWatchingPrices() {
    _pricesSubscription = _erpRepository.watchLatestPrices().listen(
      (prices) {
        emit(state.copyWith(
          status: SettingsStatus.success, 
          currentPrices: prices,
        ));
      },
      onError: (error) {
        emit(state.copyWith(status: SettingsStatus.failure, errorMessage: error.toString()));
      },
    );
  }

  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _erpRepository.pullDataFromCloud();
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.success, 
        errorMessage: "تعذر الاتصال بالسحابة (أنت تعمل الآن Offline).",
      ));
    }
  }

  Future<void> updatePrices({
    required double iron,
    required double cement,
    required double block15,
    required double formwork,
    required double aggregates,
    required double worker,
  }) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول لتحديث الأسعار.');

      final newPrices = MaterialPricesHistoryCompanion.insert(
        ironPrice: iron,
        cementPrice: cement,
        block15Price: block15,
        formworkAndPouringWages: formwork,
        aggregateMaterialsPrice: aggregates,
        ordinaryWorkerWage: worker,
        effectiveDate: Value(DateTime.now()), 
        userId: userId, 
        isDeleted: const Value(false),
      );
      
      await _erpRepository.savePrices(newPrices);
      _erpRepository.forceSyncWithCloud();

    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 جلب السجل التاريخي للأسعار
  Future<void> fetchPriceHistory() async {
    try {
      final history = await _erpRepository.getAllMaterialPricesHistory();
      // نستبعد الأسعار المحذوفة من العرض
      final activeHistory = history.where((p) => p.isDeleted == false).toList();
      
      // 🌟 السحر هنا: جلب المستخدمين وصنع قاموس للأسماء
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
        priceHistory: activeHistory,
        userNamesMap: namesMap, // 🌟 تمرير القاموس للواجهة
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر جلب السجل: $e"));
    }
  }

  /// 🌟 حذف تسعيرة من السجل
  Future<void> deleteHistoricalPrice(String id) async {
    try {
      await _erpRepository.softDeleteMaterialPrice(id);
      // بعد الحذف، نحدث القائمة مرة أخرى ليتحدث الجدول فوراً
      await fetchPriceHistory();
    } catch (e) {
      emit(state.copyWith(errorMessage: "حدث خطأ أثناء الحذف: $e"));
    }
  }


  // ==========================================
  // 🛡️ قسم النسخ الاحتياطي والاستعادة
  // ==========================================
  
  Future<String> createManualBackup() async {
    // نمرر الطلب للـ Repository ونعيد النص للواجهة
    return await _erpRepository.backupDatabaseManually();
  }

  Future<String> restoreDatabase() async {
    // نمرر الطلب للـ Repository ونعيد النص للواجهة
    return await _erpRepository.restoreDatabase();
  }

  @override
  Future<void> close() {
    _pricesSubscription?.cancel();
    return super.close();
  }

  // ==========================================
  // 🕰️ إضافة تسعيرة تاريخية (قديمة) للإحصائيات
  // ==========================================
  Future<void> addHistoricalPrice({
    required DateTime effectiveDate,
    required double iron,
    required double cement,
    required double block15,
    required double formwork,
    required double aggregates,
    required double worker,
  }) async {
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

      final historicalPrice = MaterialPricesHistoryCompanion.insert(
        effectiveDate: Value(effectiveDate.toUtc()), 
        ironPrice: iron,
        cementPrice: cement,
        block15Price: block15,
        formworkAndPouringWages: formwork,
        aggregateMaterialsPrice: aggregates,
        ordinaryWorkerWage: worker,
        userId: userId,
      );

      // حفظ في القاعدة
      await _erpRepository.savePrices(historicalPrice);
      
      // تحديث قائمة السجل لكي تظهر فوراً في الشاشة
      await fetchPriceHistory();

    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: 'فشل حفظ التسعيرة: $e'));
    }
  }
}