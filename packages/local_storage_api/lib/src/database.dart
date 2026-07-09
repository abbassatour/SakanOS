// packages/local_storage_api/lib/src/database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
// استيراد الجداول المفصولة
import 'tables/apartments.dart';
import 'tables/app_roles.dart';
import 'tables/buildings.dart';
import 'tables/clients.dart';
import 'tables/contracts.dart';
import 'tables/dollar_prices_history.dart';
import 'tables/installments_schedule.dart';
import 'tables/legal_action_attachments.dart';
import 'tables/legal_actions.dart';
import 'tables/local_users.dart';
import 'tables/material_prices_history.dart';
import 'tables/payments_ledger.dart';
import 'tables/contract_attachments.dart';
import 'tables/apartment_attachments.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Clients,
    Contracts,
    Buildings,
    Apartments,
    MaterialPricesHistory,
    DollarPricesHistory,
    InstallmentsSchedule,
    PaymentsLedger,
    AppRoles,
    LocalUsers,
    LegalActions,
    LegalActionAttachments,
    ContractAttachments,
    ApartmentAttachments,
  ],
)
class AppDatabase extends _$AppDatabase {
  // 🌟 تعديل هندسي: نسمح بتمرير (QueryExecutor) من الخارج من أجل اختبارات الـ In-Memory
  AppDatabase({QueryExecutor? e}) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================
  // --- استعلامات العملاء ---
  // ==========================================
  Future<List<Client>> getActiveClients() =>
      (select(clients)..where((t) => t.isDeleted.equals(false))).get();

  Future<String> insertClient(ClientsCompanion client) async {
    final row = await into(clients).insertReturning(client);
    return row.id;
  }

  Future<bool> updateClient(Client client) => update(clients).replace(client);

  // ==========================================
  // --- استعلامات الحذف التعاقبي (Cascading Soft Delete) ---
  // ==========================================
  Future<void> softDeleteClient(String clientId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      final clientContracts = await (select(
        contracts,
      )..where((t) => t.clientId.equals(clientId))).get();
      for (final contract in clientContracts) {
        await (update(contracts)..where((t) => t.id.equals(contract.id))).write(
          ContractsCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
        await (update(
          installmentsSchedule,
        )..where((t) => t.contractId.equals(contract.id))).write(
          InstallmentsScheduleCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
        await (update(
          paymentsLedger,
        )..where((t) => t.contractId.equals(contract.id))).write(
          PaymentsLedgerCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  // ==========================================
  // ⚖️ --- استعلامات الإجراءات القانونية ---
  // ==========================================
  Future<List<LegalAction>> getLegalActionsForContract(String contractId) =>
      (select(legalActions)
            ..where(
              (t) =>
                  t.contractId.equals(contractId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.actionDate)]))
          .get();

  Future<String> insertLegalAction(LegalActionsCompanion action) async {
    final row = await into(legalActions).insertReturning(action);
    return row.id;
  }

  Future<int> softDeleteLegalAction(String actionId, String userId) {
    return (update(legalActions)..where((t) => t.id.equals(actionId))).write(
      LegalActionsCompanion(
        isDeleted: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> updateLegalAction(LegalActionsCompanion action) async {
    await (update(
      legalActions,
    )..where((t) => t.id.equals(action.id.value))).write(
      action.copyWith(
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<List<LegalAction>> getAllLegalActions() =>
      (select(legalActions)..where((t) => t.isDeleted.equals(false))).get();

  Future<List<LegalActionAttachment>> getAllLegalActionAttachments() => (select(
    legalActionAttachments,
  )..where((t) => t.isDeleted.equals(false))).get();

  // ==========================================
  // 🎯 تسجيل إجراء إداري على العقد
  // ==========================================
  Future<int> markContractActionTaken(
    String contractId,
    String note,
    String userId,
  ) {
    final nowUtc = DateTime.now().toUtc();
    return (update(contracts)..where((t) => t.id.equals(contractId))).write(
      ContractsCompanion(
        lastActionDate: Value(nowUtc),
        lastActionNote: Value(note),
        userId: Value(userId),
        updatedAt: Value(nowUtc),
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 🎯 تسجيل تسليم الشقة للعميل
  // ==========================================
  Future<void> markContractAsHandedOver(
    String contractId,
    String? apartmentId,
    DateTime actualDate,
    String? notes,
    String userId,
  ) async {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();

      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          isHandedOver: const Value(true),
          actualHandoverDate: Value(actualDate.toUtc()),
          handoverNotes: Value(notes),
          userId: Value(userId),
          updatedAt: Value(nowUtc),
          isSynced: const Value(false),
        ),
      );

      if (apartmentId != null && apartmentId.isNotEmpty) {
        await (update(
          apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            status: const Value('delivered'),
            userId: Value(userId),
            updatedAt: Value(nowUtc),
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  // ==========================================
  // ⏪ التراجع عن تسليم الشقة
  // ==========================================
  Future<void> cancelContractHandover(
    String contractId,
    String? apartmentId,
    String userId,
  ) async {
    return transaction(() async {
      final nowUtc = DateTime.now().toUtc();

      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          isHandedOver: const Value(false),
          actualHandoverDate: const Value(null),
          handoverNotes: const Value(null),
          userId: Value(userId),
          updatedAt: Value(nowUtc),
          isSynced: const Value(false),
        ),
      );

      if (apartmentId != null && apartmentId.isNotEmpty) {
        await (update(
          apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            status: const Value('sold'),
            userId: Value(userId),
            updatedAt: Value(nowUtc),
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  // ==========================================
  // --- إضافة عقد شامل مع المعاملة المالية الموحدة (Atomic Transaction) ---
  // ==========================================
  Future<void> insertFullContractProcess({
    required ContractsCompanion contract,
    required DateTime startDate,
    required String userId,
    required PaymentsLedgerCompanion? downPaymentEntry,
    required String? apartmentId,
  }) async {
    return transaction(() async {
      // 1. إضافة العقد
      final contractRow = await into(contracts).insertReturning(contract);
      final String newContractId = contractRow.id;

      // 2. إضافة القسط الأول فقط
      final dueDate = DateTime.utc(
        startDate.year,
        startDate.month + 1,
        startDate.day,
      );

      final scheduleEntry = InstallmentsScheduleCompanion.insert(
        contractId: newContractId,
        installmentNumber: 1,
        dueDate: dueDate,
        status: const Value('pending'),
        userId: userId,
      );
      await into(installmentsSchedule).insert(scheduleEntry);

      // 3. إضافة الدفعة المقدمة (إن وُجدت)
      if (downPaymentEntry != null) {
        final maxExpr = paymentsLedger.receiptNumber.max();
        final query = selectOnly(paymentsLedger)..addColumns([maxExpr]);
        final result = await query.getSingle();
        final currentMax = result.read(maxExpr) ?? 1000;

        final newPaymentEntry = downPaymentEntry.copyWith(
          contractId: Value(newContractId),
          receiptNumber: Value(currentMax + 1),
        );
        await into(paymentsLedger).insert(newPaymentEntry);
      }

      // 4. تغيير حالة الشقة إلى "مباعة" لكي لا تُباع لشخصين في نفس اللحظة
      if (apartmentId != null && apartmentId.isNotEmpty) {
        await (update(
          apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            status: const Value('sold'),
            userId: Value(userId),
            updatedAt: Value(DateTime.now().toUtc()),
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  // ==========================================
  // 🗑️ الحذف والاستعادة للعقود (Cascading & Atomicity)
  // ==========================================
  Future<void> softDeleteContract(
    String contractId,
    String? apartmentId,
    String userId,
  ) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        installmentsSchedule,
      )..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        paymentsLedger,
      )..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).write(
        LegalActionsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      final actions = await (select(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).get();
      for (final action in actions) {
        await (update(
          legalActionAttachments,
        )..where((t) => t.legalActionId.equals(action.id))).write(
          LegalActionAttachmentsCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );

        // 🌟 الحماية الجديدة: حذف مرفقات العقد آلياً
        await (update(
          contractAttachments,
        )..where((t) => t.contractId.equals(contractId))).write(
          ContractAttachmentsCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }

      // 🌟 الحماية الجديدة: تحرير الشقة لتعود متاحة للبيع
      if (apartmentId != null && apartmentId.isNotEmpty) {
        await (update(
          apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            status: const Value('available'),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> restoreSoftDeletedContract(
    String contractId,
    String? apartmentId,
    bool isHandedOver,
    String userId,
  ) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        installmentsSchedule,
      )..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        paymentsLedger,
      )..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).write(
        LegalActionsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      final actions = await (select(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).get();
      for (final action in actions) {
        await (update(
          legalActionAttachments,
        )..where((t) => t.legalActionId.equals(action.id))).write(
          LegalActionAttachmentsCompanion(
            isDeleted: const Value(false),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }

      // 🌟 الحماية الجديدة: استعادة مرفقات العقد آلياً
      await (update(
        contractAttachments,
      )..where((t) => t.contractId.equals(contractId))).write(
        ContractAttachmentsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      // 🌟 الحماية الجديدة: إعادة حجز الشقة
      if (apartmentId != null && apartmentId.isNotEmpty) {
        final targetStatus = isHandedOver ? 'delivered' : 'sold';
        await (update(
          apartments,
        )..where((t) => t.id.equals(apartmentId))).write(
          ApartmentsCompanion(
            status: Value(targetStatus),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> hardDeleteContract(String contractId) async {
    return transaction(() async {
      // 🌟 حذف المرفقات والإجراءات القانونية
      final actions = await (select(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).get();
      for (final action in actions) {
        await (delete(
          legalActionAttachments,
        )..where((t) => t.legalActionId.equals(action.id))).go();
      }
      await (delete(
        legalActions,
      )..where((t) => t.contractId.equals(contractId))).go();

      // 🌟 حذف المدفوعات والأقساط
      await (delete(
        paymentsLedger,
      )..where((t) => t.contractId.equals(contractId))).go();
      await (delete(
        installmentsSchedule,
      )..where((t) => t.contractId.equals(contractId))).go();

      // 🌟 حذف مرفقات العقد نهائياً (يجب أن يكون هنا قبل العقد)
      await (delete(
        contractAttachments,
      )..where((t) => t.contractId.equals(contractId))).go();

      // 🌟 أخيراً، حذف العقد نفسه
      await (delete(contracts)..where((t) => t.id.equals(contractId))).go();
    });
  }

  Future<List<Contract>> getActiveContracts() =>
      (select(contracts)..where((t) => t.isDeleted.equals(false))).get();

  // ==========================================
  // --- استعلامات دفتر المدفوعات (Ledger) ---
  // ==========================================
  Future<List<PaymentsLedgerData>> getLedgerForContract(String contractId) =>
      (select(paymentsLedger)
            ..where(
              (t) =>
                  t.contractId.equals(contractId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
          .get();

  Future<List<PaymentsLedgerData>> getAllActivePayments() =>
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(false))).get();

  Future<String> insertLedgerEntry(PaymentsLedgerCompanion entry) async {
    return transaction(() async {
      // 🌟 1. استخراج أعلى رقم إيصال موجود حالياً في النظام
      final maxExpr = paymentsLedger.receiptNumber.max();
      final query = selectOnly(paymentsLedger)..addColumns([maxExpr]);
      final result = await query.getSingle();

      // إذا كانت القاعدة فارغة (أو كل الإيصالات القديمة بدون رقم)، سنبدأ من الرقم 1000 (شكل محاسبي احترافي)
      final currentMax = result.read(maxExpr) ?? 1000;

      // 🌟 2. دمج الرقم الجديد مع البيانات القادمة من الواجهة
      final entryWithNumber = entry.copyWith(
        receiptNumber: Value(currentMax + 1),
      );

      // 🌟 3. حفظ الإيصال
      final row = await into(paymentsLedger).insertReturning(entryWithNumber);
      return row.id;
    });
  }

  Future<int> markWhatsAppAsSent(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isWhatsAppSent: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // --- استعلامات سجل أسعار المواد ---
  // ==========================================
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() =>
      (select(
        materialPricesHistory,
      )..where((t) => t.isDeleted.equals(false))).get();

  Future<MaterialPricesHistoryData?> getLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<String> insertMaterialPriceRecord(
    MaterialPricesHistoryCompanion prices,
  ) async {
    final row = await into(materialPricesHistory).insertReturning(prices);
    return row.id;
  }

  // ==========================================
  // --- استعلامات الأقساط (جدول الاستحقاقات) ---
  // ==========================================
  Future<List<InstallmentsScheduleData>> getScheduleForContract(
    String contractId,
  ) =>
      (select(installmentsSchedule)
            ..where(
              (t) =>
                  t.contractId.equals(contractId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .get();

  Future<String> insertCustomSchedule(
    InstallmentsScheduleCompanion entry,
  ) async {
    final row = await into(installmentsSchedule).insertReturning(entry);
    return row.id;
  }

  Future<int> updateScheduleStatus(String id, String status, String userId) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        status: Value(status),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<int> softDeleteScheduleEntry(String id) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() {
    final nowUtc = DateTime.now().toUtc();
    return (select(installmentsSchedule)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.status.equals('pending') &
                t.dueDate.isSmallerThanValue(nowUtc),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  Future<int> updateIndividualSchedule({
    required String scheduleId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount,
    required String userId,
  }) {
    return (update(
      installmentsSchedule,
    )..where((t) => t.id.equals(scheduleId))).write(
      InstallmentsScheduleCompanion(
        dueDate: Value(newDueDate.toUtc()),
        notes: Value(notes),
        expectedAmount: Value(expectedAmount),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
    required String userId,
  }) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      final paidSchedules =
          await (select(installmentsSchedule)..where(
                (t) =>
                    t.contractId.equals(contractId) &
                    t.status.equals('paid') &
                    t.isDeleted.equals(false),
              ))
              .get();

      int lastPaidNumber = 0;
      for (var s in paidSchedules) {
        if (s.installmentNumber > lastPaidNumber) {
          lastPaidNumber = s.installmentNumber;
        }
      }

      await (update(installmentsSchedule)..where(
            (t) =>
                t.contractId.equals(contractId) &
                t.status.equals('pending') &
                t.isDeleted.equals(false) &
                t.expectedAmount.isNull(),
          ))
          .write(
            InstallmentsScheduleCompanion(
              isDeleted: const Value(true),
              updatedAt: nowUtc,
              isSynced: const Value(false),
            ),
          );

      for (int i = 1; i <= newRemainingMonths; i++) {
        final dueDate = DateTime.utc(
          newStartDate.year,
          newStartDate.month + (i - 1),
          newStartDate.day,
        );

        final entry = InstallmentsScheduleCompanion.insert(
          contractId: contractId,
          installmentNumber: lastPaidNumber + i,
          dueDate: dueDate,
          status: const Value('pending'),
          userId: userId,
        );
        await into(installmentsSchedule).insert(entry);
      }

      final int newTotalInstallments = lastPaidNumber + newRemainingMonths;
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          installmentsCount: Value(newTotalInstallments),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
    });
  }

  Stream<MaterialPricesHistoryData?> watchLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  // ==========================================
  // --- 🏢 استعلامات المحاضر (Buildings) ---
  // ==========================================
  Future<List<Building>> getActiveBuildings() =>
      (select(buildings)..where((t) => t.isDeleted.equals(false))).get();

  Future<String> insertBuilding(BuildingsCompanion building) async {
    final row = await into(buildings).insertReturning(building);
    return row.id;
  }

  // ==========================================
  // --- 🚪 استعلامات الشقق (Apartments) ---
  // ==========================================
  Future<List<Apartment>> getAllActiveApartments() =>
      (select(apartments)..where((t) => t.isDeleted.equals(false))).get();

  Future<List<Apartment>> getApartmentsForBuilding(String buildingId) =>
      (select(apartments)..where(
            (t) => t.buildingId.equals(buildingId) & t.isDeleted.equals(false),
          ))
          .get();

  Future<String> insertApartment(ApartmentsCompanion apartment) async {
    final row = await into(apartments).insertReturning(apartment);
    return row.id;
  }

  Future<int> updateApartmentStatus(
    String apartmentId,
    String newStatus,
    String userId,
  ) {
    return (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
      ApartmentsCompanion(
        status: Value(newStatus),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(contractAttachments).go();
      await delete(legalActionAttachments).go();
      await delete(legalActions).go();
      await delete(localUsers).go();
      await delete(appRoles).go();
      await delete(paymentsLedger).go();
      await delete(installmentsSchedule).go();
      await delete(materialPricesHistory).go();
      await delete(dollarPricesHistory).go();
      await delete(contracts).go();
      await delete(apartments).go();
      await delete(buildings).go();
      await delete(clients).go();
      await delete(apartmentAttachments).go(); // 🌟 السطر الجديد
    });
  }
  // ==========================================
  // ☁️ دوال الحقن السحابي المحصنة (Safe Sync Upserts)
  // ==========================================

  Future<void> syncClient(ClientsCompanion entity) => into(clients).insert(
    entity,
    onConflict: DoUpdate(
      (old) => entity,
      target: [clients.id],
      where: (old) => old.isSynced.equals(true), // 🛡️ الحماية هنا
    ),
  );

  Future<void> syncContract(ContractsCompanion entity) =>
      into(contracts).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [contracts.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncMaterialPrice(MaterialPricesHistoryCompanion entity) =>
      into(materialPricesHistory).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [materialPricesHistory.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncSchedule(InstallmentsScheduleCompanion entity) =>
      into(installmentsSchedule).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [installmentsSchedule.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncPayment(PaymentsLedgerCompanion entity) =>
      into(paymentsLedger).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [paymentsLedger.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncBuilding(BuildingsCompanion entity) =>
      into(buildings).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [buildings.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncApartment(ApartmentsCompanion entity) =>
      into(apartments).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [apartments.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncAppRole(AppRolesCompanion entity) => into(appRoles).insert(
    entity,
    onConflict: DoUpdate(
      (old) => entity,
      target: [appRoles.id],
      where: (old) => old.isSynced.equals(true),
    ),
  );

  Future<void> syncLocalUser(LocalUsersCompanion entity) =>
      into(localUsers).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [localUsers.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncDollarPrice(DollarPricesHistoryCompanion entity) =>
      into(dollarPricesHistory).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [dollarPricesHistory.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  // 🌟 دوال المرفقات والإجراءات القانونية (أضفناها هنا لنوحد الحماية)
  Future<void> syncLegalAction(LegalActionsCompanion entity) =>
      into(legalActions).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [legalActions.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );

  Future<void> syncLegalActionAttachment(
    LegalActionAttachmentsCompanion entity,
  ) => into(legalActionAttachments).insert(
    entity,
    onConflict: DoUpdate(
      (old) => entity,
      target: [legalActionAttachments.id],
      where: (old) => old.isSynced.equals(true),
    ),
  );
  // ==========================================
  // 📎 استعلامات مرفقات العقود (Contract Attachments)
  // ==========================================
  Future<List<ContractAttachment>> getAttachmentsForContract(
    String contractId,
  ) =>
      (select(contractAttachments)
            ..where(
              (t) =>
                  t.contractId.equals(contractId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<String> insertContractAttachment(
    ContractAttachmentsCompanion attachment,
  ) async {
    final row = await into(contractAttachments).insertReturning(attachment);
    return row.id;
  }

  Future<int> softDeleteContractAttachment(String attachmentId, String userId) {
    return (update(
      contractAttachments,
    )..where((t) => t.id.equals(attachmentId))).write(
      ContractAttachmentsCompanion(
        isDeleted: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<List<ContractAttachment>> getAllContractAttachments() => (select(
    contractAttachments,
  )..where((t) => t.isDeleted.equals(false))).get();

  // الحقن السحابي لمرفقات العقود
  Future<void> syncContractAttachment(ContractAttachmentsCompanion entity) =>
      into(contractAttachments).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [contractAttachments.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );
  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العملاء
  // ==========================================
  Future<List<Client>> getDeletedClients() =>
      (select(clients)..where((t) => t.isDeleted.equals(true))).get();

  Future<void> restoreSoftDeletedClient(String clientId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
    });
  }

  Future<void> hardDeleteClient(String clientId) async {
    await (delete(clients)..where((t) => t.id.equals(clientId))).go();
  }

  Future<void> autoCleanOldDeletedClients() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(
      const Duration(days: 7),
    );
    await (delete(clients)..where(
          (t) =>
              t.isDeleted.equals(true) &
              t.updatedAt.isSmallerThanValue(sevenDaysAgo),
        ))
        .go();
  }

  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العقود
  // ==========================================
  Future<List<Contract>> getDeletedContracts() =>
      (select(contracts)..where((t) => t.isDeleted.equals(true))).get();

  Future<void> autoCleanOldDeletedContracts() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(
      const Duration(days: 7),
    );
    final oldContracts =
        await (select(contracts)..where(
              (t) =>
                  t.isDeleted.equals(true) &
                  t.updatedAt.isSmallerThanValue(sevenDaysAgo),
            ))
            .get();
    for (var c in oldContracts) {
      await hardDeleteContract(c.id);
    }
  }

  // ==========================================
  // 🗑️ سلة المحذوفات وتعديل المدفوعات (Ledger)
  // ==========================================
  Future<int> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
    required String userId,
  }) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        amountPaid: Value(newAmount),
        fees: Value(newDiscount),
        convertedMeters: Value(newConvertedMeters),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<int> softDeleteLedgerEntry(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() =>
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(true))).get();

  Future<int> restoreLedgerEntry(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(false),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<int> forceHardDeleteLedgerEntry(String entryId) {
    return (delete(paymentsLedger)..where((t) => t.id.equals(entryId))).go();
  }

  Future<void> autoCleanOldDeletedLedgerEntries() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(
      const Duration(days: 7),
    );
    await (delete(paymentsLedger)..where(
          (t) =>
              t.isDeleted.equals(true) &
              t.updatedAt.isSmallerThanValue(sevenDaysAgo),
        ))
        .go();
  }

  // ==========================================
  // 🔄 محرك نقاط التفاعل (Rolling Checkpoints)
  // ==========================================
  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String currentScheduleId,
    required String actionType,
    required DateTime nextDueDate,
    required String userId,
  }) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(
        installmentsSchedule,
      )..where((t) => t.id.equals(currentScheduleId))).write(
        InstallmentsScheduleCompanion(
          status: Value(actionType),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      final currentSchedule = await (select(
        installmentsSchedule,
      )..where((t) => t.id.equals(currentScheduleId))).getSingle();
      final int nextNumber = currentSchedule.installmentNumber + 1;

      final newEntry = InstallmentsScheduleCompanion.insert(
        contractId: contractId,
        installmentNumber: nextNumber,
        dueDate: nextDueDate.toUtc(),
        status: const Value('pending'),
        userId: userId,
      );
      await into(installmentsSchedule).insert(newEntry);

      final contract = await (select(
        contracts,
      )..where((t) => t.id.equals(contractId))).getSingle();
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          installmentsCount: Value(contract.installmentsCount + 1),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
    });
  }

  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - المحاضر والشقق
  // ==========================================
  Future<void> softDeleteBuilding(String buildingId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(buildings)..where((t) => t.id.equals(buildingId))).write(
        BuildingsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      await (update(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).write(
        ApartmentsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      // ... بعد كود الـ apartments:
      final bldApts = await (select(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).get();
      for (final apt in bldApts) {
        await (update(
          apartmentAttachments,
        )..where((t) => t.apartmentId.equals(apt.id))).write(
          ApartmentAttachmentsCompanion(
            isDeleted: const Value(true),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> restoreSoftDeletedBuilding(
    String buildingId,
    String userId,
  ) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(buildings)..where((t) => t.id.equals(buildingId))).write(
        BuildingsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
      await (update(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).write(
        ApartmentsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      // ... بعد كود الـ apartments:
      final bldApts = await (select(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).get();
      for (final apt in bldApts) {
        await (update(
          apartmentAttachments,
        )..where((t) => t.apartmentId.equals(apt.id))).write(
          ApartmentAttachmentsCompanion(
            isDeleted: const Value(false),
            userId: Value(userId),
            updatedAt: nowUtc,
            isSynced: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> softDeleteApartment(String apartmentId, String userId) {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
        ApartmentsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      // 🌟 الحذف المؤقت للمرفقات التابعة للشقة
      await (update(
        apartmentAttachments,
      )..where((t) => t.apartmentId.equals(apartmentId))).write(
        ApartmentAttachmentsCompanion(
          isDeleted: const Value(true),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
    });
  }

  Future<void> restoreSoftDeletedApartment(String apartmentId, String userId) {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      await (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
        ApartmentsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );

      // 🌟 استعادة المرفقات التابعة للشقة
      await (update(
        apartmentAttachments,
      )..where((t) => t.apartmentId.equals(apartmentId))).write(
        ApartmentAttachmentsCompanion(
          isDeleted: const Value(false),
          userId: Value(userId),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        ),
      );
    });
  }

  Future<void> hardDeleteApartment(String apartmentId) {
    return transaction(() async {
      // 🌟 يجب حذف المرفقات نهائياً قبل الشقة (بسبب الربط المرجعي FK)
      await (delete(
        apartmentAttachments,
      )..where((t) => t.apartmentId.equals(apartmentId))).go();
      await (delete(apartments)..where((t) => t.id.equals(apartmentId))).go();
    });
  }

  Future<List<Building>> getDeletedBuildings() =>
      (select(buildings)..where((t) => t.isDeleted.equals(true))).get();

  Future<List<Apartment>> getDeletedApartments() =>
      (select(apartments)..where((t) => t.isDeleted.equals(true))).get();

  Future<void> hardDeleteBuilding(String buildingId) async {
    return transaction(() async {
      // ... قبل حذف الـ apartments:
      final bldApts = await (select(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).get();
      for (final apt in bldApts) {
        await (delete(
          apartmentAttachments,
        )..where((t) => t.apartmentId.equals(apt.id))).go();
      }

      await (delete(
        apartments,
      )..where((t) => t.buildingId.equals(buildingId))).go();
      await (delete(buildings)..where((t) => t.id.equals(buildingId))).go();
    });
  }

  Future<void> autoCleanOldDeletedBuildingsAndApartments() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(
      const Duration(days: 7),
    );

    await (delete(apartments)..where(
          (t) =>
              t.isDeleted.equals(true) &
              t.updatedAt.isSmallerThanValue(sevenDaysAgo),
        ))
        .go();

    await (delete(buildings)..where(
          (t) =>
              t.isDeleted.equals(true) &
              t.updatedAt.isSmallerThanValue(sevenDaysAgo),
        ))
        .go();
  }

  // ==========================================
  // 🛡️ --- استعلامات الصلاحيات والمستخدمين ---
  // ==========================================
  Future<List<AppRole>> getAllRoles() =>
      (select(appRoles)..where((t) => t.isDeleted.equals(false))).get();

  Future<List<LocalUser>> getAllLocalUsers() =>
      (select(localUsers)..where((t) => t.isDeleted.equals(false))).get();

  Future<String> insertRole(AppRolesCompanion role) async {
    final row = await into(appRoles).insertReturning(role);
    return row.id;
  }

  Future<int> updateRolePermissions(String roleId, String newPermissionsJson) {
    return (update(appRoles)..where((t) => t.id.equals(roleId))).write(
      AppRolesCompanion(
        permissionsJson: Value(newPermissionsJson),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<int> updateUserRoleAndPermissions({
    required String userId,
    required String roleId,
    String? extraPermissionsJson,
    String? revokedPermissionsJson,
    bool? isActive,
  }) {
    return (update(localUsers)..where((t) => t.id.equals(userId))).write(
      LocalUsersCompanion(
        roleId: Value(roleId),
        extraPermissionsJson: extraPermissionsJson != null
            ? Value(extraPermissionsJson)
            : const Value.absent(),
        revokedPermissionsJson: revokedPermissionsJson != null
            ? Value(revokedPermissionsJson)
            : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> softDeleteRole(String roleId) async {
    final nowUtc = Value(DateTime.now().toUtc());
    await (update(appRoles)..where((t) => t.id.equals(roleId))).write(
      AppRolesCompanion(
        isDeleted: const Value(true),
        updatedAt: nowUtc,
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 🔐 تحديث رمز الأمان (PIN) للمستخدم
  // ==========================================
  Future<int> updateUserSecurityPin(String userId, String newPin) {
    return (update(localUsers)..where((t) => t.id.equals(userId))).write(
      LocalUsersCompanion(
        securityPin: Value(newPin),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<LocalUser?> getLocalUserById(String id) =>
      (select(localUsers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<AppRole?> getRoleById(String id) =>
      (select(appRoles)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ==========================================
  // 🕒 استعلامات سجل النشاطات (Activity Log)
  // ==========================================
  Future<List<PaymentsLedgerData>> getRecentPayments(int limitCount) =>
      (select(paymentsLedger)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(limitCount))
          .get();

  Future<List<Contract>> getRecentContracts(int limitCount) =>
      (select(contracts)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(limitCount))
          .get();

  Future<List<Client>> getRecentClients(int limitCount) =>
      (select(clients)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(limitCount))
          .get();

  // ==========================================
  // 🔒 إغلاق أو إعادة فتح العقد (Archive / Reopen)
  // ==========================================
  Future<int> toggleContractCompletion(
    String contractId,
    bool isCompleted,
    String userId,
  ) {
    final nowUtc = DateTime.now().toUtc();
    return (update(contracts)..where((t) => t.id.equals(contractId))).write(
      ContractsCompanion(
        isCompleted: Value(isCompleted),
        userId: Value(userId),
        updatedAt: Value(nowUtc),
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 📎 استعلامات مرفقات الإجراءات القانونية
  // ==========================================
  Future<List<LegalActionAttachment>> getAttachmentsForAction(
    String actionId,
  ) =>
      (select(legalActionAttachments)
            ..where(
              (t) =>
                  t.legalActionId.equals(actionId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<String> insertLegalActionAttachment(
    LegalActionAttachmentsCompanion attachment,
  ) async {
    final row = await into(legalActionAttachments).insertReturning(attachment);
    return row.id;
  }

  Future<int> softDeleteLegalActionAttachment(
    String attachmentId,
    String userId,
  ) {
    return (update(
      legalActionAttachments,
    )..where((t) => t.id.equals(attachmentId))).write(
      LegalActionAttachmentsCompanion(
        isDeleted: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 💵 --- استعلامات أسعار الدولار ---
  // ==========================================
  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() => (select(
    dollarPricesHistory,
  )..where((t) => t.isDeleted.equals(false))).get();

  Future<DollarPricesHistoryData?> getLatestDollarPrice() {
    return (select(dollarPricesHistory)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<String> insertDollarPriceRecord(
    DollarPricesHistoryCompanion prices,
  ) async {
    final row = await into(dollarPricesHistory).insertReturning(prices);
    return row.id;
  }

  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() {
    return (select(dollarPricesHistory)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<int> softDeleteDollarPrice(String id) {
    return (update(dollarPricesHistory)..where((t) => t.id.equals(id))).write(
      DollarPricesHistoryCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 📎 استعلامات مرفقات الشقق (Apartment Attachments)
  // ==========================================
  Future<List<ApartmentAttachment>> getAttachmentsForApartment(
    String apartmentId,
  ) =>
      (select(apartmentAttachments)
            ..where(
              (t) =>
                  t.apartmentId.equals(apartmentId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<String> insertApartmentAttachment(
    ApartmentAttachmentsCompanion attachment,
  ) async {
    final row = await into(apartmentAttachments).insertReturning(attachment);
    return row.id;
  }

  Future<int> softDeleteApartmentAttachment(
    String attachmentId,
    String userId,
  ) {
    return (update(
      apartmentAttachments,
    )..where((t) => t.id.equals(attachmentId))).write(
      ApartmentAttachmentsCompanion(
        isDeleted: const Value(true),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  Future<List<ApartmentAttachment>> getAllApartmentAttachments() => (select(
    apartmentAttachments,
  )..where((t) => t.isDeleted.equals(false))).get();

  // الحقن السحابي لمرفقات الشقق
  Future<void> syncApartmentAttachment(ApartmentAttachmentsCompanion entity) =>
      into(apartmentAttachments).insert(
        entity,
        onConflict: DoUpdate(
          (old) => entity,
          target: [apartmentAttachments.id],
          where: (old) => old.isSynced.equals(true),
        ),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(
      p.join(dbFolder.path, 'our_home_erp_v14_legal_system.sqlite'),
    );
    return NativeDatabase.createInBackground(file);
  });
}
