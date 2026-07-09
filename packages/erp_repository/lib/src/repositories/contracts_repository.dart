// packages/erp_repository/lib/src/repositories/contracts_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart';

class ContractsRepository {
  const ContractsRepository({
    required LocalStorageApi localApi,
    required CloudStorageClient cloudApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _cloudApi = cloudApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  // ==========================================
  // 🛡️ محرك التقريب والتحصين المالي
  // ==========================================
  double _roundTo10(double val) => (val / 10).round() * 10.0;
  double _roundArea(double val) => double.parse(val.toStringAsFixed(4));
  double _roundConvertedMeters(double val) =>
      double.parse(val.toStringAsFixed(6));
  double _roundPercent(double val) => double.parse(val.toStringAsFixed(2));

  // ==========================================
  // 📄 استعلامات العقود
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<List<Contract>> getDeletedContracts() =>
      _localApi.getDeletedContracts();

  Future<List<Contract>> getContractsForClient(String clientId) async {
    final allContracts = await getAllContracts();
    return allContracts
        .where((c) => c.clientId == clientId && c.isDeleted != true)
        .toList();
  }

  // ==========================================
  // ➕ إضافة عقد (العملية المعقدة)
  // ==========================================
  Future<void> addContract({
    required String clientId,
    required String contractType,
    required String details,
    required String? apartmentId,
    required double area,
    required double basePrice,
    required double downPayment,
    required int installmentsCount,
    required String guarantorName,
    required double agreedMonthlyAmount,
    Map<String, double> coefficients = const {},
    DateTime? customDate,
    DateTime? agreedHandoverDate,
    int? gracePeriodMonths,
    bool isPenaltyActive = false,
    double penaltyPercentage = 0.0,
    int penaltyIntervalMonths = 1,
    double? histIron,
    double? histCement,
    double? histBlock,
    double? histFormwork,
    double? histAggregates,
    double? histWorker,
    double? histDollarRate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final contractDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

    // 1. حفظ سعر الدولار التاريخي
    if (customDate != null && histDollarRate != null) {
      try {
        final historicalDollar = DollarPricesHistoryCompanion.insert(
          exchangeRate: histDollarRate,
          effectiveDate: drift.Value(contractDateToSave),
          userId: userId,
        );
        await _localApi.saveDollarPrice(historicalDollar);
      } on Exception catch (e) {
        print('⚠️ تحذير: فشل حفظ تسعيرة الدولار التاريخية: $e');
      }
    }

    // 2. حفظ أسعار المواد التاريخية
    if (customDate != null && histIron != null) {
      final historicalPrices = MaterialPricesHistoryCompanion.insert(
        effectiveDate: drift.Value(contractDateToSave),
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

    // 3. التقريب
    final safeArea = _roundArea(area);
    final safeBasePriceForContract = _roundTo10(basePrice);
    final safeDownPaymentForContract = _roundTo10(downPayment);
    final safeMonthlyAmount = _roundTo10(agreedMonthlyAmount);
    final safePenaltyPct = _roundPercent(penaltyPercentage);

    // 4. إنشاء العقد
    final newContract = ContractsCompanion.insert(
      clientId: clientId,
      apartmentId: drift.Value(apartmentId),
      contractType: drift.Value(contractType),
      apartmentDetails: drift.Value(details),
      totalArea: safeArea,
      baseMeterPriceAtSigning: safeBasePriceForContract,
      downPayment: drift.Value(safeDownPaymentForContract),
      agreedHandoverDate: agreedHandoverDate != null
          ? drift.Value(agreedHandoverDate.toUtc())
          : const drift.Value.absent(),
      gracePeriodMonths: drift.Value(gracePeriodMonths ?? 0),
      isPenaltyActive: drift.Value(isPenaltyActive),
      penaltyPercentage: drift.Value(safePenaltyPct),
      penaltyIntervalMonths: drift.Value(penaltyIntervalMonths),
      installmentsCount: drift.Value(installmentsCount),
      agreedMonthlyAmount: drift.Value(safeMonthlyAmount),
      coefficients: drift.Value(jsonEncode(coefficients)),
      contractDate: contractDateToSave,
      guarantorName: guarantorName,
      userId: userId,
    );

    // 5. تجهيز الدفعة الأولى (إن وُجدت)
    PaymentsLedgerCompanion? downPaymentEntry;
    if (downPayment > 0) {
      final rawConverted = basePrice > 0 ? (downPayment / basePrice) : 0;
      final snapshotData = <String, dynamic>{
        'note': 'الدفعة الأولى عند توقيع العقد',
      };

      if (histDollarRate != null)
        snapshotData['dollar_rate_used'] = histDollarRate;

      if (customDate != null && histIron != null) {
        snapshotData['iron'] = histIron;
        snapshotData['cement'] = histCement;
        snapshotData['block'] = histBlock;
        snapshotData['formwork'] = histFormwork;
        snapshotData['aggregates'] = histAggregates;
        snapshotData['worker'] = histWorker;
      } else {
        final currentPrices = await _localApi.getLatestPrices();
        if (currentPrices != null) {
          snapshotData['iron'] = currentPrices.ironPrice;
          snapshotData['cement'] = currentPrices.cementPrice;
          snapshotData['block'] = currentPrices.block15Price;
          snapshotData['formwork'] = currentPrices.formworkAndPouringWages;
          snapshotData['aggregates'] = currentPrices.aggregateMaterialsPrice;
          snapshotData['worker'] = currentPrices.ordinaryWorkerWage;
        }
      }

      downPaymentEntry = PaymentsLedgerCompanion.insert(
        contractId: 'TEMP', // سيتم استبدالها آلياً داخل قاعدة البيانات
        paymentDate: contractDateToSave,
        amountPaid: downPayment,
        meterPriceAtPayment: basePrice,
        convertedMeters: _roundConvertedMeters(rawConverted.toDouble()),
        pricesSnapshot: drift.Value(jsonEncode(snapshotData)),
        userId: userId,
      );
    }

    // ==========================================
    // 🛡️ التنفيذ الذري (Atomic Transaction)
    // ==========================================
    await _localApi.database.insertFullContractProcess(
      contract: newContract,
      startDate: contractDateToSave,
      userId: userId,
      downPaymentEntry: downPaymentEntry,
      apartmentId: apartmentId,
    );

    await _syncRepo.syncPendingData();
  }

  // ==========================================
  // 📝 تعديل العقد
  // ==========================================
  Future<void> updateContract({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
    required double agreedMonthlyAmount,
    required DateTime contractDate,
    required bool isPenaltyActive,
    required double penaltyPercentage,
    required int penaltyIntervalMonths,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final safeMonthlyAmount = _roundTo10(agreedMonthlyAmount);
    final safePenaltyPct = _roundPercent(penaltyPercentage);

    final db = _localApi.database;
    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        apartmentDetails: drift.Value(details),
        guarantorName: drift.Value(guarantorName),
        installmentsCount: drift.Value(installmentsCount),
        agreedMonthlyAmount: drift.Value(safeMonthlyAmount),
        contractDate: drift.Value(contractDate.toUtc()),
        isPenaltyActive: drift.Value(isPenaltyActive),
        penaltyPercentage: drift.Value(safePenaltyPct),
        penaltyIntervalMonths: drift.Value(penaltyIntervalMonths),
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );

    await (db.update(db.installmentsSchedule)
          ..where((t) => t.contractId.equals(id))
          ..where(
            (t) => t.installmentNumber.isBiggerThanValue(installmentsCount),
          )
          ..where((t) => t.status.equals('pending')))
        .write(
          const InstallmentsScheduleCompanion(
            isDeleted: drift.Value(true),
            isSynced: drift.Value(false),
          ),
        );

    await _syncRepo.syncPendingData();
  }

  // ==========================================
  // 🗑️ الحذف والاستعادة والتسليم
  // ==========================================
  Future<void> deleteContract(String contractId, String? apartmentId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // السطر السحري: عملية واحدة محمية 100%
    await _localApi.deleteContract(contractId, apartmentId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> restoreContract(
    String contractId,
    String? apartmentId,
    bool isHandedOver,
  ) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // السطر السحري: عملية واحدة محمية 100%
    await _localApi.restoreContract(
      contractId,
      apartmentId,
      isHandedOver,
      userId,
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> forceHardDeleteContract(String contractId) async {
    await _localApi.hardDeleteContractLocal(contractId);
  }

  Future<void> markContractAsHandedOver({
    required String contractId,
    required String? apartmentId,
    required DateTime actualHandoverDate,
    String? notes,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.markContractAsHandedOver(
      contractId,
      apartmentId,
      actualHandoverDate,
      notes,
      userId,
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> cancelContractHandover({
    required String contractId,
    required String? apartmentId,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.cancelContractHandover(contractId, apartmentId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> toggleContractCompletion({
    required String contractId,
    required bool isCompleted,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.toggleContractCompletion(contractId, isCompleted, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> attachContractFile(
    String contractId,
    File file,
    String extension,
  ) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // 1. إنشاء مجلد محلي آمن داخل مجلد التطبيق
    final dir = await getApplicationSupportDirectory();
    final localDirPath = p.join(dir.path, 'pending_uploads');
    final localDir = Directory(localDirPath);
    if (!await localDir.exists()) await localDir.create(recursive: true);

    // 2. نسخ الملف المختار إلى هذا المجلد المحلي
    final fileName = 'contract_$contractId.$extension';
    final localFile = await file.copy(p.join(localDir.path, fileName));

    // 3. حفظ المسار المحلي في قاعدة البيانات بدلاً من الرابط السحابي
    final db = _localApi.database;
    await (db.update(
      db.contracts,
    )..where((t) => t.id.equals(contractId))).write(
      ContractsCompanion(
        contractFileUrl: drift.Value(
          localFile.path,
        ), // 🌟 حفظ المسار المحلي هنا
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), // 🌟 تأشير كـ "غير متزامن"
      ),
    );

    // 4. محاولة المزامنة (إذا كان هناك إنترنت سيرفع فوراً، وإلا سينتظر)
    await _syncRepo.syncPendingData();
  }

  Future<void> markContractActionTaken({
    required String contractId,
    required String note,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.markContractActionTaken(contractId, note, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restructureContractSchedule(
      contractId: contractId,
      newRemainingMonths: newRemainingMonths,
      newStartDate: newStartDate.toUtc(),
      userId: userId,
    );
    await _syncRepo.syncPendingData();
  }

  // ==========================================
  // 📅 تعديل تاريخ العقد فقط
  // ==========================================
  Future<void> updateContractDateOnly({
    required String id,
    required DateTime contractDate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        contractDate: drift.Value(contractDate.toUtc()),
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }
}
