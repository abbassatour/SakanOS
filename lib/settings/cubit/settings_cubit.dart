//lib\settings\cubit\settings_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
// 🌟 استيراد كلاسات الدولار من قاعدة البيانات
import 'package:local_storage_api/local_storage_api.dart' show 
    MaterialPricesHistoryCompanion, MaterialPricesHistoryData,
    DollarPricesHistoryCompanion, DollarPricesHistoryData;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState()) {
    _startWatchingPrices(); 
    _startWatchingDollarPrice(); // 🌟 بدء الاستماع للدولار فوراً
  }

  final ErpRepository _erpRepository;
  StreamSubscription<MaterialPricesHistoryData?>? _pricesSubscription;
  StreamSubscription<DollarPricesHistoryData?>? _dollarSubscription; // 🌟 مستمع الدولار

  // ==========================================
  // 📡 الاستماع الحي للبيانات
  // ==========================================
  void _startWatchingPrices() {
    _pricesSubscription = _erpRepository.watchLatestPrices().listen(
      (prices) {
        emit(state.copyWith(status: SettingsStatus.success, currentPrices: prices));
      },
      onError: (error) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: error.toString())),
    );
  }

  // 🌟 مستمع سعر الدولار
  void _startWatchingDollarPrice() {
    _dollarSubscription = _erpRepository.watchLatestDollarPrice().listen(
      (dollarPrice) {
        emit(state.copyWith(status: SettingsStatus.success, currentDollarPrice: dollarPrice));
      },
      onError: (error) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: error.toString())),
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

  // ==========================================
  // 🧱 تحديث أسعار المواد
  // ==========================================
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
        effectiveDate: Value(DateTime.now().toUtc()), // 🌟 تصحيح التوقيت
        userId: userId, 
        isDeleted: const Value(false),
      );
      
      await _erpRepository.savePrices(newPrices);
      _erpRepository.forceSyncWithCloud();

    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 💵 تحديث سعر الدولار
  // ==========================================
  Future<void> updateDollarPrice(double exchangeRate) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول لتحديث الأسعار.');

      final newDollar = DollarPricesHistoryCompanion.insert(
        exchangeRate: exchangeRate,
        effectiveDate: Value(DateTime.now().toUtc()), 
        userId: userId, 
        isDeleted: const Value(false),
      );
      
      await _erpRepository.saveDollarPrice(newDollar);
      _erpRepository.forceSyncWithCloud();

    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 📚 جلب السجلات التاريخية
  // ==========================================
  Future<void> fetchPriceHistory() async {
    try {
      final history = await _erpRepository.getAllMaterialPricesHistory();
      final activeHistory = history.where((p) => p.isDeleted == false).toList();
      
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(priceHistory: activeHistory, userNamesMap: namesMap));
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر جلب السجل: $e"));
    }
  }

  // 🌟 جلب سجل الدولار
  Future<void> fetchDollarHistory() async {
    try {
      final history = await _erpRepository.getAllDollarPricesHistory();
      final activeHistory = history.where((p) => p.isDeleted == false).toList();
      
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(dollarPriceHistory: activeHistory, userNamesMap: namesMap));
    } catch (e) {
      emit(state.copyWith(errorMessage: "تعذر جلب سجل الدولار: $e"));
    }
  }

  // ==========================================
  // 🗑️ حذف التسعيرات (Soft Delete)
  // ==========================================
  Future<void> deleteHistoricalPrice(String id) async {
    try {
      await _erpRepository.softDeleteMaterialPrice(id);
      await fetchPriceHistory();
    } catch (e) {
      emit(state.copyWith(errorMessage: "حدث خطأ أثناء الحذف: $e"));
    }
  }

  // 🌟 حذف دولار
  Future<void> deleteHistoricalDollarPrice(String id) async {
    try {
      await _erpRepository.softDeleteDollarPrice(id);
      await fetchDollarHistory();
    } catch (e) {
      emit(state.copyWith(errorMessage: "حدث خطأ أثناء الحذف: $e"));
    }
  }

  // ==========================================
  // 🕰️ الإضافات التاريخية (بأثر رجعي)
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

      await _erpRepository.savePrices(historicalPrice);
      await fetchPriceHistory();
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: 'فشل حفظ التسعيرة: $e'));
    }
  }

  // 🌟 إضافة دولار بأثر رجعي
  Future<void> addHistoricalDollarPrice({
    required DateTime effectiveDate,
    required double exchangeRate,
  }) async {
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

      final historicalPrice = DollarPricesHistoryCompanion.insert(
        effectiveDate: Value(effectiveDate.toUtc()), 
        exchangeRate: exchangeRate,
        userId: userId,
      );

      await _erpRepository.saveDollarPrice(historicalPrice);
      await fetchDollarHistory();
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: 'فشل حفظ التسعيرة: $e'));
    }
  }

  // ==========================================
  // 🛡️ قسم النسخ الاحتياطي والاستعادة
  // ==========================================
  Future<String> createManualBackup() async => await _erpRepository.backupDatabaseManually();
  Future<String> restoreDatabase() async => await _erpRepository.restoreDatabase();

  @override
  Future<void> close() {
    _pricesSubscription?.cancel();
    _dollarSubscription?.cancel(); // 🌟 إغلاق مستمع الدولار لتجنب تسريب الذاكرة
    return super.close();
  }
}