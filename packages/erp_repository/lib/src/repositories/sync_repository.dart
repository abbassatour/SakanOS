// packages/erp_repository/lib/src/repositories/sync_repository.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncRepository {
  SyncRepository({
    required LocalStorageApi localApi,
    required CloudStorageClient cloudApi,
  }) : _localApi = localApi,
       _cloudApi = cloudApi;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  bool _isSyncing = false;

  String? get currentUserId => _cloudApi.currentUserId;

  Future<String> forceSyncWithCloud() async {
    try {
      await syncPendingData();
      await pullDataFromCloud();
      return 'تمت المزامنة مع السحابة بنجاح! ☁️✓';
    } on Exception catch (e) {
      return 'حدث خطأ أثناء المزامنة: $e';
    }
  }

  Future<void> pullDataFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString('last_pull_timestamp');
      DateTime? lastSyncTime;

      final existingClients = await _localApi.getClients();
      final isDatabaseEmpty = existingClients.isEmpty;

      if (lastSyncStr != null && !isDatabaseEmpty) {
        lastSyncTime = DateTime.parse(lastSyncStr).toUtc();
      }

      // ==========================================
      // 🌟 الحل السحري: تتبع أحدث توقيت قادم من السيرفر
      // ==========================================
      DateTime? latestServerTimestamp;

      void trackLatestTime(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return;
        final date = DateTime.tryParse(dateStr)?.toUtc();
        if (date != null) {
          if (latestServerTimestamp == null ||
              date.isAfter(latestServerTimestamp!)) {
            latestServerTimestamp = date;
          }
        }
      }

      // 0. سحب أسعار الدولار
      final cloudDollarPrices = await _cloudApi.getDollarPrices(
        lastSync: lastSyncTime,
      );
      for (final d in cloudDollarPrices) {
        trackLatestTime(d['updated_at']?.toString());
        await _localApi.syncDollarPrice(_mapCloudToDollarPrice(d));
      }

      // 1. سحب العملاء
      final cloudClients = await _cloudApi.getClients(lastSync: lastSyncTime);
      for (final c in cloudClients) {
        trackLatestTime(c['updated_at']?.toString());
        final client = ClientsCompanion.insert(
          id: drift.Value(c['id'].toString()),
          name: c['name'].toString(),
          phone: c['phone'].toString(),
          nationalId: drift.Value(c['national_id']?.toString()),
          userId: c['user_id']?.toString() ?? '',
          isDeleted: drift.Value(c['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(c['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncClient(client);
      }

      // 2. سحب العقود
      final cloudContracts = await _cloudApi.getContracts(
        lastSync: lastSyncTime,
      );
      for (final c in cloudContracts) {
        trackLatestTime(c['updated_at']?.toString());
        final contract = ContractsCompanion.insert(
          id: drift.Value(c['id'].toString()),
          clientId: c['client_id'].toString(),
          apartmentId: drift.Value(c['apartment_id']?.toString()),
          contractType: drift.Value(
            c['contract_type']?.toString() ?? 'لاحق التخصص',
          ),
          apartmentDetails: drift.Value(
            c['apartment_details']?.toString() ?? '',
          ),
          totalArea: double.tryParse(c['total_area']?.toString() ?? '0') ?? 0.0,
          baseMeterPriceAtSigning:
              double.tryParse(
                c['base_meter_price_at_signing']?.toString() ?? '0',
              ) ??
              0.0,
          downPayment: drift.Value(
            double.tryParse(c['down_payment']?.toString() ?? '0') ?? 0.0,
          ),
          isPenaltyActive: drift.Value(c['is_penalty_active'] == true),
          penaltyPercentage: drift.Value(
            double.tryParse(c['penalty_percentage']?.toString() ?? '0') ?? 0.0,
          ),
          penaltyIntervalMonths: drift.Value(
            int.tryParse(c['penalty_interval_months']?.toString() ?? '1') ?? 1,
          ),
          isHandedOver: drift.Value(c['is_handed_over'] == true),
          agreedHandoverDate: drift.Value(
            c['agreed_handover_date'] != null
                ? DateTime.tryParse(
                    c['agreed_handover_date'].toString(),
                  )?.toUtc()
                : null,
          ),
          actualHandoverDate: drift.Value(
            c['actual_handover_date'] != null
                ? DateTime.tryParse(
                    c['actual_handover_date'].toString(),
                  )?.toUtc()
                : null,
          ),
          gracePeriodMonths: drift.Value(
            int.tryParse(c['grace_period_months']?.toString() ?? '0') ?? 0,
          ),
          handoverNotes: drift.Value(c['handover_notes']?.toString()),
          installmentsCount: drift.Value(
            int.tryParse(c['installments_count']?.toString() ?? '48') ?? 48,
          ),
          agreedMonthlyAmount: drift.Value(
            double.tryParse(c['agreed_monthly_amount']?.toString() ?? '0') ??
                0.0,
          ),
          coefficients: drift.Value(c['coefficients']?.toString() ?? '{}'),
          contractDate:
              DateTime.tryParse(
                c['contract_date']?.toString() ?? '',
              )?.toUtc() ??
              DateTime.now().toUtc(),
          guarantorName: c['guarantor_name']?.toString() ?? 'بدون كفيل',
          contractFileUrl: drift.Value(c['contract_file_url']?.toString()),
          userId: c['user_id']?.toString() ?? '',
          lastActionDate: drift.Value(
            c['last_action_date'] != null
                ? DateTime.tryParse(c['last_action_date'].toString())?.toUtc()
                : null,
          ),
          lastActionNote: drift.Value(c['last_action_note']?.toString()),
          isCompleted: drift.Value(c['is_completed'] == true),
          isDeleted: drift.Value(c['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(c['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncContract(contract);
      }

      // 3. سحب أسعار المواد
      final cloudPrices = await _cloudApi.getMaterialPrices();
      for (final p in cloudPrices) {
        trackLatestTime(p['updated_at']?.toString());
        final price = MaterialPricesHistoryCompanion.insert(
          id: drift.Value(p['id'].toString()),
          ironPrice: double.tryParse(p['iron_price']?.toString() ?? '0') ?? 0.0,
          cementPrice:
              double.tryParse(p['cement_price']?.toString() ?? '0') ?? 0.0,
          block15Price:
              double.tryParse(p['block15_price']?.toString() ?? '0') ?? 0.0,
          formworkAndPouringWages:
              double.tryParse(
                p['formwork_and_pouring_wages']?.toString() ?? '0',
              ) ??
              0.0,
          aggregateMaterialsPrice:
              double.tryParse(
                p['aggregate_materials_price']?.toString() ?? '0',
              ) ??
              0.0,
          ordinaryWorkerWage:
              double.tryParse(p['ordinary_worker_wage']?.toString() ?? '0') ??
              0.0,
          effectiveDate: drift.Value(
            DateTime.tryParse(p['effective_date']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          userId: p['user_id']?.toString() ?? '',
          isDeleted: drift.Value(p['is_deleted'] == true),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncPrice(price);
      }

      // 4. سحب جدول الاستحقاقات
      final cloudSchedules = await _cloudApi.getSchedules(
        lastSync: lastSyncTime,
      );
      for (final s in cloudSchedules) {
        trackLatestTime(s['updated_at']?.toString());
        final schedule = InstallmentsScheduleCompanion.insert(
          id: drift.Value(s['id'].toString()),
          contractId: s['contract_id'].toString(),
          installmentNumber:
              int.tryParse(s['installment_number']?.toString() ?? '1') ?? 1,
          dueDate:
              DateTime.tryParse(s['due_date']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
          status: drift.Value(s['status']?.toString() ?? 'pending'),
          notes: drift.Value(s['notes']?.toString()),
          expectedAmount: drift.Value(
            s['expected_amount'] != null
                ? double.tryParse(s['expected_amount'].toString())
                : null,
          ),
          userId: s['user_id']?.toString() ?? '',
          isDeleted: drift.Value(s['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(s['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncSchedule(schedule);
      }

      // 5. سحب الأقساط (الدفعات)
      final cloudPayments = await _cloudApi.getPayments(lastSync: lastSyncTime);
      for (final p in cloudPayments) {
        trackLatestTime(p['updated_at']?.toString());
        final payment = PaymentsLedgerCompanion.insert(
          id: drift.Value(p['id'].toString()),
          contractId: p['contract_id'].toString(),
          scheduleId: drift.Value(p['schedule_id']?.toString()),
          receiptNumber: drift.Value(
            p['receipt_number'] != null
                ? int.tryParse(p['receipt_number'].toString())
                : null,
          ),
          paymentDate:
              DateTime.tryParse(p['payment_date']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
          amountPaid:
              double.tryParse(p['amount_paid']?.toString() ?? '0') ?? 0.0,
          meterPriceAtPayment:
              double.tryParse(p['meter_price_at_payment']?.toString() ?? '0') ??
              0.0,
          convertedMeters:
              double.tryParse(p['converted_meters']?.toString() ?? '0') ?? 0.0,
          pricesSnapshot: drift.Value(p['prices_snapshot']?.toString() ?? '{}'),
          fees: drift.Value(
            double.tryParse(p['fees']?.toString() ?? '0') ?? 0.0,
          ),
          isWhatsAppSent: drift.Value(p['is_whatsapp_sent'] == true),
          userId: p['user_id']?.toString() ?? '',
          isDeleted: drift.Value(p['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncPayment(payment);
      }

      // 6. سحب المحاضر
      final cloudBuildings = await _cloudApi.getBuildings();
      for (final b in cloudBuildings) {
        trackLatestTime(b['updated_at']?.toString());
        final building = BuildingsCompanion.insert(
          id: drift.Value(b['id'].toString()),
          name: b['name'].toString(),
          location: drift.Value(b['location']?.toString()),
          floorCoefficients: drift.Value(
            b['floor_coefficients']?.toString() ?? '{}',
          ),
          directionCoefficients: drift.Value(
            b['direction_coefficients']?.toString() ?? '{}',
          ),
          userId: drift.Value(b['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(b['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(b['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncBuilding(building);
      }

      // 7. سحب الشقق
      final cloudApartments = await _cloudApi.getApartments();
      for (final a in cloudApartments) {
        trackLatestTime(a['updated_at']?.toString());
        final apartment = ApartmentsCompanion.insert(
          id: drift.Value(a['id'].toString()),
          buildingId: a['building_id'].toString(),
          unitType: drift.Value(a['unit_type']?.toString() ?? 'apartment'),
          apartmentNumber: a['apartment_number'].toString(),
          area: double.tryParse(a['area']?.toString() ?? '0') ?? 0.0,
          floorName: a['floor_name'].toString(),
          directionName: a['direction_name']?.toString() ?? '-',
          customCoefficients: drift.Value(
            a['custom_coefficients']?.toString() ?? '{}',
          ),
          status: drift.Value(a['status']?.toString() ?? 'available'),
          userId: drift.Value(a['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(a['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(a['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncApartment(apartment);
      }

      // 8. سحب قوالب الأدوار
      final cloudRoles = await _cloudApi.getAppRoles(lastSync: lastSyncTime);
      for (final r in cloudRoles) {
        trackLatestTime(r['updated_at']?.toString());
        final role = AppRolesCompanion.insert(
          id: drift.Value(r['id'].toString()),
          name: r['name'].toString(),
          permissionsJson: drift.Value(r['permissions']?.toString() ?? '[]'),
          isSystemRole: drift.Value(r['is_system_role'] == true),
          isDeleted: drift.Value(r['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(r['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncAppRole(role);
      }

      // 9. سحب المستخدمين
      final cloudUsers = await _cloudApi.getAppUsers(lastSync: lastSyncTime);
      for (final u in cloudUsers) {
        trackLatestTime(u['updated_at']?.toString());
        final user = LocalUsersCompanion.insert(
          id: u['id'].toString(),
          email: u['email']?.toString() ?? '',
          fullName: drift.Value(u['full_name']?.toString()),
          roleId: drift.Value(u['role_id']?.toString()),

          // 🌟 السطر الجديد: جلب الـ PIN من السحابة
          securityPin: drift.Value(u['security_pin']?.toString() ?? '0000'),

          extraPermissionsJson: drift.Value(
            u['extra_permissions']?.toString() ?? '[]',
          ),
          revokedPermissionsJson: drift.Value(
            u['revoked_permissions']?.toString() ?? '[]',
          ),
          isActive: drift.Value(u['is_active'] != false),
          updatedAt: drift.Value(
            DateTime.tryParse(u['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncLocalUser(user);
      }

      // 10. سحب الإجراءات القانونية
      final cloudLegalActions = await _cloudApi.getLegalActions(
        lastSync: lastSyncTime,
      );
      for (final a in cloudLegalActions) {
        trackLatestTime(a['updated_at']?.toString());
        final action = LegalActionsCompanion.insert(
          id: drift.Value(a['id'].toString()),
          contractId: a['contract_id'].toString(),
          actionType: a['action_type'].toString(),
          actionDate: DateTime.parse(a['action_date'].toString()).toUtc(),
          notes: drift.Value(a['notes']?.toString()),
          userId: a['user_id']?.toString() ?? '',
          isDeleted: drift.Value(a['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(a['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.database.syncLegalAction(action);
      }

      // 11. سحب المرفقات القانونية
      final cloudAttachments = await _cloudApi.getLegalActionAttachments(
        lastSync: lastSyncTime,
      );
      for (final att in cloudAttachments) {
        trackLatestTime(att['updated_at']?.toString());
        final attachment = LegalActionAttachmentsCompanion.insert(
          id: drift.Value(att['id'].toString()),
          legalActionId: att['legal_action_id'].toString(),
          fileUrl: att['file_url'].toString(),
          fileName: drift.Value(att['file_name']?.toString()),
          fileType: drift.Value(att['file_type']?.toString()),
          userId: att['user_id']?.toString() ?? '',
          isDeleted: drift.Value(att['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(att['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.database.syncLegalActionAttachment(attachment);
      }

      // 12. سحب المرفقات الخاصة بالعقود
      final cloudContractAttachments = await _cloudApi.getContractAttachments(
        lastSync: lastSyncTime,
      );
      for (final att in cloudContractAttachments) {
        trackLatestTime(att['updated_at']?.toString());
        final attachment = ContractAttachmentsCompanion.insert(
          id: drift.Value(att['id'].toString()),
          contractId: att['contract_id'].toString(),
          fileUrl: att['file_url'].toString(),
          fileName: drift.Value(att['file_name']?.toString()),
          fileType: drift.Value(att['file_type']?.toString()),
          userId: att['user_id']?.toString() ?? '',
          isDeleted: drift.Value(att['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(att['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.database.syncContractAttachment(attachment);
      }

      // 13. سحب المرفقات الخاصة بالشقق
      final cloudApartmentAttachments = await _cloudApi.getApartmentAttachments(
        lastSync: lastSyncTime,
      );
      for (final att in cloudApartmentAttachments) {
        trackLatestTime(att['updated_at']?.toString());
        final attachment = ApartmentAttachmentsCompanion.insert(
          id: drift.Value(att['id'].toString()),
          apartmentId: att['apartment_id'].toString(),
          fileUrl: att['file_url'].toString(),
          fileName: drift.Value(att['file_name']?.toString()),
          fileType: drift.Value(att['file_type']?.toString()),
          userId: att['user_id']?.toString() ?? '',
          isDeleted: drift.Value(att['is_deleted'] == true),
          updatedAt: drift.Value(
            DateTime.tryParse(att['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
          ),
          isSynced: const drift.Value(true),
        );
        await _localApi.database.syncApartmentAttachment(attachment);
      }

      // ==========================================
      // 🌟 حفظ أحدث توقيت سيرفر للمزامنة القادمة (إن وُجد)
      // ==========================================
      if (latestServerTimestamp != null) {
        await prefs.setString(
          'last_pull_timestamp',
          latestServerTimestamp!.toIso8601String(),
        );
      }
    } on Exception catch (e) {
      // ignore: avoid_print
      print('❌ Cloud Pull Failed: $e');
    }
  }

  Future<void> syncPendingData() async {
    if (_isSyncing || currentUserId == null) return;
    _isSyncing = true;

    bool hasErrors = false;
    final db = _localApi.database;

    double safeNum(double? val) {
      if (val == null) return 0.0;
      if (val.isInfinite || val.isNaN) return 0.0;
      return val;
    }

    // 1. مزامنة العملاء
    try {
      final pendingClients = await (db.select(
        db.clients,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final c in pendingClients) {
        await _cloudApi.upsertClient({
          'id': c.id,
          'name': c.name,
          'phone': c.phone,
          'national_id': c.nationalId,
          'user_id': c.userId,
          'is_deleted': c.isDeleted,
          'updated_at': c.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.clients)..where((t) => t.id.equals(c.id))).write(
          const ClientsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Clients Failed: $e');
      hasErrors = true;
    }

    // 2. مزامنة العقود
    try {
      final pendingContracts = await (db.select(
        db.contracts,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final c in pendingContracts) {
        await _cloudApi.upsertContract({
          'id': c.id,
          'client_id': c.clientId,
          'apartment_id': c.apartmentId,
          'contract_type': c.contractType,
          'apartment_details': c.apartmentDetails,
          'total_area': safeNum(c.totalArea),
          'base_meter_price_at_signing': safeNum(c.baseMeterPriceAtSigning),
          'down_payment': safeNum(c.downPayment),
          'is_penalty_active': c.isPenaltyActive,
          'penalty_percentage': safeNum(c.penaltyPercentage),
          'penalty_interval_months': c.penaltyIntervalMonths,
          'is_handed_over': c.isHandedOver,
          'agreed_handover_date': c.agreedHandoverDate
              ?.toUtc()
              .toIso8601String(),
          'actual_handover_date': c.actualHandoverDate
              ?.toUtc()
              .toIso8601String(),
          'grace_period_months': c.gracePeriodMonths,
          'handover_notes': c.handoverNotes,
          'installments_count': c.installmentsCount,
          'agreed_monthly_amount': safeNum(c.agreedMonthlyAmount),
          'coefficients': c.coefficients,
          'contract_date': c.contractDate.toUtc().toIso8601String(),
          'guarantor_name': c.guarantorName,
          'contract_file_url': c.contractFileUrl,
          'user_id': c.userId,
          'is_completed': c.isCompleted,
          'last_action_date': c.lastActionDate?.toUtc().toIso8601String(),
          'last_action_note': c.lastActionNote,
          'is_deleted': c.isDeleted,
          'updated_at': c.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.contracts)..where((t) => t.id.equals(c.id))).write(
          const ContractsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Contracts Failed: $e');
      hasErrors = true;
    }

    // 3. مزامنة جدول الاستحقاقات
    try {
      final pendingSchedules = await (db.select(
        db.installmentsSchedule,
      )..where((t) => t.isSynced.equals(false))).get();
      if (pendingSchedules.isNotEmpty) {
        final cloudSchedules = pendingSchedules
            .map(
              (s) => {
                'id': s.id,
                'contract_id': s.contractId,
                'installment_number': s.installmentNumber,
                'due_date': s.dueDate.toUtc().toIso8601String(),
                'status': s.status,
                'notes': s.notes,
                'expected_amount': s.expectedAmount,
                'user_id': s.userId,
                'is_deleted': s.isDeleted,
                'updated_at': s.updatedAt.toUtc().toIso8601String(),
              },
            )
            .toList();

        await _cloudApi.upsertSchedule(cloudSchedules);

        for (final s in pendingSchedules) {
          await (db.update(
            db.installmentsSchedule,
          )..where((t) => t.id.equals(s.id))).write(
            const InstallmentsScheduleCompanion(isSynced: drift.Value(true)),
          );
        }
      }
    } on Exception catch (e) {
      print('Sync Schedules Failed: $e');
      hasErrors = true;
    }

    // 4. مزامنة الدفعات
    try {
      final pendingPayments = await (db.select(
        db.paymentsLedger,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final p in pendingPayments) {
        await _cloudApi.upsertPayment({
          'id': p.id,
          'contract_id': p.contractId,
          'schedule_id': p.scheduleId,
          'receipt_number': p.receiptNumber,
          'payment_date': p.paymentDate.toUtc().toIso8601String(),
          'amount_paid': safeNum(p.amountPaid),
          'meter_price_at_payment': safeNum(p.meterPriceAtPayment),
          'converted_meters': safeNum(p.convertedMeters),
          'prices_snapshot': p.pricesSnapshot,
          'fees': safeNum(p.fees),
          'is_whatsapp_sent': p.isWhatsAppSent,
          'user_id': p.userId,
          'is_deleted': p.isDeleted,
          'updated_at': p.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.paymentsLedger)..where((t) => t.id.equals(p.id)))
            .write(const PaymentsLedgerCompanion(isSynced: drift.Value(true)));
      }
    } on Exception catch (e) {
      print('Sync Payments Failed: $e');
      hasErrors = true;
    }

    // 5. مزامنة أسعار المواد
    try {
      final pendingPrices = await (db.select(
        db.materialPricesHistory,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final p in pendingPrices) {
        await _cloudApi.upsertMaterialPrices({
          'id': p.id,
          'effective_date': p.effectiveDate.toUtc().toIso8601String(),
          'iron_price': safeNum(p.ironPrice),
          'cement_price': safeNum(p.cementPrice),
          'block15_price': safeNum(p.block15Price),
          'formwork_and_pouring_wages': safeNum(p.formworkAndPouringWages),
          'aggregate_materials_price': safeNum(p.aggregateMaterialsPrice),
          'ordinary_worker_wage': safeNum(p.ordinaryWorkerWage),
          'user_id': p.userId,
          'is_deleted': p.isDeleted,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        await (db.update(
          db.materialPricesHistory,
        )..where((t) => t.id.equals(p.id))).write(
          const MaterialPricesHistoryCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Prices Failed: $e');
      hasErrors = true;
    }

    // 6. مزامنة المحاضر
    try {
      final pendingBuildings = await (db.select(
        db.buildings,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final b in pendingBuildings) {
        await _cloudApi.upsertBuilding({
          'id': b.id,
          'name': b.name,
          'location': b.location,
          'floor_coefficients': b.floorCoefficients,
          'direction_coefficients': b.directionCoefficients,
          'user_id': b.userId,
          'is_deleted': b.isDeleted,
          'updated_at': b.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.buildings)..where((t) => t.id.equals(b.id))).write(
          const BuildingsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Buildings Failed: $e');
      hasErrors = true;
    }

    // 7. مزامنة الشقق
    try {
      final pendingApartments = await (db.select(
        db.apartments,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final a in pendingApartments) {
        await _cloudApi.upsertApartment({
          'id': a.id,
          'building_id': a.buildingId,
          'unit_type': a.unitType,
          'apartment_number': a.apartmentNumber,
          'area': safeNum(a.area),
          'floor_name': a.floorName,
          'direction_name': a.directionName,
          'custom_coefficients': a.customCoefficients,
          'status': a.status,
          'user_id': a.userId,
          'is_deleted': a.isDeleted,
          'updated_at': a.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.apartments)..where((t) => t.id.equals(a.id))).write(
          const ApartmentsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Apartments Failed: $e');
      hasErrors = true;
    }

    // 8. مزامنة قوالب الأدوار
    try {
      final pendingRoles = await (db.select(
        db.appRoles,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final r in pendingRoles) {
        await _cloudApi.upsertAppRole({
          'id': r.id,
          'name': r.name,
          'permissions': r.permissionsJson,
          'is_system_role': r.isSystemRole,
          'is_deleted': r.isDeleted,
          'updated_at': r.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.appRoles)..where((t) => t.id.equals(r.id))).write(
          const AppRolesCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Roles Failed: $e');
      hasErrors = true;
    }

    // 9. مزامنة المستخدمين
    try {
      final pendingUsers = await (db.select(
        db.localUsers,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final u in pendingUsers) {
        await _cloudApi.upsertAppUser({
          'id': u.id,
          'full_name': u.fullName,
          'email': u.email,
          'role_id': u.roleId,
          'security_pin': u.securityPin,
          'extra_permissions': u.extraPermissionsJson,
          'revoked_permissions': u.revokedPermissionsJson,
          'is_active': u.isActive,
          'updated_at': u.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.localUsers)..where((t) => t.id.equals(u.id))).write(
          const LocalUsersCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Users Failed: $e');
      hasErrors = true;
    }

    // 10. مزامنة الإجراءات القانونية
    try {
      final pendingActions = await (db.select(
        db.legalActions,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final a in pendingActions) {
        await _cloudApi.upsertLegalAction({
          'id': a.id,
          'contract_id': a.contractId,
          'action_type': a.actionType,
          'action_date': a.actionDate.toUtc().toIso8601String(),
          'notes': a.notes,
          'user_id': a.userId,
          'is_deleted': a.isDeleted,
          'updated_at': a.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(db.legalActions)..where((t) => t.id.equals(a.id)))
            .write(const LegalActionsCompanion(isSynced: drift.Value(true)));
      }
    } on Exception catch (e) {
      print('Sync Legal Actions Failed: $e');
      hasErrors = true;
    }

    // 11. مزامنة المرفقات القانونية
    try {
      final pendingAttachments = await (db.select(
        db.legalActionAttachments,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final att in pendingAttachments) {
        String finalFileUrl = att.fileUrl;

        if (!finalFileUrl.startsWith('http')) {
          try {
            final localFile = File(finalFileUrl);
            if (await localFile.exists()) {
              final extension = att.fileType ?? 'pdf';
              finalFileUrl = await _cloudApi.uploadLegalAttachmentFile(
                attachmentId: att.id,
                file: localFile,
                extension: extension,
              );
              await (db.update(
                db.legalActionAttachments,
              )..where((t) => t.id.equals(att.id))).write(
                LegalActionAttachmentsCompanion(
                  fileUrl: drift.Value(finalFileUrl),
                ),
              );
              await localFile.delete();
            } else {
              await (db.delete(
                db.legalActionAttachments,
              )..where((t) => t.id.equals(att.id))).go();
              continue;
            }
          } catch (e) {
            print('⚠️ فشل رفع المرفق: $e');
            hasErrors = true;
            continue;
          }
        }

        await _cloudApi.upsertLegalActionAttachment({
          'id': att.id,
          'legal_action_id': att.legalActionId,
          'file_url': finalFileUrl,
          'file_name': att.fileName,
          'file_type': att.fileType,
          'user_id': att.userId,
          'is_deleted': att.isDeleted,
          'updated_at': att.updatedAt.toUtc().toIso8601String(),
        });
        await (db.update(
          db.legalActionAttachments,
        )..where((t) => t.id.equals(att.id))).write(
          const LegalActionAttachmentsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Legal Attachments Failed: $e');
      hasErrors = true;
    }

    // 12. مزامنة أسعار الدولار
    try {
      final pendingDollars = await (db.select(
        db.dollarPricesHistory,
      )..where((t) => t.isSynced.equals(false))).get();
      for (final d in pendingDollars) {
        await _cloudApi.upsertDollarPrice(_mapDollarPriceToCloud(d));
        await (db.update(
          db.dollarPricesHistory,
        )..where((t) => t.id.equals(d.id))).write(
          const DollarPricesHistoryCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Dollar Prices Failed: $e');
      hasErrors = true;
    }

    // 13. مزامنة المرفقات الخاصة بالعقود
    try {
      final pendingContractAttachments = await (db.select(
        db.contractAttachments,
      )..where((t) => t.isSynced.equals(false))).get();

      for (final att in pendingContractAttachments) {
        String finalFileUrl = att.fileUrl;

        if (!finalFileUrl.startsWith('http')) {
          try {
            final localFile = File(finalFileUrl);
            if (await localFile.exists()) {
              final extension = att.fileType ?? 'pdf';
              finalFileUrl = await _cloudApi.uploadContractAttachmentFile(
                attachmentId: att.id,
                file: localFile,
                extension: extension,
              );
              await (db.update(
                db.contractAttachments,
              )..where((t) => t.id.equals(att.id))).write(
                ContractAttachmentsCompanion(
                  fileUrl: drift.Value(finalFileUrl),
                ),
              );
              await localFile.delete();
            } else {
              await (db.delete(
                db.contractAttachments,
              )..where((t) => t.id.equals(att.id))).go();
              continue;
            }
          } catch (e) {
            print('⚠️ فشل رفع مرفق العقد: $e');
            hasErrors = true;
            continue;
          }
        }

        await _cloudApi.upsertContractAttachment({
          'id': att.id,
          'contract_id': att.contractId,
          'file_url': finalFileUrl,
          'file_name': att.fileName,
          'file_type': att.fileType,
          'user_id': att.userId,
          'is_deleted': att.isDeleted,
          'updated_at': att.updatedAt.toUtc().toIso8601String(),
        });

        await (db.update(
          db.contractAttachments,
        )..where((t) => t.id.equals(att.id))).write(
          const ContractAttachmentsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Contract Attachments Failed: $e');
      hasErrors = true;
    }

    // 14. مزامنة المرفقات الخاصة بالشقق
    try {
      final pendingApartmentAttachments = await (db.select(
        db.apartmentAttachments,
      )..where((t) => t.isSynced.equals(false))).get();

      for (final att in pendingApartmentAttachments) {
        String finalFileUrl = att.fileUrl;

        if (!finalFileUrl.startsWith('http')) {
          try {
            final localFile = File(finalFileUrl);
            if (await localFile.exists()) {
              final extension = att.fileType ?? 'pdf';
              finalFileUrl = await _cloudApi.uploadApartmentAttachmentFile(
                attachmentId: att.id,
                file: localFile,
                extension: extension,
              );
              await (db.update(
                db.apartmentAttachments,
              )..where((t) => t.id.equals(att.id))).write(
                ApartmentAttachmentsCompanion(
                  fileUrl: drift.Value(finalFileUrl),
                ),
              );
              await localFile.delete();
            } else {
              await (db.delete(
                db.apartmentAttachments,
              )..where((t) => t.id.equals(att.id))).go();
              continue;
            }
          } catch (e) {
            print('⚠️ فشل رفع مرفق الشقة: $e');
            hasErrors = true;
            continue;
          }
        }

        await _cloudApi.upsertApartmentAttachment({
          'id': att.id,
          'apartment_id': att.apartmentId,
          'file_url': finalFileUrl,
          'file_name': att.fileName,
          'file_type': att.fileType,
          'user_id': att.userId,
          'is_deleted': att.isDeleted,
          'updated_at': att.updatedAt.toUtc().toIso8601String(),
        });

        await (db.update(
          db.apartmentAttachments,
        )..where((t) => t.id.equals(att.id))).write(
          const ApartmentAttachmentsCompanion(isSynced: drift.Value(true)),
        );
      }
    } on Exception catch (e) {
      print('Sync Apartment Attachments Failed: $e');
      hasErrors = true;
    }

    _isSyncing = false;

    if (hasErrors) {
      throw Exception(
        'فشل رفع بعض التعديلات المحلية. تم إيقاف السحب من السحابة لحماية بياناتك من المسح.',
      );
    }
  }

  Map<String, dynamic> _mapDollarPriceToCloud(
    DollarPricesHistoryData localData,
  ) {
    return {
      'id': localData.id,
      'effective_date': localData.effectiveDate.toUtc().toIso8601String(),
      'exchange_rate': localData.exchangeRate,
      'user_id': localData.userId,
      'created_at': localData.createdAt.toUtc().toIso8601String(),
      'updated_at': localData.updatedAt.toUtc().toIso8601String(),
      'is_deleted': localData.isDeleted,
    };
  }

  DollarPricesHistoryCompanion _mapCloudToDollarPrice(
    Map<String, dynamic> cloudData,
  ) {
    return DollarPricesHistoryCompanion(
      id: drift.Value(cloudData['id'].toString()),
      effectiveDate: drift.Value(
        DateTime.parse(cloudData['effective_date'].toString()).toUtc(),
      ),
      exchangeRate: drift.Value((cloudData['exchange_rate'] as num).toDouble()),
      userId: drift.Value(cloudData['user_id'].toString()),
      createdAt: drift.Value(
        DateTime.parse(cloudData['created_at'].toString()).toUtc(),
      ),
      updatedAt: drift.Value(
        DateTime.parse(cloudData['updated_at'].toString()).toUtc(),
      ),
      isDeleted: drift.Value(cloudData['is_deleted'] == true),
      isSynced: const drift.Value(true),
    );
  }
}
