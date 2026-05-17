//packages\erp_repository\lib\src\erp_repository.dart
import 'dart:io';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart'; 
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// المدير الذكي بنظام (Offline-First) والمزامنة الشبحية ثنائية الاتجاه (Push & Pull)
class ErpRepository {
  // ==========================================
  // 🏗️ الدالة البانية (Constructor)
  // ==========================================
  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient {
    // 🌟 السحر هنا: بمجرد بناء الـ Repository عند فتح التطبيق
    // نتحقق إذا كان المستخدم مسجلاً للدخول مسبقاً، نشغل الاستماع للسحابة فوراً!
    if (currentUserId != null) {
      _startCloudListener();

      // 2. 🌟 نشغل النسخ الاحتياطي التلقائي الصامت
      autoBackupSilent();

      // 🌟 السطر الجديد: تنظيف قاعدة البيانات المحلية من المهملات القديمة
      _localApi.autoCleanOldDeletedClients(); 
      _localApi.autoCleanOldDeletedContracts(); 
      _localApi.autoCleanOldDeletedLedgerEntries();
      
      _localApi.database.autoCleanOldDeletedBuildingsAndApartments(); 
    }
  }

  // 🌟 فصلنا كود تشغيل المستمع في دالة خاصة لترتيب الكود
  void _startCloudListener() {
    _cloudApi.startListeningToCloudChanges(
      onDataChanged: () {
        print('🔄 جاري سحب الأسعار الجديدة من السحابة بسبب تحديث حي...');
        pullDataFromCloud(); 
      },
    );
  }

  RealtimeChannel? _pricesChannel;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  bool _isSyncing = false;

  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  String? get currentUserId => _cloudApi.currentUserId;

  Future<void> signIn({required String email, required String password}) async {
    await _cloudApi.signIn(email: email, password: password);
    // 1. سحب كل بيانات الشركة فور تسجيل الدخول بنجاح!
    await pullDataFromCloud();
    
    // تشغيل المستمع بعد تسجيل الدخول لأول مرة
    _startCloudListener(); 
  }

  // 🌟 الدالة الجديدة المضافة هنا
  Future<void> signUp({required String fullName, required String email, required String password}) async {
    await _cloudApi.signUp(fullName: fullName, email: email, password: password);
    // لن نقوم بسحب البيانات هنا لأن الموظف الجديد لا يملك صلاحيات بعد
  }

  Future<void> signOut() async {
    await _cloudApi.signOut();
    // حماية قصوى: مسح قاعدة البيانات المحلية
    await _localApi.formatDatabase();
  }

  // ==========================================
  // 🔄 المزامنة اليدوية (زر المزامنة الأخضر في لوحة التحكم)
  // ==========================================
  Future<String> forceSyncWithCloud() async {
    try {
      await syncPendingData(); // 1. رفع أي تعديلات محلية أولاً
      await pullDataFromCloud(); // 2. سحب أي بيانات جديدة أضافها مدير آخر
      return 'تمت المزامنة مع السحابة بنجاح! ☁️✓';
    } catch (e) {
      return 'حدث خطأ أثناء المزامنة: $e';
    }
  }

  // ==========================================
  // 📥 محرك السحب الشبحي (Pull from Cloud) - النسخة فائقة الذكاء
  // ==========================================
  Future<void> pullDataFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. جلب وقت آخر مزامنة من الذاكرة
      final String? lastSyncStr = prefs.getString('last_pull_timestamp');
      DateTime? lastSyncTime; 
      
      // 🛡️ 2. حماية ذكية جداً: التحقق مما إذا كانت القاعدة المحلية فارغة (بسبب فورمات أو تغيير اسم الملف)
      final existingClients = await _localApi.getClients();
      final isDatabaseEmpty = existingClients.isEmpty;

      // 3. اتخاذ القرار: سحب تزايدي أم سحب شامل؟
      if (lastSyncStr != null && !isDatabaseEmpty) {
        lastSyncTime = DateTime.parse(lastSyncStr).toUtc();
        print('⏳ جاري سحب التعديلات فقط منذ: $lastSyncTime');
      } else {
        // إذا كانت القاعدة فارغة، نتجاهل الوقت القديم لنجبر السحابة على إرسال كل شيء!
        print('⏳ القاعدة فارغة أو مزامنة أولى: جاري سحب كامل البيانات من السحابة...');
        lastSyncTime = null; 
      }

      // 1. سحب العملاء
      final cloudClients = await _cloudApi.getClients(lastSync: lastSyncTime);
      for (var c in cloudClients) {
        final client = ClientsCompanion.insert(
          id: drift.Value(c['id'].toString()), 
          name: c['name'].toString(), 
          phone: c['phone'].toString(), 
          nationalId: drift.Value(c['national_id']?.toString()), 
          userId: c['user_id']?.toString() ?? '', 
          isDeleted: drift.Value(c['is_deleted'] == true), 
          updatedAt: drift.Value(DateTime.tryParse(c['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()), 
          isSynced: const drift.Value(true), 
        );
        await _localApi.syncClient(client); 
      }

      // 2. سحب العقود
      final cloudContracts = await _cloudApi.getContracts(lastSync: lastSyncTime);
      for (var c in cloudContracts) {
        final contract = ContractsCompanion.insert(
          id: drift.Value(c['id'].toString()), 
          clientId: c['client_id'].toString(), 
          apartmentId: drift.Value(c['apartment_id']?.toString()), 
          contractType: drift.Value(c['contract_type']?.toString() ?? 'لاحق التخصص'),
          apartmentDetails: drift.Value(c['apartment_details']?.toString() ?? ''),
          totalArea: double.tryParse(c['total_area']?.toString() ?? '0') ?? 0.0,
          baseMeterPriceAtSigning: double.tryParse(c['base_meter_price_at_signing']?.toString() ?? '0') ?? 0.0,
          
          downPayment: drift.Value(double.tryParse(c['down_payment']?.toString() ?? '0') ?? 0.0),
          isPenaltyActive: drift.Value(c['is_penalty_active'] == true),
          penaltyPercentage: drift.Value(double.tryParse(c['penalty_percentage']?.toString() ?? '0') ?? 0.0),
          penaltyIntervalMonths: drift.Value(int.tryParse(c['penalty_interval_months']?.toString() ?? '1') ?? 1),

          

          isHandedOver: drift.Value(c['is_handed_over'] == true),
          agreedHandoverDate: drift.Value(c['agreed_handover_date'] != null ? DateTime.tryParse(c['agreed_handover_date'].toString())?.toUtc() : null),
          actualHandoverDate: drift.Value(c['actual_handover_date'] != null ? DateTime.tryParse(c['actual_handover_date'].toString())?.toUtc() : null),
          gracePeriodMonths: drift.Value(int.tryParse(c['grace_period_months']?.toString() ?? '0') ?? 0),
          handoverNotes: drift.Value(c['handover_notes']?.toString()),
          
          installmentsCount: drift.Value(int.tryParse(c['installments_count']?.toString() ?? '48') ?? 48),
          agreedMonthlyAmount: drift.Value(double.tryParse(c['agreed_monthly_amount']?.toString() ?? '0') ?? 0.0),
          coefficients: drift.Value(c['coefficients']?.toString() ?? '{}'),
          contractDate: DateTime.tryParse(c['contract_date']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(),
          guarantorName: c['guarantor_name']?.toString() ?? 'بدون كفيل', 
          contractFileUrl: drift.Value(c['contract_file_url']?.toString()), 
          userId: c['user_id']?.toString() ?? '',
          lastActionDate: drift.Value(c['last_action_date'] != null ? DateTime.tryParse(c['last_action_date'].toString())?.toUtc() : null),
          lastActionNote: drift.Value(c['last_action_note']?.toString()),
          isCompleted: drift.Value(c['is_completed'] == true),
          isDeleted: drift.Value(c['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(c['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncContract(contract);
      }

      // 3. سحب أسعار المواد
      final cloudPrices = await _cloudApi.getMaterialPrices();
      for (var p in cloudPrices) {
        final price = MaterialPricesHistoryCompanion.insert(
          id: drift.Value(p['id'].toString()), 
          ironPrice: double.tryParse(p['iron_price']?.toString() ?? '0') ?? 0.0, 
          cementPrice: double.tryParse(p['cement_price']?.toString() ?? '0') ?? 0.0,
          block15Price: double.tryParse(p['block15_price']?.toString() ?? '0') ?? 0.0, 
          formworkAndPouringWages: double.tryParse(p['formwork_and_pouring_wages']?.toString() ?? '0') ?? 0.0,
          aggregateMaterialsPrice: double.tryParse(p['aggregate_materials_price']?.toString() ?? '0') ?? 0.0, 
          ordinaryWorkerWage: double.tryParse(p['ordinary_worker_wage']?.toString() ?? '0') ?? 0.0,
          effectiveDate: drift.Value(DateTime.tryParse(p['effective_date']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          userId: p['user_id']?.toString() ?? '',
          isDeleted: drift.Value(p['is_deleted'] == true),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncPrice(price); 
      }

      // 4. سحب جدول الاستحقاقات
      final cloudSchedules = await _cloudApi.getSchedules(lastSync: lastSyncTime);
      for (var s in cloudSchedules) {
        final schedule = InstallmentsScheduleCompanion.insert(
          id: drift.Value(s['id'].toString()), 
          contractId: s['contract_id'].toString(), 
          installmentNumber: int.tryParse(s['installment_number']?.toString() ?? '1') ?? 1, 
          dueDate: DateTime.tryParse(s['due_date']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(), 
          status: drift.Value(s['status']?.toString() ?? 'pending'),
          notes: drift.Value(s['notes']?.toString()),
          userId: s['user_id']?.toString() ?? '', 
          isDeleted: drift.Value(s['is_deleted'] == true), 
          updatedAt: drift.Value(DateTime.tryParse(s['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()), 
          isSynced: const drift.Value(true),
        );
        await _localApi.syncSchedule(schedule);
      }

      // 5. سحب الأقساط (الدفعات)
      final cloudPayments = await _cloudApi.getPayments(lastSync: lastSyncTime);
      for (var p in cloudPayments) {
        final payment = PaymentsLedgerCompanion.insert(
          id: drift.Value(p['id'].toString()), 
          contractId: p['contract_id'].toString(), 
          scheduleId: drift.Value(p['schedule_id']?.toString()), 
          paymentDate: DateTime.tryParse(p['payment_date']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(), 
          amountPaid: double.tryParse(p['amount_paid']?.toString() ?? '0') ?? 0.0, 
          meterPriceAtPayment: double.tryParse(p['meter_price_at_payment']?.toString() ?? '0') ?? 0.0,
          convertedMeters: double.tryParse(p['converted_meters']?.toString() ?? '0') ?? 0.0, 
          pricesSnapshot: drift.Value(p['prices_snapshot']?.toString() ?? '{}'),
          fees: drift.Value(double.tryParse(p['fees']?.toString() ?? '0') ?? 0.0),
          isWhatsAppSent: drift.Value(p['is_whatsapp_sent'] == true), 
          userId: p['user_id']?.toString() ?? '', 
          isDeleted: drift.Value(p['is_deleted'] == true), 
          updatedAt: drift.Value(DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()), 
          isSynced: const drift.Value(true),
        );
        await _localApi.syncPayment(payment);
      }

      // 6. سحب المحاضر
      final cloudBuildings = await _cloudApi.getBuildings();
      for (var b in cloudBuildings) {
        final building = BuildingsCompanion.insert(
          id: drift.Value(b['id'].toString()),
          name: b['name'].toString(),
          location: drift.Value(b['location']?.toString()),
          floorCoefficients: drift.Value(b['floor_coefficients']?.toString() ?? '{}'),
          directionCoefficients: drift.Value(b['direction_coefficients']?.toString() ?? '{}'),
          userId: drift.Value(b['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(b['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(b['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncBuilding(building);
      }

      // 7. سحب الشقق
      final cloudApartments = await _cloudApi.getApartments();
      for (var a in cloudApartments) {
        final apartment = ApartmentsCompanion.insert(
          id: drift.Value(a['id'].toString()),
          buildingId: a['building_id'].toString(),
          unitType: drift.Value(a['unit_type']?.toString() ?? 'apartment'),
          apartmentNumber: a['apartment_number'].toString(),
          area: double.tryParse(a['area']?.toString() ?? '0') ?? 0.0,
          floorName: a['floor_name'].toString(),
          directionName: a['direction_name']?.toString() ?? '-', 
          customCoefficients: drift.Value(a['custom_coefficients']?.toString() ?? '{}'),
          status: drift.Value(a['status']?.toString() ?? 'available'),
          userId: drift.Value(a['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(a['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(a['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncApartment(apartment);
      }

      // 8. 🛡️ سحب قوالب الأدوار (Roles)
      final cloudRoles = await _cloudApi.getAppRoles(lastSync: lastSyncTime);
      for (var r in cloudRoles) {
        final role = AppRolesCompanion.insert(
          id: drift.Value(r['id'].toString()),
          name: r['name'].toString(),
          permissionsJson: drift.Value(r['permissions']?.toString() ?? '[]'),
          isSystemRole: drift.Value(r['is_system_role'] == true),
          isDeleted: drift.Value(r['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(r['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncAppRole(role);
      }

      // 9. 🧑‍💼 سحب المستخدمين وصلاحياتهم (Users)
      final cloudUsers = await _cloudApi.getAppUsers(lastSync: lastSyncTime);
      for (var u in cloudUsers) {
        final user = LocalUsersCompanion.insert(
          id: u['id'].toString(), 
          email: u['email']?.toString() ?? '',
          fullName: drift.Value(u['full_name']?.toString()),
          roleId: drift.Value(u['role_id']?.toString()),
          extraPermissionsJson: drift.Value(u['extra_permissions']?.toString() ?? '[]'),
          revokedPermissionsJson: drift.Value(u['revoked_permissions']?.toString() ?? '[]'),
          isActive: drift.Value(u['is_active'] != false), 
          updatedAt: drift.Value(DateTime.tryParse(u['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncLocalUser(user);
      }

      // ==========================================
      // 10. ⚖️ سحب الإجراءات القانونية (الجدول الجديد)
      // ==========================================
      final cloudLegalActions = await _cloudApi.getLegalActions(lastSync: lastSyncTime);
      for (var a in cloudLegalActions) {
        final action = LegalActionsCompanion.insert(
          id: drift.Value(a['id'].toString()),
          contractId: a['contract_id'].toString(),
          actionType: a['action_type'].toString(),
          actionDate: DateTime.parse(a['action_date'].toString()).toUtc(),
          notes: drift.Value(a['notes']?.toString()),
          userId: a['user_id']?.toString() ?? '',
          isDeleted: drift.Value(a['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(a['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        // نستخدم الإدخال المباشر للجدول
        await _localApi.database.into(_localApi.database.legalActions).insert(action, mode: drift.InsertMode.insertOrReplace);
      }

      // ==========================================
      // 11. 📎 سحب المرفقات القانونية (الجدول الجديد)
      // ==========================================
      final cloudAttachments = await _cloudApi.getLegalActionAttachments(lastSync: lastSyncTime);
      for (var att in cloudAttachments) {
        final attachment = LegalActionAttachmentsCompanion.insert(
          id: drift.Value(att['id'].toString()),
          legalActionId: att['legal_action_id'].toString(),
          fileUrl: att['file_url'].toString(),
          fileName: drift.Value(att['file_name']?.toString()),
          fileType: drift.Value(att['file_type']?.toString()),
          userId: att['user_id']?.toString() ?? '',
          isDeleted: drift.Value(att['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(att['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.database.into(_localApi.database.legalActionAttachments).insert(attachment, mode: drift.InsertMode.insertOrReplace);
      }

      // 🌍 حفظ الوقت الحالي للعمليات القادمة
      await prefs.setString('last_pull_timestamp', DateTime.now().toUtc().toIso8601String());

      print('✅ تم تحديث كافة البيانات المحلية من السحابة بنجاح');
    } catch (e) {
      print('❌ Cloud Pull Failed: $e'); 
    }


    
    
    
  }

  // ==========================================
  // 📤 محرك الرفع الشبحي (Push to Cloud) - نسخة محمية ومحسنة 🛡️
  // ==========================================
  Future<void> syncPendingData() async {
    if (_isSyncing || currentUserId == null) return;
    _isSyncing = true;
    
    final db = _localApi.database;

    double _safeNum(double? val) {
      if (val == null) return 0.0;
      if (val.isInfinite || val.isNaN) return 0.0;
      return val;
    }

    // 1. مزامنة العملاء
    try {
      final pendingClients = await (db.select(db.clients)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingClients) {
        await _cloudApi.upsertClient({
          'id': c.id, 
          'name': c.name, 
          'phone': c.phone, 
          'national_id': c.nationalId,
          'user_id': c.userId,
          'is_deleted': c.isDeleted,
          'updated_at': c.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.clients)..where((t) => t.id.equals(c.id))).write(
          const ClientsCompanion(isSynced: drift.Value(true))
        );
      }
    } catch (e) { print('Sync Clients Failed: $e'); }

    // 2. مزامنة العقود
    try {
      final pendingContracts = await (db.select(db.contracts)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingContracts) {
        await _cloudApi.upsertContract({
          'id': c.id, 
          'client_id': c.clientId, 
          'apartment_id': c.apartmentId, 
          'contract_type': c.contractType, 
          'apartment_details': c.apartmentDetails, 
          'total_area': _safeNum(c.totalArea), 
          'base_meter_price_at_signing': _safeNum(c.baseMeterPriceAtSigning), 
          
          'down_payment': _safeNum(c.downPayment),
          'is_penalty_active': c.isPenaltyActive,
          'penalty_percentage': _safeNum(c.penaltyPercentage),
          'penalty_interval_months': c.penaltyIntervalMonths,

          

          'is_handed_over': c.isHandedOver,
          'agreed_handover_date': c.agreedHandoverDate?.toUtc().toIso8601String(),
          'actual_handover_date': c.actualHandoverDate?.toUtc().toIso8601String(),
          'grace_period_months': c.gracePeriodMonths,
          'handover_notes': c.handoverNotes,

          'installments_count': c.installmentsCount, 
          'agreed_monthly_amount': _safeNum(c.agreedMonthlyAmount),
          'coefficients': c.coefficients, 
          'contract_date': c.contractDate.toUtc().toIso8601String(), 
          'guarantor_name': c.guarantorName,
          'contract_file_url': c.contractFileUrl,
          'user_id': c.userId, 
          'is_completed': c.isCompleted, 
          'last_action_date': c.lastActionDate?.toUtc().toIso8601String(),
          'last_action_note': c.lastActionNote,
          'is_deleted': c.isDeleted, 
          'updated_at': c.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.contracts)..where((t) => t.id.equals(c.id))).write(
          const ContractsCompanion(isSynced: drift.Value(true))
        );
      }
    } catch (e) { print('Sync Contracts Failed: $e'); }

    // 3. مزامنة جدول الاستحقاقات
    try {
      final pendingSchedules = await (db.select(db.installmentsSchedule)..where((t) => t.isSynced.equals(false))).get();
      if (pendingSchedules.isNotEmpty) {
        final cloudSchedules = pendingSchedules.map((s) => {
          'id': s.id, 
          'contract_id': s.contractId, 
          'installment_number': s.installmentNumber, 
          'due_date': s.dueDate.toUtc().toIso8601String(), 
          'status': s.status, 
          'notes': s.notes,
          'user_id': s.userId, 
          'is_deleted': s.isDeleted, 
          'updated_at': s.updatedAt.toUtc().toIso8601String()
        }).toList();
        
        await _cloudApi.upsertSchedule(cloudSchedules); 
        
        for (var s in pendingSchedules) {
          await (db.update(db.installmentsSchedule)..where((t) => t.id.equals(s.id))).write(
            const InstallmentsScheduleCompanion(isSynced: drift.Value(true))
          );
        }
      }
    } catch (e) { print('Sync Schedules Failed: $e'); }

    // 4. مزامنة الدفعات
    try {
      final pendingPayments = await (db.select(db.paymentsLedger)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPayments) {
        await _cloudApi.upsertPayment({
          'id': p.id, 
          'contract_id': p.contractId, 
          'schedule_id': p.scheduleId, 
          'payment_date': p.paymentDate.toUtc().toIso8601String(), 
          'amount_paid': _safeNum(p.amountPaid), 
          'meter_price_at_payment': _safeNum(p.meterPriceAtPayment), 
          'converted_meters': _safeNum(p.convertedMeters), 
          'prices_snapshot': p.pricesSnapshot,
          'fees': _safeNum(p.fees), 
          'is_whatsapp_sent': p.isWhatsAppSent, 
          'user_id': p.userId, 
          'is_deleted': p.isDeleted, 
          'updated_at': p.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.paymentsLedger)..where((t) => t.id.equals(p.id))).write(
          const PaymentsLedgerCompanion(isSynced: drift.Value(true))
        );
      }
    } catch (e) { print('Sync Payments Failed: $e'); }
    
    // 5. مزامنة أسعار المواد
    try {
      final pendingPrices = await (db.select(db.materialPricesHistory)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPrices) {
        await _cloudApi.upsertMaterialPrices({
          'id': p.id, 
          'effective_date': p.effectiveDate.toUtc().toIso8601String(),
          'iron_price': _safeNum(p.ironPrice), 
          'cement_price': _safeNum(p.cementPrice), 
          'block15_price': _safeNum(p.block15Price), 
          'formwork_and_pouring_wages': _safeNum(p.formworkAndPouringWages), 
          'aggregate_materials_price': _safeNum(p.aggregateMaterialsPrice), 
          'ordinary_worker_wage': _safeNum(p.ordinaryWorkerWage), 
          'user_id': p.userId, 
          'is_deleted': p.isDeleted,
          'updated_at': DateTime.now().toUtc().toIso8601String(),  
        });
        await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(p.id))).write(const MaterialPricesHistoryCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Prices Failed: $e'); }
    
    // 6. مزامنة المحاضر
    try {
      final pendingBuildings = await (db.select(db.buildings)..where((t) => t.isSynced.equals(false))).get();
      for (var b in pendingBuildings) {
        await _cloudApi.upsertBuilding({
          'id': b.id,
          'name': b.name,
          'location': b.location,
          'floor_coefficients': b.floorCoefficients,
          'direction_coefficients': b.directionCoefficients,
          'user_id': b.userId,
          'is_deleted': b.isDeleted,
          'updated_at': b.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.buildings)..where((t) => t.id.equals(b.id))).write(const BuildingsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Buildings Failed: $e'); }

    // 7. مزامنة الشقق
    try {
      final pendingApartments = await (db.select(db.apartments)..where((t) => t.isSynced.equals(false))).get();
      for (var a in pendingApartments) {
        await _cloudApi.upsertApartment({
          'id': a.id,
          'building_id': a.buildingId,
          'unit_type': a.unitType,
          'apartment_number': a.apartmentNumber,
          'area': _safeNum(a.area),
          'floor_name': a.floorName,
          'direction_name': a.directionName,
          'custom_coefficients': a.customCoefficients,
          'status': a.status,
          'user_id': a.userId,
          'is_deleted': a.isDeleted,
          'updated_at': a.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.apartments)..where((t) => t.id.equals(a.id))).write(const ApartmentsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Apartments Failed: $e'); }

    // 8. مزامنة قوالب الأدوار
    try {
      final pendingRoles = await (db.select(db.appRoles)..where((t) => t.isSynced.equals(false))).get();
      for (var r in pendingRoles) {
        await _cloudApi.upsertAppRole({
          'id': r.id,
          'name': r.name,
          'permissions': r.permissionsJson, 
          'is_system_role': r.isSystemRole,
          'is_deleted': r.isDeleted,
          'updated_at': r.updatedAt.toUtc().toIso8601String() 
        });
        await (db.update(db.appRoles)..where((t) => t.id.equals(r.id))).write(const AppRolesCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Roles Failed: $e'); }

    // 9. مزامنة المستخدمين
    try {
      final pendingUsers = await (db.select(db.localUsers)..where((t) => t.isSynced.equals(false))).get();
      for (var u in pendingUsers) {
        await _cloudApi.upsertAppUser({
          'id': u.id,
          'full_name': u.fullName,
          'email': u.email,
          'role_id': u.roleId,
          'extra_permissions': u.extraPermissionsJson,
          'revoked_permissions': u.revokedPermissionsJson,
          'is_active': u.isActive,
          'updated_at': u.updatedAt.toUtc().toIso8601String() 
        });
        await (db.update(db.localUsers)..where((t) => t.id.equals(u.id))).write(const LocalUsersCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Users Failed: $e'); }

    // ==========================================
    // 10. ⚖️ مزامنة الإجراءات القانونية
    // ==========================================
    try {
      final pendingActions = await (db.select(db.legalActions)..where((t) => t.isSynced.equals(false))).get();
      for (var a in pendingActions) {
        await _cloudApi.upsertLegalAction({
          'id': a.id,
          'contract_id': a.contractId,
          'action_type': a.actionType,
          'action_date': a.actionDate.toUtc().toIso8601String(),
          'notes': a.notes,
          'user_id': a.userId,
          'is_deleted': a.isDeleted,
          'updated_at': a.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.legalActions)..where((t) => t.id.equals(a.id))).write(const LegalActionsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Legal Actions Failed: $e'); }


    // ==========================================
    // 11. 📎 مزامنة المرفقات القانونية (رفع البيانات)
    // ==========================================
    try {
      final pendingAttachments = await (db.select(db.legalActionAttachments)..where((t) => t.isSynced.equals(false))).get();
      for (var att in pendingAttachments) {
        await _cloudApi.upsertLegalActionAttachment({
          'id': att.id,
          'legal_action_id': att.legalActionId,
          'file_url': att.fileUrl,
          'file_name': att.fileName,
          'file_type': att.fileType,
          'user_id': att.userId,
          'is_deleted': att.isDeleted,
          'updated_at': att.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.legalActionAttachments)..where((t) => t.id.equals(att.id))).write(const LegalActionAttachmentsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Legal Attachments Failed: $e'); }
    

    _isSyncing = false; 
  }

  // ==========================================
  // 👥 العملاء 
  // ==========================================
  Future<List<Client>> getClients() => _localApi.getClients();

  Future<void> addClient(ClientsCompanion clientCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = clientCompanion.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addClient(companionWithUser); 
    syncPendingData(); 
  }

  Future<void> deleteClient(String clientId) async { 
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    
    await _localApi.deleteClient(clientId, safeUserId);
    syncPendingData();
  }

  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await (db.update(db.clients)..where((t) => t.id.equals(id))).write(
      ClientsCompanion(
        name: drift.Value(name),
        phone: drift.Value(phone),
        nationalId: drift.Value(nationalId),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }

  // ==========================================
  // 🗑️ إدارة سلة المحذوفات للعملاء
  // ==========================================
  Future<List<Client>> getDeletedClients() => _localApi.getDeletedClients();

  Future<void> restoreClient(String clientId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restoreClient(clientId, safeUserId);
    await syncPendingData(); 
  }

  Future<void> forceHardDeleteClient(String clientId) async {
    await _localApi.hardDeleteClientLocal(clientId);
  }

  // ==========================================
  // 📄 العقود والتوليد الآلي للاستحقاقات
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<List<Contract>> getContractsForClient(String clientId) async {
    final allContracts = await getAllContracts();
    return allContracts.where((c) => c.clientId == clientId && c.isDeleted != true).toList();
  }

  Future<void> markContractActionTaken({required String contractId, required String note}) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.markContractActionTaken(contractId, note, safeUserId);
    await syncPendingData(); 
  }
  
  Future<void> addContract(ContractsCompanion contractCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    
    final companionWithUser = contractCompanion.copyWith(userId: drift.Value(currentUserId!));
    final int months = contractCompanion.installmentsCount.present ? contractCompanion.installmentsCount.value : 48;
    final DateTime startDate = contractCompanion.contractDate.present ? contractCompanion.contractDate.value : DateTime.now().toUtc();
    
    final String type = contractCompanion.contractType.present ? contractCompanion.contractType.value : 'متخصص';
    
    await _localApi.addContractWithSchedules(companionWithUser, months, startDate, currentUserId!, type);
    await syncPendingData();
  }

  Future<void> deleteContract(String contractId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteContract(contractId, safeUserId);
    syncPendingData();
  }

  // ==========================================
  // 🌟 تعديل العقد الأساسي
  // ==========================================
  Future<void> updateContract({
    required String id,
    required String apartmentDetails,
    required String guarantorName,
    required int installmentsCount,
    required double agreedMonthlyAmount,
    required DateTime contractDate,
    required bool isPenaltyActive,
    required double penaltyPercentage,
    required int penaltyIntervalMonths,
  }) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        apartmentDetails: drift.Value(apartmentDetails),
        guarantorName: drift.Value(guarantorName),
        installmentsCount: drift.Value(installmentsCount),
        agreedMonthlyAmount: drift.Value(agreedMonthlyAmount),
        contractDate: drift.Value(contractDate.toUtc()), 
        isPenaltyActive: drift.Value(isPenaltyActive),
        penaltyPercentage: drift.Value(penaltyPercentage),
        penaltyIntervalMonths: drift.Value(penaltyIntervalMonths),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );

    await (db.update(db.installmentsSchedule)
      ..where((t) => t.contractId.equals(id))
      ..where((t) => t.installmentNumber.isBiggerThanValue(installmentsCount)) 
      ..where((t) => t.status.equals('pending')) 
    ).write(
      const InstallmentsScheduleCompanion(isDeleted: drift.Value(true), isSynced: drift.Value(false))
    );

    await syncPendingData();
  }

  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً لإجراء التعديلات المالية.');

    await _localApi.restructureContractSchedule(
      contractId: contractId,
      newRemainingMonths: newRemainingMonths,
      newStartDate: newStartDate.toUtc(), 
      userId: safeUserId,
    );
    await syncPendingData();
  }

  // ==========================================
  // 🔑 تسليم الشقة (خاص بالعقود المتخصصة)
  // ==========================================
  Future<void> markContractAsHandedOver({
    required String contractId, 
    required String? apartmentId, 
    required DateTime actualHandoverDate, 
    String? notes
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.markContractAsHandedOver(contractId, apartmentId, actualHandoverDate, notes, safeUserId);
    await syncPendingData(); 
  }

  // ==========================================
  // ⏪ التراجع عن تسليم الشقة
  // ==========================================
  Future<void> cancelContractHandover({required String contractId, required String? apartmentId}) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.cancelContractHandover(contractId, apartmentId, safeUserId);
    await syncPendingData(); 
  }
  
  // ==========================================
  // 🗑️ إدارة سلة المحذوفات للعقود
  // ==========================================
  Future<List<Contract>> getDeletedContracts() => _localApi.getDeletedContracts();

  Future<void> restoreContract(String contractId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restoreContract(contractId, safeUserId);
    await syncPendingData(); 
  }

  Future<void> forceHardDeleteContract(String contractId) async {
    await _localApi.hardDeleteContractLocal(contractId);
  }

  // ==========================================
  // 📅 جدول الاستحقاقات (المراقبة)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => _localApi.getContractSchedule(contractId);

  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String scheduleId,
    required String actionType,
    required DateTime nextDueDate,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.handleRollingCheckpoint(contractId, scheduleId, actionType, nextDueDate, safeUserId);
    await syncPendingData(); 
  }
  
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() => _localApi.getAllOverdueSchedules();

  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required DateTime newDueDate,
    String? notes,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateIndividualSchedule(scheduleId, newDueDate, notes, safeUserId);
    await syncPendingData(); 
  }

  Future<void> updateContractDateOnly({required String id, required DateTime contractDate}) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        contractDate: drift.Value(contractDate.toUtc()),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }
  
  // ==========================================
  // 💰 الأقساط (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId);
  Future<List<PaymentsLedgerData>> getAllPayments() => _localApi.getAllPayments();

  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    final String? safeUserId = currentUserId; 
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final companionWithUser = entryCompanion.copyWith(userId: drift.Value(safeUserId));
    await _localApi.addLedgerEntry(companionWithUser);
    
    if (entryCompanion.scheduleId.present && entryCompanion.scheduleId.value != null) {
      await _localApi.updateScheduleStatus(entryCompanion.scheduleId.value!, 'paid', safeUserId);
    }
    await syncPendingData(); 
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateScheduleStatus(scheduleId, status, safeUserId);
    await syncPendingData(); 
  }

  Future<void> markWhatsAppAsSent(String entryId) async { 
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateWhatsAppStatus(entryId, safeUserId);
    await syncPendingData();
  }

  Future<void> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateLedgerEntryAmount(
      entryId: entryId, 
      newAmount: newAmount, 
      newDiscount: newDiscount, 
      newConvertedMeters: newConvertedMeters,
      userId: safeUserId, 
    );
    await syncPendingData(); 
  }

  Future<void> softDeleteLedgerEntry(String entryId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.softDeleteLedgerEntry(entryId, safeUserId);
    await syncPendingData();
  }

  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() => _localApi.getDeletedLedgerEntries();

  Future<void> restoreLedgerEntry(String entryId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restoreLedgerEntry(entryId, safeUserId);
    await syncPendingData(); 
  }

  Future<void> forceHardDeleteLedgerEntry(String entryId) async {
    await _localApi.forceHardDeleteLedgerEntry(entryId);
  }

  // ==========================================
  // ⚙️ الإعدادات (Material Prices)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _localApi.getLatestPrices();
  Stream<MaterialPricesHistoryData?> watchLatestPrices() => _localApi.watchLatestPrices();
  
  Future<void> savePrices(MaterialPricesHistoryCompanion pricesCompanion) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً');

    final String newId = const Uuid().v7();

    final companionReadyToSave = pricesCompanion.copyWith(
      id: drift.Value(newId),
      userId: drift.Value(safeUserId),
      isSynced: const drift.Value(false),
    );

    await _localApi.savePrices(companionReadyToSave);
    await syncPendingData(); 
  }
  
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => _localApi.getAllMaterialPricesHistory();
  
  Future<void> softDeleteMaterialPrice(String priceId) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(priceId))).write(
      MaterialPricesHistoryCompanion(
        isDeleted: const drift.Value(true),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }

  // ==========================================
  // 🏢 إدارة المحاضر والشقق
  // ==========================================
  Future<List<Building>> getBuildings() => _localApi.getBuildings();
  Future<List<Apartment>> getAllApartments() => _localApi.getAllApartments();

  Future<void> changeApartmentStatus(String apartmentId, String status) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.changeApartmentStatus(apartmentId, status, safeUserId);
    await syncPendingData(); 
  }

  Future<void> addBuilding(BuildingsCompanion building) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = building.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addBuilding(companionWithUser);
    await syncPendingData(); 
  }

  Future<void> addApartment(ApartmentsCompanion apartment) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = apartment.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addApartment(companionWithUser);
    await syncPendingData(); 
  }

  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await (db.update(db.buildings)..where((t) => t.id.equals(id))).write(
      BuildingsCompanion(
        name: drift.Value(name),
        location: drift.Value(location),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }

  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await (db.update(db.apartments)..where((t) => t.id.equals(id))).write(
      ApartmentsCompanion(
        apartmentNumber: drift.Value(apartmentNumber),
        area: drift.Value(area),
        directionName: drift.Value(directionName),
        userId: drift.Value(safeUserId), 
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }
  
  // ==========================================
  // 📡 محرك الاستماع السحابي الحي (Realtime Sync)
  // ==========================================
  void startListeningToCloudChanges() {
    _pricesChannel?.unsubscribe();

    _pricesChannel = Supabase.instance.client
        .channel('public:material_prices')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, 
          schema: 'public',
          table: 'material_prices',
          callback: (payload) {
            print('🔥 السحابة تقول: تم تغيير الأسعار! جاري التحديث التلقائي...');
            pullDataFromCloud(); 
          },
        )
        .subscribe();
  }

  // ==========================================
  // 🌟 إرفاق ملف Word للعقد 
  // ==========================================
  Future<void> attachFileToContract(String contractId, File file, String extension) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    try {
      final fileUrl = await _cloudApi.uploadContractFile(
        contractId: contractId, 
        file: file, 
        extension: extension
      );

      final db = _localApi.database;
      await (db.update(db.contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          contractFileUrl: drift.Value(fileUrl),
          userId: drift.Value(safeUserId), 
          updatedAt: drift.Value(DateTime.now().toUtc()),
          isSynced: const drift.Value(false),
        )
      );
      await syncPendingData();

    } catch (e, stacktrace) {
      print('❌❌ خطأ فادح أثناء إرفاق الملف: $e');
      print('🔍 التفاصيل: $stacktrace');
      throw Exception('فشل الإرفاق: $e'); 
    }
  }


  // ==========================================
  // 🛡️ قسم النسخ الاحتياطي والاستعادة (Backup & Restore)
  // ==========================================
  final String _dbFileName = 'our_home_erp_v10_uuidv7.sqlite';

  Future<void> autoBackupSilent() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) return; 

      final docsDir = await getApplicationDocumentsDirectory();
      final backupFolder = Directory(p.join(docsDir.path, 'OurHomeERP_AutoBackups'));
      
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      final String dateOnly = DateTime.now().toIso8601String().split('T')[0];
      final String backupPath = p.join(backupFolder.path, 'AutoBackup_$dateOnly.sqlite');

      await dbFile.copy(backupPath);
      print('🛡️[Auto-Backup]: تم أخذ نسخة احتياطية بنجاح ليوم $dateOnly');
      
    } catch (e) {
      print('⚠️ [Auto-Backup] فشل النسخ التلقائي: $e');
    }
  }

  Future<String> backupDatabaseManually() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) {
        return '❌ لا توجد قاعدة بيانات لنسخها بعد.';
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلداً لحفظ النسخة الاحتياطية',
      );

      if (selectedDirectory == null) {
        return '⚠️ تم إلغاء العملية.';
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = p.join(selectedDirectory, 'ERP_ManualBackup_$timestamp.sqlite');

      await dbFile.copy(backupPath);
      return '✅ تم الحفظ بنجاح في:\n$backupPath';
    } catch (e) {
      return '❌ حدث خطأ أثناء النسخ: $e';
    }
  }

  Future<String> restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية (sqlite)',
        type: FileType.custom,
        allowedExtensions:['sqlite', 'db'],
      );

      if (result == null || result.files.single.path == null) {
        return '⚠️ تم إلغاء الاستعادة.';
      }

      File backupFile = File(result.files.single.path!);
      final supportDir = await getApplicationSupportDirectory();
      final targetDbPath = p.join(supportDir.path, _dbFileName);

      await _localApi.database.close();
      await backupFile.copy(targetDbPath);

      return '✅ تمت استعادة البيانات بنجاح!\n\n🚨 يرجى إغلاق البرنامج بالكامل وإعادة فتحه لتطبيق التغييرات.';
    } catch (e) {
      return '❌ فشلت الاستعادة: $e';
    }
  }

  // ==========================================
  // 🗑️ إدارة حذف المحاضر والشقق (مع طبقة الحماية)
  // ==========================================

  Future<void> softDeleteApartment(String apartmentId) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    
    final apt = await (db.select(db.apartments)..where((t) => t.id.equals(apartmentId))).getSingle();
    if (apt.status != 'available') {
      throw Exception('⚠️ لا يمكن حذف هذه الوحدة لأن حالتها حالياً: ${apt.status}');
    }

    await db.softDeleteApartment(apartmentId, safeUserId); 
    await syncPendingData(); 
  }

  Future<void> softDeleteBuilding(String buildingId) async {
    final db = _localApi.database;
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final buildingApartments = await (db.select(db.apartments)..where((t) => t.buildingId.equals(buildingId) & t.isDeleted.equals(false))).get();
    
    final hasSoldApartments = buildingApartments.any((apt) => apt.status != 'available');
    if (hasSoldApartments) {
      throw Exception('⛔ لا يمكن حذف هذا المحضر لاحتوائه على وحدات مباعة. يرجى حذف الوحدات المتاحة يدوياً إن أردت.');
    }

    await db.softDeleteBuilding(buildingId, safeUserId); 
    await syncPendingData(); 
  }

  Future<void> restoreApartment(String apartmentId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.database.restoreSoftDeletedApartment(apartmentId, safeUserId);
    await syncPendingData();
  }

  Future<void> restoreBuilding(String buildingId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.database.restoreSoftDeletedBuilding(buildingId, safeUserId);
    await syncPendingData();
  }

  Future<void> forceHardDeleteApartment(String apartmentId) async {
    await _localApi.database.hardDeleteApartment(apartmentId);
  }

  Future<void> forceHardDeleteBuilding(String buildingId) async {
    await _localApi.database.hardDeleteBuilding(buildingId);
  }

  Future<List<Building>> getDeletedBuildings() => _localApi.database.getDeletedBuildings();
  Future<List<Apartment>> getDeletedApartments() => _localApi.database.getDeletedApartments();

  // ==========================================
  // 🛡️ إدارة الصلاحيات والمستخدمين (لوحة تحكم الأدمن)
  // ==========================================
  Future<List<AppRole>> getAllRoles() => _localApi.getAllRoles();
  Future<List<LocalUser>> getAllLocalUsers() => _localApi.getAllLocalUsers();

  Future<List<LocalUser>> getAllUsers() => _localApi.getAllLocalUsers();

  Future<void> createRole({required String name, required String permissionsJson}) async {
    final companion = AppRolesCompanion.insert(
      name: name,
      permissionsJson: drift.Value(permissionsJson),
      isSynced: const drift.Value(false), 
    );
    await _localApi.addRole(companion);
    await syncPendingData(); 
  }

  Future<void> updateRolePermissions({required String roleId, required String permissionsJson}) async {
    await _localApi.updateRolePermissions(roleId, permissionsJson);
    await syncPendingData();
  }

  Future<void> updateUserRoleAndPermissions({
    required String userId,
    required String roleId,
    String? extraPermissionsJson,
    String? revokedPermissionsJson,
    bool? isActive,
  }) async {
    await _localApi.updateUserRoleAndPermissions(
      userId: userId,
      roleId: roleId,
      extraPermissionsJson: extraPermissionsJson,
      revokedPermissionsJson: revokedPermissionsJson,
      isActive: isActive,
    );
    await syncPendingData();
  }

  Future<LocalUser?> getLocalUserById(String id) => _localApi.getLocalUserById(id);
  Future<AppRole?> getRoleById(String id) => _localApi.getRoleById(id);

  // ==========================================
  // 🕒 نظام تتبع النشاطات (Activity Log)
  // ==========================================
  Future<List<ActivityItem>> getRecentActivities({int limitPerType = 20, int finalLimit = 30}) async {
    final List<ActivityItem> allActivities =[];

    final recentPayments = await _localApi.getRecentPayments(limitPerType);
    final recentContracts = await _localApi.getRecentContracts(limitPerType);
    final recentClients = await _localApi.getRecentClients(limitPerType);

    for (var p in recentPayments) {
      allActivities.add(ActivityItem(
        entityId: p.id,
        type: ActivityType.payment,
        title: 'حركة مالية (دفعة/تعديل)',
        description: 'دفعة بقيمة ${p.amountPaid} للعقد ${p.contractId.substring(0, 5)}...', 
        timestamp: p.updatedAt,
        userId: p.userId,
      ));
    }

    for (var c in recentContracts) {
      if (c.lastActionDate != null && c.lastActionDate!.difference(c.updatedAt).inMinutes.abs() < 5) {
        allActivities.add(ActivityItem(
          entityId: c.id,
          type: ActivityType.adminAction,
          title: 'إجراء إداري (ملاحظة)',
          description: c.lastActionNote ?? 'تم تسجيل ملاحظة على العقد',
          timestamp: c.updatedAt,
          userId: c.userId,
        ));
      } else {
        allActivities.add(ActivityItem(
          entityId: c.id,
          type: ActivityType.contract,
          title: 'إضافة/تعديل عقد',
          description: 'عقد جديد أو معدل للعميل ${c.clientId.substring(0, 5)}...',
          timestamp: c.updatedAt,
          userId: c.userId,
        ));
      }
    }

    for (var c in recentClients) {
      allActivities.add(ActivityItem(
        entityId: c.id,
        type: ActivityType.client,
        title: 'إضافة/تعديل عميل',
        description: 'العميل: ${c.name}',
        timestamp: c.updatedAt,
        userId: c.userId,
      ));
    }

    allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final trimmedActivities = allActivities.length > finalLimit 
        ? allActivities.sublist(0, finalLimit) 
        : allActivities;

    final allUsers = await _localApi.getAllLocalUsers();
    final Map<String, String> userNamesMap = {
      for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
    };

    for (var activity in trimmedActivities) {
      if (userNamesMap.containsKey(activity.userId)) {
        activity.userName = userNamesMap[activity.userId]!;
      }
    }

    return trimmedActivities;
  }
  
  // ==========================================
  // 🔒 إغلاق أو إعادة فتح العقد (أرشفة)
  // ==========================================
  Future<void> toggleContractCompletion({required String contractId, required bool isCompleted}) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.toggleContractCompletion(contractId, isCompleted, safeUserId);
    await syncPendingData(); 
  }



  // ==========================================
  // ⚖️ إدارة الإجراءات القانونية (صفحة المحامي)
  // ==========================================
  Future<List<LegalAction>> getLegalActionsForContract(String contractId) => _localApi.getLegalActionsForContract(contractId);

  Future<void> addLegalAction(LegalActionsCompanion action) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final companionWithUser = action.copyWith(userId: drift.Value(safeUserId));
    await _localApi.addLegalAction(companionWithUser);
    await syncPendingData(); 
  }

  // ==========================================
  // تعديل إجراء قانوني
  // ==========================================
  Future<void> updateLegalAction(LegalActionsCompanion action) async {
    // 🌟 تم تصحيح الاسم من _localStorageApi إلى _localApi
    await _localApi.updateLegalAction(action);
    await syncPendingData(); // 🌟 أضفنا هذا السطر أيضاً ليقوم برفع التعديل للسحابة مباشرة
  }
  Future<void> deleteLegalAction(String actionId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteLegalAction(actionId, safeUserId);
    await syncPendingData(); 
  }

  Future<List<LegalAction>> getAllLegalActions() => _localApi.getAllLegalActions();
  Future<List<LegalActionAttachment>> getAllLegalActionAttachments() => _localApi.getAllLegalActionAttachments();

  // 🌟 (هذه الدالة لحذف المرفق التي استدعيناها في الـ Cubit)
  Future<void> deleteLegalActionAttachment(String attachmentId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteLegalActionAttachment(attachmentId, safeUserId);
    await syncPendingData(); 
  }
  
  // 📎 إرفاق ملف لإجراء قانوني
  Future<void> attachFileToLegalAction({
    required String actionId, 
    required File file, 
    required String extension,
    required String originalFileName,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    try {
      // 1. توليد آي دي جديد للمرفق
      final String attachmentId = const Uuid().v7();

      // 2. رفع الملف الفعلي للسحابة وجلب الرابط
      final fileUrl = await _cloudApi.uploadLegalAttachmentFile(
        attachmentId: attachmentId, 
        file: file, 
        extension: extension
      );

      // 3. حفظ بيانات المرفق في قاعدة البيانات المحلية
      final newAttachment = LegalActionAttachmentsCompanion.insert(
        id: drift.Value(attachmentId),
        legalActionId: actionId,
        fileUrl: fileUrl,
        fileName: drift.Value(originalFileName),
        fileType: drift.Value(extension),
        userId: safeUserId,
        isSynced: const drift.Value(false), // ستتم مزامنتها تلقائياً بالخطوة التالية
      );

      await _localApi.database.insertLegalActionAttachment(newAttachment);
      
      // 4. دفع البيانات للسحابة
      await syncPendingData();

    } catch (e) {
      print('❌ خطأ أثناء إرفاق الملف القانوني: $e');
      throw Exception('فشل الإرفاق: $e'); 
    }
  }
  

    // ==========================================
  // 💵 Mappers (Dollar Prices) - ضعها هنا
  // ==========================================
  Map<String, dynamic> _mapDollarPriceToCloud(DollarPricesHistoryData localData) {
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

  DollarPricesHistoryCompanion _mapCloudToDollarPrice(Map<String, dynamic> cloudData) {
    return DollarPricesHistoryCompanion(
      id: Value(cloudData['id']),
      effectiveDate: Value(DateTime.parse(cloudData['effective_date']).toUtc()),
      exchangeRate: Value((cloudData['exchange_rate'] as num).toDouble()),
      userId: Value(cloudData['user_id']),
      createdAt: Value(DateTime.parse(cloudData['created_at']).toUtc()),
      updatedAt: Value(DateTime.parse(cloudData['updated_at']).toUtc()),
      isDeleted: Value(cloudData['is_deleted'] == true),
      isSynced: const Value(true),
    );
  }

  // ==========================================
  // 💵 دوال الدولار للواجهات - ضعها تحت الـ Mappers مباشرة
  // ==========================================
  
  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() => 
      _localStorageApi.watchLatestDollarPrice();

  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() => 
      _localStorageApi.getAllDollarPricesHistory();

  Future<void> saveDollarPrice(DollarPricesHistoryCompanion prices) async {
    final newId = await _localStorageApi.saveDollarPrice(prices);
    try {
      final savedData = await _localStorageApi.database.select(_localStorageApi.database.dollarPricesHistory)
          .where((t) => t.id.equals(newId)).getSingle();
      await _cloudStorageClient.upsertDollarPrice(_mapDollarPriceToCloud(savedData));
      await _localStorageApi.syncDollarPrice(savedData.copyWith(isSynced: true).toCompanion(true));
    } catch (e) {
      print('⚠️ الحفظ المحلي تم، لكن الرفع السحابي فشل.');
    }
  }

  Future<void> softDeleteDollarPrice(String id) async {
    await _localStorageApi.softDeleteDollarPrice(id);
    forceSyncWithCloud();
  }
}

// نموذج يمثل حركة أو نشاط واحد في النظام
enum ActivityType { payment, contract, client, adminAction }

class ActivityItem {
  final String entityId; 
  final ActivityType type; 
  final String title; 
  final String description; 
  final DateTime timestamp; 
  final String userId; 
  String userName; 

  ActivityItem({
    required this.entityId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userId,
    this.userName = 'مستخدم غير معروف',
  });
}