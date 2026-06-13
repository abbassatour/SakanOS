// packages/erp_repository/lib/src/repositories/payments_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart' hide SecureTime;

class PaymentsRepository {
  const PaymentsRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) =>
      _localApi.getContractLedger(contractId);

  Future<List<PaymentsLedgerData>> getAllPayments() =>
      _localApi.getAllPayments();

  Future<void> addLedgerEntry({
    required String contractId,
    required double amountPaid,
    required double meterPriceAtPayment,
    required double convertedMeters,
    required String pricesSnapshotJson,
    double discountPercentage = 0,
    String? scheduleId,
    DateTime? customDate,
    double? histDollarRate,
    double? histIron,
    double? histCement,
    double? histBlock,
    double? histFormwork,
    double? histAggregates,
    double? histWorker,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final paymentDateToSave = customDate?.toUtc() ?? SecureTime.now();

    // 1. حفظ سعر الدولار التاريخي
    if (customDate != null && histDollarRate != null) {
      try {
        final historicalDollar = DollarPricesHistoryCompanion.insert(
          exchangeRate: histDollarRate,
          effectiveDate: drift.Value(paymentDateToSave),
          userId: userId,
        );
        await _localApi.saveDollarPrice(historicalDollar);
      } on Exception catch (e) {
        // ignore: avoid_print
        print('⚠️ تحذير: فشل حفظ تسعيرة الدولار التاريخية: $e');
      }
    }

    // 2. حفظ أسعار المواد التاريخية
    if (customDate != null && histIron != null) {
      final historicalPrices = MaterialPricesHistoryCompanion.insert(
        effectiveDate: drift.Value(paymentDateToSave),
        ironPrice: histIron,
        cementPrice: histCement!,
        block15Price: histBlock!,
        formworkAndPouringWages: histFormwork!,
        aggregateMaterialsPrice: histAggregates!,
        ordinaryWorkerWage: histWorker!,
        userId: userId,
      );
      await _localApi.savePrices(historicalPrices);
    }

    // 3. إضافة الدفعة إلى دفتر المدفوعات
    final newEntry = PaymentsLedgerCompanion.insert(
      contractId: contractId,
      scheduleId: scheduleId != null
          ? drift.Value(scheduleId)
          : const drift.Value.absent(),
      paymentDate: paymentDateToSave,
      amountPaid: amountPaid,
      meterPriceAtPayment: meterPriceAtPayment,
      convertedMeters: convertedMeters,
      pricesSnapshot: drift.Value(pricesSnapshotJson),
      fees: drift.Value(discountPercentage),
      userId: userId,
    );

    await _localApi.addLedgerEntry(newEntry);

    // 4. معالجة نقطة التفاعل (الرادار) للقسط
    if (scheduleId != null) {
      final currentSchedules = await _localApi.getContractSchedule(contractId);
      final targetScheduleIndex = currentSchedules.indexWhere(
        (s) => s.id == scheduleId,
      );

      if (targetScheduleIndex != -1) {
        final targetSchedule = currentSchedules[targetScheduleIndex];
        final nextDueDate = DateTime.utc(
          targetSchedule.dueDate.year,
          targetSchedule.dueDate.month + 1,
          targetSchedule.dueDate.day,
        );

        await _localApi.handleRollingCheckpoint(
          contractId,
          scheduleId,
          'paid',
          nextDueDate,
          userId,
        );
      }
    }

    await _syncRepo.syncPendingData();
  }

  Future<void> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateLedgerEntryAmount(
      entryId: entryId,
      newAmount: newAmount,
      newDiscount: newDiscount,
      newConvertedMeters: newConvertedMeters,
      userId: userId,
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> softDeleteLedgerEntry(String entryId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.softDeleteLedgerEntry(entryId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() =>
      _localApi.getDeletedLedgerEntries();

  Future<void> restoreLedgerEntry(String entryId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restoreLedgerEntry(entryId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> forceHardDeleteLedgerEntry(String entryId) async {
    await _localApi.forceHardDeleteLedgerEntry(entryId);
  }

  Future<void> markWhatsAppAsSent(String entryId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // 🌟 أضفنا كلمة .database هنا
    await _localApi.database.markWhatsAppAsSent(entryId, userId);

    await _syncRepo.syncPendingData();
  }
}
