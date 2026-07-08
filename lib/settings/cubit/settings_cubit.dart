// lib/settings/cubit/settings_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show DollarPricesHistoryData, MaterialPricesHistoryData;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState()) {
    _startWatchingPrices();
    _startWatchingDollarPrice();
  }

  final ErpRepository _erpRepository;
  StreamSubscription<MaterialPricesHistoryData?>? _pricesSubscription;
  StreamSubscription<DollarPricesHistoryData?>? _dollarSubscription;

  void _startWatchingPrices() {
    _pricesSubscription = _erpRepository.watchLatestPrices().listen(
      (prices) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            currentPrices: prices,
          ),
        );
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      ),
    );
  }

  void _startWatchingDollarPrice() {
    _dollarSubscription = _erpRepository.watchLatestDollarPrice().listen(
      (dollarPrice) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            currentDollarPrice: dollarPrice,
          ),
        );
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      ),
    );
  }

  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _erpRepository.pullDataFromCloud();
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          errorMessage: 'تعذر الاتصال بالسحابة (أنت تعمل الآن Offline).',
        ),
      );
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
      await _erpRepository.saveMaterialPrices(
        iron: iron,
        cement: cement,
        block15: block15,
        formwork: formwork,
        aggregates: aggregates,
        worker: worker,
      );

      unawaited(
        _erpRepository.forceSyncWithCloud().catchError((Object e) {
          return '';
        }),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateDollarPrice(double exchangeRate) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _erpRepository.saveDollarPrice(exchangeRate: exchangeRate);

      unawaited(
        _erpRepository.forceSyncWithCloud().catchError((Object e) {
          return '';
        }),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================
  // 🔐 تغيير رمز الأمان الخاص بالمستخدم
  // ==========================================
  Future<void> updateSecurityPin(String newPin) async {
    final userId = _erpRepository.currentUserId;
    if (userId == null) return;

    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _erpRepository.updateUserSecurityPin(userId, newPin);
      emit(state.copyWith(status: SettingsStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'فشل تحديث رمز الأمان: $e',
        ),
      );
    }
  }

  Future<void> fetchPriceHistory() async {
    try {
      final history = await _erpRepository.getAllMaterialPricesHistory();
      final activeHistory = history.where((p) => p.isDeleted == false).toList();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          priceHistory: activeHistory,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: 'تعذر جلب السجل: $e'));
    }
  }

  Future<void> fetchDollarHistory() async {
    try {
      final history = await _erpRepository.getAllDollarPricesHistory();
      final activeHistory = history.where((p) => p.isDeleted == false).toList();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          dollarPriceHistory: activeHistory,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: 'تعذر جلب سجل الدولار: $e'));
    }
  }

  Future<void> deleteHistoricalPrice(String id) async {
    try {
      await _erpRepository.softDeleteMaterialPrice(id);
      await fetchPriceHistory();
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: 'حدث خطأ أثناء الحذف: $e'));
    }
  }

  Future<void> deleteHistoricalDollarPrice(String id) async {
    try {
      await _erpRepository.softDeleteDollarPrice(id);
      await fetchDollarHistory();
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: 'حدث خطأ أثناء الحذف: $e'));
    }
  }

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
      await _erpRepository.saveMaterialPrices(
        iron: iron,
        cement: cement,
        block15: block15,
        formwork: formwork,
        aggregates: aggregates,
        worker: worker,
        effectiveDate: effectiveDate,
      );

      await fetchPriceHistory();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'فشل حفظ التسعيرة: $e',
        ),
      );
    }
  }

  Future<void> addHistoricalDollarPrice({
    required DateTime effectiveDate,
    required double exchangeRate,
  }) async {
    try {
      await _erpRepository.saveDollarPrice(
        exchangeRate: exchangeRate,
        effectiveDate: effectiveDate,
      );

      await fetchDollarHistory();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'فشل حفظ التسعيرة: $e',
        ),
      );
    }
  }

  Future<String> createManualBackup() async =>
      _erpRepository.backupDatabaseManually();

  Future<String> restoreDatabase() async => _erpRepository.restoreDatabase();

  @override
  Future<void> close() {
    _pricesSubscription?.cancel();
    _dollarSubscription?.cancel();
    return super.close();
  }
}
