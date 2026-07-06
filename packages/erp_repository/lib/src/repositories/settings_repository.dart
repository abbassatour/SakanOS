// packages/erp_repository/lib/src/repositories/settings_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';
import 'package:uuid/uuid.dart';

import 'sync_repository.dart';

class SettingsRepository {
  const SettingsRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  // ==========================================
  // 🧱 أسعار المواد (Material Prices)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() =>
      _localApi.getLatestPrices();

  Stream<MaterialPricesHistoryData?> watchLatestPrices() =>
      _localApi.watchLatestPrices();

  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() =>
      _localApi.getAllMaterialPricesHistory();

  Future<void> saveMaterialPrices({
    required double iron,
    required double cement,
    required double block15,
    required double formwork,
    required double aggregates,
    required double worker,
    DateTime? effectiveDate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final dateToSave = effectiveDate?.toUtc() ?? DateTime.now().toUtc();

    final newPrices = MaterialPricesHistoryCompanion.insert(
      id: drift.Value(const Uuid().v7()),
      ironPrice: iron,
      cementPrice: cement,
      block15Price: block15,
      formworkAndPouringWages: formwork,
      aggregateMaterialsPrice: aggregates,
      ordinaryWorkerWage: worker,
      effectiveDate: drift.Value(dateToSave),
      userId: userId,
      isDeleted: const drift.Value(false),
      isSynced: const drift.Value(false),
    );

    await _localApi.savePrices(newPrices);
    await _syncRepo.syncPendingData();
  }

  Future<void> softDeleteMaterialPrice(String priceId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(
      db.materialPricesHistory,
    )..where((t) => t.id.equals(priceId))).write(
      MaterialPricesHistoryCompanion(
        isDeleted: const drift.Value(true),
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }

  // ==========================================
  // 💵 أسعار الدولار (Dollar Prices)
  // ==========================================
  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() =>
      _localApi.watchLatestDollarPrice();

  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() =>
      _localApi.getAllDollarPricesHistory();

  Future<void> saveDollarPrice({
    required double exchangeRate,
    DateTime? effectiveDate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final dateToSave = effectiveDate?.toUtc() ?? DateTime.now().toUtc();

    final newDollar = DollarPricesHistoryCompanion.insert(
      id: drift.Value(const Uuid().v7()),
      exchangeRate: exchangeRate,
      effectiveDate: drift.Value(dateToSave),
      userId: userId,
      isDeleted: const drift.Value(false),
      isSynced: const drift.Value(false),
    );

    await _localApi.saveDollarPrice(newDollar);
    await _syncRepo.syncPendingData();
  }

  Future<void> softDeleteDollarPrice(String id) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(
      db.dollarPricesHistory,
    )..where((t) => t.id.equals(id))).write(
      DollarPricesHistoryCompanion(
        isDeleted: const drift.Value(true),
        userId: drift.Value(userId), // توثيق من حذف
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }
}
