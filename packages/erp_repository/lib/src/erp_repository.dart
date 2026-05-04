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

      // 4. سحب جدول الاستحقاقات (مع دعم حقل الملاحظات notes الجديد)
      final cloudSchedules = await _cloudApi.getSchedules(lastSync: lastSyncTime);
      for (var s in cloudSchedules) {
        final schedule = InstallmentsScheduleCompanion.insert(
          id: drift.Value(s['id'].toString()), 
          contractId: s['contract_id'].toString(), 
          installmentNumber: int.tryParse(s['installment_number']?.toString() ?? '1') ?? 1, 
          dueDate: DateTime.tryParse(s['due_date']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc(), 
          status: drift.Value(s['status']?.toString() ?? 'pending'),
          notes: drift.Value(s['notes']?.toString()), // 🌟 قراءة الملاحظات من السحابة
          userId: s['user_id']?.toString() ?? '', 
          isDeleted: drift.Value(s['is_deleted'] == true), 
          updatedAt: drift.Value(DateTime.tryParse(s['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()), 
          isSynced: const drift.Value(true),
        );
        await _localApi.syncSchedule(schedule);
      }

      // 5. سحب دفتر الأستاذ (الدفعات)
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
          unitType: drift.Value(a['unit_type']?.toString() ?? 'apartment'), // 🌟 السطر الجديد
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
          id: u['id'].toString(), // ID هنا إجباري لأنه قادم من السحابة ولا يولد محلياً
          email: u['email']?.toString() ?? '',
          fullName: drift.Value(u['full_name']?.toString()),
          roleId: drift.Value(u['role_id']?.toString()),
          extraPermissionsJson: drift.Value(u['extra_permissions']?.toString() ?? '[]'),
          revokedPermissionsJson: drift.Value(u['revoked_permissions']?.toString() ?? '[]'),
          isActive: drift.Value(u['is_active'] != false), // الافتراضي true
          updatedAt: drift.Value(DateTime.tryParse(u['updated_at']?.toString() ?? '')?.toUtc() ?? DateTime.now().toUtc()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncLocalUser(user);
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

    // 🛡️ دالة مساعدة لمنع خطأ الـ Infinity في تحويل الـ JSON
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
          'national_id': c.nationalId, // تم التوحيد
          'user_id': c.userId, // تم التوحيد
          'is_deleted': c.isDeleted, // تم التوحيد
          'updated_at': c.updatedAt.toUtc().toIso8601String() // تم التوحيد
        });
        // تحديث الحالة محلياً
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
        'client_id': c.clientId, // تم التوحيد
        'apartment_id': c.apartmentId, 
        'contract_type': c.contractType, 
        'apartment_details': c.apartmentDetails, 
        'total_area': _safeNum(c.totalArea), 
        'base_meter_price_at_signing': _safeNum(c.baseMeterPriceAtSigning), 
        'installments_count': c.installmentsCount, 
        'agreed_monthly_amount': _safeNum(c.agreedMonthlyAmount),
        
        'coefficients': c.coefficients, 
        // 🌍 التعديل الضروري: UTC
        'contract_date': c.contractDate.toUtc().toIso8601String(), 
        'guarantor_name': c.guarantorName,
        'contract_file_url': c.contractFileUrl,
        'user_id': c.userId, 
        'is_completed': c.isCompleted, 

        // 🌟 السطرين الجديدين للرفع
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
        // تجهيز البيانات بصيغة snake_case للرفع للسحابة
        final cloudSchedules = pendingSchedules.map((s) => {
          'id': s.id, 
          'contract_id': s.contractId, 
          'installment_number': s.installmentNumber, 
          // 🌍 التعديل الضروري: UTC
          'due_date': s.dueDate.toUtc().toIso8601String(), 
          'status': s.status, 
          'notes': s.notes,
          'user_id': s.userId, 
          'is_deleted': s.isDeleted, 
          'updated_at': s.updatedAt.toUtc().toIso8601String()
        }).toList();
        
        await _cloudApi.upsertSchedule(cloudSchedules); 
        
        // تحديث الحالة محلياً
        for (var s in pendingSchedules) {
          await (db.update(db.installmentsSchedule)..where((t) => t.id.equals(s.id))).write(
            const InstallmentsScheduleCompanion(isSynced: drift.Value(true))
          );
        }
      }
    } catch (e) { print('Sync Schedules Failed: $e'); }

    // 4. مزامنة الدفعات (هنا كان يحدث خطأ الـ Infinity) 🚨
    try {
      final pendingPayments = await (db.select(db.paymentsLedger)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPayments) {
        await _cloudApi.upsertPayment({
          'id': p.id, 
          'contract_id': p.contractId, // استخدام snake_case للرفع
          'schedule_id': p.scheduleId, 
          // 🌍 التعديل الضروري: UTC
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
        // تحديث الحالة محلياً بأنها زومنت بنجاح
        await (db.update(db.paymentsLedger)..where((t) => t.id.equals(p.id))).write(
          const PaymentsLedgerCompanion(isSynced: drift.Value(true))
        );
      }
    } catch (e) { print('Sync Payments Failed: $e'); }
    
    // 5. مزامنة أسعار المواد (المعدل ليتوافق مع SQL)
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
          'updated_at': DateTime.now().toUtc().toIso8601String(),  // حقل الوقت الضروري بـ UTC
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
          // 🌍 التعديل الضروري: UTC
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
          // 🌍 التعديل الضروري: UTC
          'updated_at': a.updatedAt.toUtc().toIso8601String()
        });
        await (db.update(db.apartments)..where((t) => t.id.equals(a.id))).write(const ApartmentsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Apartments Failed: $e'); }


    // 8. 🛡️ مزامنة قوالب الأدوار
    try {
      final pendingRoles = await (db.select(db.appRoles)..where((t) => t.isSynced.equals(false))).get();
      for (var r in pendingRoles) {
        await _cloudApi.upsertAppRole({
          'id': r.id,
          'name': r.name,
          'permissions': r.permissionsJson, // يتوافق مع اسم العمود في Supabase
          'is_system_role': r.isSystemRole,
          'is_deleted': r.isDeleted,
          'updated_at': r.updatedAt.toUtc().toIso8601String() // 🌍 حماية الـ UTC
        });
        await (db.update(db.appRoles)..where((t) => t.id.equals(r.id))).write(const AppRolesCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Roles Failed: $e'); }

    // 9. 🧑‍💼 مزامنة تعديلات المستخدمين (كإعطاء دور أو إيقاف حساب)
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
          'updated_at': u.updatedAt.toUtc().toIso8601String() // 🌍 حماية الـ UTC
        });
        await (db.update(db.localUsers)..where((t) => t.id.equals(u.id))).write(const LocalUsersCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Users Failed: $e'); }


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
    await _localApi.deleteClient(clientId);
    syncPendingData();
  }

  // 🌟 الصق الدالة الجديدة هنا 🌟
  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    final db = _localApi.database;
    
    // 🌟 1. جلب آي دي المستخدم الحالي الذي يقوم بعملية التعديل الآن
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // 2. تحديث بيانات العميل + استبدال المستخدم
    await (db.update(db.clients)..where((t) => t.id.equals(id))).write(
      ClientsCompanion(
        name: drift.Value(name),
        phone: drift.Value(phone),
        nationalId: drift.Value(nationalId),
        
        // 🌟 3. هنا السحر: استبدال المستخدم القديم بالمستخدم الذي قام بالتعديل
        userId: drift.Value(safeUserId), 
        
        // 🌍 تحديث الوقت
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
    await _localApi.restoreClient(clientId);
    await syncPendingData(); // 🌟 رفع أمر الاستعادة للسحابة فوراً
  }

  Future<void> forceHardDeleteClient(String clientId) async {
    await _localApi.hardDeleteClientLocal(clientId);
    // ملاحظة: لا نرفع هذا للسحابة، لأن السحابة ستقوم بحذفه تلقائياً
    // عبر الـ Cron Job بعد 7 أيام للحفاظ على الأداء.
  }


  // ==========================================
  // 📄 العقود والتوليد الآلي للاستحقاقات
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();
  // 🌟 الدالة الجديدة المضافة لجلب عقود عميل محدد للتحقق قبل الحذف
  Future<List<Contract>> getContractsForClient(String clientId) async {
    final allContracts = await getAllContracts();
    // جلب العقود الفعالة (غير المحذوفة) المرتبطة بهذا العميل
    return allContracts.where((c) => c.clientId == clientId && c.isDeleted != true).toList();
  }


  // ==========================================
  // 🌟 تسجيل إجراء الرادار
  // ==========================================
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
    
    // 🌟 استخراج نوع العقد
    final String type = contractCompanion.contractType.present ? contractCompanion.contractType.value : 'متخصص';
    
    // 🌟 تمرير النوع لآلة التوليد
    await _localApi.addContractWithSchedules(companionWithUser, months, startDate, currentUserId!, type);
    
    await syncPendingData();
  }


  Future<void> deleteContract(String contractId) async {
    await _localApi.deleteContract(contractId);
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
  }) async {
    final db = _localApi.database;
    
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // 1. تحديث بيانات العقد الأساسية (مع استبدال المستخدم)
    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        apartmentDetails: drift.Value(apartmentDetails),
        guarantorName: drift.Value(guarantorName),
        installmentsCount: drift.Value(installmentsCount),
        agreedMonthlyAmount: drift.Value(agreedMonthlyAmount),
        contractDate: drift.Value(contractDate.toUtc()), 
        userId: drift.Value(safeUserId), // 🌟 حفظ آي دي الشخص الذي عدّل العقد
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );

    // 2. السحر المحاسبي (تسوية لوحة المراقبة) - حافظنا عليه بالكامل!
    await (db.update(db.installmentsSchedule)
      ..where((t) => t.contractId.equals(id))
      ..where((t) => t.installmentNumber.isBiggerThanValue(installmentsCount)) 
      ..where((t) => t.status.equals('pending')) 
    ).write(
      const InstallmentsScheduleCompanion(
        isDeleted: drift.Value(true), 
        isSynced: drift.Value(false), 
      )
    );

    await syncPendingData();
  }

  // 🌟 دالة إعادة الجدولة الذكية (تنفذ محلياً وترفع للسحابة فوراً)
  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً لإجراء التعديلات المالية.');

    // 1. تنفيذ العملية الجراحية في القاعدة المحلية
    await _localApi.restructureContractSchedule(
      contractId: contractId,
      newRemainingMonths: newRemainingMonths,
      newStartDate: newStartDate.toUtc(), // ضمان تحويل البداية لـ UTC
      userId: safeUserId,
    );

    // 2. تفعيل المزامنة الشبحية لرفع (الأقساط الملغاة + الأقساط الجديدة + تعديل مدة العقد)
    await syncPendingData();
  }

  // ==========================================
  // 🗑️ إدارة سلة المحذوفات للعقود
  // ==========================================
  Future<List<Contract>> getDeletedContracts() => _localApi.getDeletedContracts();

  Future<void> restoreContract(String contractId) async {
    await _localApi.restoreContract(contractId);
    await syncPendingData(); // 🌟 رفع الاستعادة للسحابة
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
    await syncPendingData(); // رفع التعديل للسحابة
  }
  
  // 🌟 أضف هذا السطر في قسم (جدول الاستحقاقات)
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() => _localApi.getAllOverdueSchedules();

  
  // ==========================================
  // 🌟 تعديل قسط فردي
  // ==========================================
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

    
  
  // ==========================================
  // 🌟 تعديل تاريخ العقد فقط
  // ==========================================
  Future<void> updateContractDateOnly({required String id, required DateTime contractDate}) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(
        contractDate: drift.Value(contractDate.toUtc()),
        userId: drift.Value(safeUserId), // 🌟 توثيق التعديل
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), 
      )
    );
    await syncPendingData();
  }
  

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId);
  // 🌟 جلب كل الدفعات لغرفة العمليات (الداشبورد)
  Future<List<PaymentsLedgerData>> getAllPayments() => _localApi.getAllPayments();
  // داخل ErpRepository
  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    final String? safeUserId = currentUserId; // 🌟 1. جلبنا المستخدم الحالي بأمان
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final companionWithUser = entryCompanion.copyWith(userId: drift.Value(safeUserId));
    await _localApi.addLedgerEntry(companionWithUser);
    
    if (entryCompanion.scheduleId.present && entryCompanion.scheduleId.value != null) {
      // 🌟 2. أضفنا safeUserId هنا كمعامل ثالث لإصلاح الخطأ
      await _localApi.updateScheduleStatus(entryCompanion.scheduleId.value!, 'paid', safeUserId);
    }
    
    await syncPendingData(); 
  }

  // ==========================================
  // 🌟 تحديث حالة القسط (من الداشبورد أو الإيصالات)
  // ==========================================
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateScheduleStatus(scheduleId, status, safeUserId);
    await syncPendingData(); 
  }

  // ==========================================
  // 🌟 توثيق إرسال الواتساب
  // ==========================================
  Future<void> markWhatsAppAsSent(String entryId) async { 
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateWhatsAppStatus(entryId, safeUserId);
    await syncPendingData();
  }

  // ==========================================
  // 🌟 تعديل دفعة مالية
  // ==========================================
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
      userId: safeUserId, // 🌟 تمرير المستخدم
    );
    await syncPendingData(); // رفع للسحابة
  }

  // ==========================================
  // 🌟 حذف دفعة لسلة المحذوفات
  // ==========================================
  Future<void> softDeleteLedgerEntry(String entryId) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.softDeleteLedgerEntry(entryId, safeUserId);
    await syncPendingData();
  }

  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() => _localApi.getDeletedLedgerEntries();

  Future<void> restoreLedgerEntry(String entryId) async {
    await _localApi.restoreLedgerEntry(entryId);
    await syncPendingData(); // رفع الاستعادة فوراً للسحابة
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

    // 🌟 الإضافة هنا: تم التغيير من v4 إلى v7 لتتناسق مع النظام الجديد وتزيد السرعة
    final String newId = const Uuid().v7();

    final companionReadyToSave = pricesCompanion.copyWith(
      id: drift.Value(newId),
      userId: drift.Value(safeUserId),
      isSynced: const drift.Value(false),
    );

    // 1. الحفظ المحلي
    await _localApi.savePrices(companionReadyToSave);
    
    // 2. المزامنة والانتظار 🚨
    await syncPendingData(); 
  }
  
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => _localApi.getAllMaterialPricesHistory();
  // أضف هذه الدالة في قسم الإعدادات داخل ErpRepository
  Future<void> softDeleteMaterialPrice(String priceId) async {
    final db = _localApi.database;
    // 1. نقوم بتحديث السطر ليصبح محذوفاً محلياً، ونجعله غير متزامن ليتم رفعه للسحابة
    await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(priceId))).write(
      const MaterialPricesHistoryCompanion(
        isDeleted: drift.Value(true),
        isSynced: drift.Value(false), // إجبار محرك المزامنة على رفعه
      )
    );
    
    // 2. تفعيل محرك المزامنة لرفع التعديل للسحابة
    await syncPendingData();
  }

  // ==========================================
  // 🏢 إدارة المحاضر والشقق
  // ==========================================
  Future<List<Building>> getBuildings() => _localApi.getBuildings();
  Future<List<Apartment>> getAllApartments() => _localApi.getAllApartments();

  Future<void> changeApartmentStatus(String apartmentId, String status) async {
    await _localApi.changeApartmentStatus(apartmentId, status);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }

  Future<void> addBuilding(BuildingsCompanion building) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = building.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addBuilding(companionWithUser);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }

  Future<void> addApartment(ApartmentsCompanion apartment) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = apartment.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addApartment(companionWithUser);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }

  // ==========================================
  // 🏢 تعديل المحاضر والشقق
  // ==========================================
  
  // 1. تعديل المحضر (الاسم والموقع فقط)
  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) async {
    final db = _localApi.database;

    await (db.update(db.buildings)..where((t) => t.id.equals(id))).write(
      BuildingsCompanion(
        name: drift.Value(name),
        location: drift.Value(location),
        // 🌍 التعديل الضروري: UTC
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), // إجبار المزامنة
      )
    );

    await syncPendingData();
  }

  // 2. تعديل الشقة (الرقم، المساحة، والاتجاه)
  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) async {
    final db = _localApi.database;

    await (db.update(db.apartments)..where((t) => t.id.equals(id))).write(
      ApartmentsCompanion(
        apartmentNumber: drift.Value(apartmentNumber),
        area: drift.Value(area),
        directionName: drift.Value(directionName),
        // 🌍 التعديل الضروري: UTC
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false), // إجبار المزامنة
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
      print('🚀 [1] بدأ رفع الملف للعقد: $contractId');
      
      final fileUrl = await _cloudApi.uploadContractFile(
        contractId: contractId, 
        file: file, 
        extension: extension
      );
      print('✅ [2] تم رفع الملف بنجاح! الرابط: $fileUrl');

      final db = _localApi.database;
      await (db.update(db.contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          contractFileUrl: drift.Value(fileUrl),
          userId: drift.Value(safeUserId), // 🌟 حفظ آي دي الشخص الذي رفع الملف
          updatedAt: drift.Value(DateTime.now().toUtc()),
          isSynced: const drift.Value(false),
        )
      );
      print('✅ [3] تم حفظ الرابط في قاعدة البيانات المحلية (Drift).');

      print('⏳[4] جاري مزامنة التعديل مع جدول Supabase...');
      await syncPendingData();
      print('✅ [5] تمت المزامنة بنجاح وانتهت العملية.');

    } catch (e, stacktrace) {
      print('❌❌ خطأ فادح أثناء إرفاق الملف: $e');
      print('🔍 التفاصيل: $stacktrace');
      throw Exception('فشل الإرفاق: $e'); 
    }
  }


  // ==========================================
  // 🛡️ قسم النسخ الاحتياطي والاستعادة (Backup & Restore)
  // ==========================================
  
  // 🌟 تحديث اسم ملف قاعدة البيانات المعتمد في نظامنا
  final String _dbFileName = 'our_home_erp_v10_uuidv7.sqlite';

  /// 1. النسخ الاحتياطي التلقائي (الصامت) - يعمل مرة واحدة كل يوم
  Future<void> autoBackupSilent() async {
    try {
      // 1. تحديد مسار قاعدة البيانات الحالية المخبأة
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) return; // إذا لم تكن موجودة، فلا نفعل شيئاً

      // 2. إنشاء مجلد النسخ التلقائي في "المستندات" (Documents) ليكون آمناً
      final docsDir = await getApplicationDocumentsDirectory();
      final backupFolder = Directory(p.join(docsDir.path, 'OurHomeERP_AutoBackups'));
      
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      // 3. توليد اسم الملف بناءً على اليوم فقط (مثال: AutoBackup_2023-11-05.sqlite)
      // اقتطاع الوقت، والاحتفاظ بالتاريخ فقط
      final String dateOnly = DateTime.now().toIso8601String().split('T')[0];
      final String backupPath = p.join(backupFolder.path, 'AutoBackup_$dateOnly.sqlite');

      // 4. النسخ (إذا كان الملف موجوداً من قبل في نفس اليوم، سيتم استبداله تلقائياً)
      await dbFile.copy(backupPath);
      print('🛡️[Auto-Backup]: تم أخذ نسخة احتياطية بنجاح ليوم $dateOnly');
      
    } catch (e) {
      print('⚠️ [Auto-Backup] فشل النسخ التلقائي: $e');
    }
  }

  /// 2. النسخ الاحتياطي اليدوي (يختاره المستخدم)
  Future<String> backupDatabaseManually() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) {
        return '❌ لا توجد قاعدة بيانات لنسخها بعد.';
      }

      // فتح نافذة منبثقة للمستخدم لاختيار مكان الحفظ (مثل فلاش USB)
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلداً لحفظ النسخة الاحتياطية',
      );

      if (selectedDirectory == null) {
        return '⚠️ تم إلغاء العملية.';
      }

      // توليد اسم يشمل التاريخ والوقت لتجنب استبدال النسخ اليدوية
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = p.join(selectedDirectory, 'ERP_ManualBackup_$timestamp.sqlite');

      await dbFile.copy(backupPath);
      return '✅ تم الحفظ بنجاح في:\n$backupPath';
    } catch (e) {
      return '❌ حدث خطأ أثناء النسخ: $e';
    }
  }

  /// 3. استعادة البيانات (عملية جراحية دقيقة)
  Future<String> restoreDatabase() async {
    try {
      // 1. اختيار ملف النسخة الاحتياطية
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية (sqlite)',
        type: FileType.custom,
        allowedExtensions:['sqlite', 'db'],
      );

      if (result == null || result.files.single.path == null) {
        return '⚠️ تم إلغاء الاستعادة.';
      }

      File backupFile = File(result.files.single.path!);

      // 2. مسار قاعدة البيانات الأصلية
      final supportDir = await getApplicationSupportDirectory();
      final targetDbPath = p.join(supportDir.path, _dbFileName);

      // 3. 🚨 الأمان أولاً: إغلاق قاعدة البيانات لمنع قفل الملف (File Lock)
      await _localApi.database.close();

      // 4. استبدال القاعدة القديمة بالقاعدة المستعادة
      await backupFile.copy(targetDbPath);

      return '✅ تمت استعادة البيانات بنجاح!\n\n🚨 يرجى إغلاق البرنامج بالكامل وإعادة فتحه لتطبيق التغييرات.';
      
    } catch (e) {
      return '❌ فشلت الاستعادة: $e';
    }
  }



  // ==========================================
  // 🗑️ إدارة حذف المحاضر والشقق (مع طبقة الحماية)
  // ==========================================

  // 1. حذف شقة/محل (مع التحقق من الحالة)
  Future<void> softDeleteApartment(String apartmentId) async {
    final db = _localApi.database;
    
    // التحقق المزدوج للأمان
    final apt = await (db.select(db.apartments)..where((t) => t.id.equals(apartmentId))).getSingle();
    if (apt.status != 'available') {
      throw Exception('⚠️ لا يمكن حذف هذه الوحدة لأن حالتها حالياً: ${apt.status}');
    }

    await db.softDeleteApartment(apartmentId);
    await syncPendingData(); // رفع أمر الحذف للسحابة فوراً
  }

  // 2. حذف محضر بالكامل (مع التحقق من الشقق التابعة له)
  Future<void> softDeleteBuilding(String buildingId) async {
    final db = _localApi.database;

    // جلب جميع الشقق والمحلات التابعة لهذا المحضر الفعالة
    final buildingApartments = await (db.select(db.apartments)..where((t) => t.buildingId.equals(buildingId) & t.isDeleted.equals(false))).get();
    
    // التحقق: هل توجد أي شقة أو محل حالته مباع/محجوز؟
    final hasSoldApartments = buildingApartments.any((apt) => apt.status != 'available');
    if (hasSoldApartments) {
      throw Exception('⛔ لا يمكن حذف هذا المحضر لاحتوائه على وحدات مباعة. يرجى حذف الوحدات المتاحة يدوياً إن أردت.');
    }

    await db.softDeleteBuilding(buildingId);
    await syncPendingData(); 
  }

  // 3. استعادة شقة/محل
  Future<void> restoreApartment(String apartmentId) async {
    await _localApi.database.restoreSoftDeletedApartment(apartmentId);
    await syncPendingData();
  }

  // 4. استعادة محضر (سيستعيد معه شققه آلياً بفضل الدالة المحلية)
  Future<void> restoreBuilding(String buildingId) async {
    await _localApi.database.restoreSoftDeletedBuilding(buildingId);
    await syncPendingData();
  }

  // 5. الحذف النهائي (Hard Delete)
  Future<void> forceHardDeleteApartment(String apartmentId) async {
    await _localApi.database.hardDeleteApartment(apartmentId);
  }

  Future<void> forceHardDeleteBuilding(String buildingId) async {
    await _localApi.database.hardDeleteBuilding(buildingId);
  }

  // 6. جلب سلة المحذوفات
  Future<List<Building>> getDeletedBuildings() => _localApi.database.getDeletedBuildings();
  Future<List<Apartment>> getDeletedApartments() => _localApi.database.getDeletedApartments();



  // ==========================================
  // 🛡️ إدارة الصلاحيات والمستخدمين (لوحة تحكم الأدمن)
  // ==========================================
  
  /// جلب كل القوالب (الأدوار) لملء القوائم المنسدلة
  Future<List<AppRole>> getAllRoles() => _localApi.getAllRoles();
  
  /// جلب كل المستخدمين المسجلين في النظام
  Future<List<LocalUser>> getAllUsers() => _localApi.getAllLocalUsers();

  /// إنشاء دور جديد (مثلاً: محاسب متدرب)
  Future<void> createRole({required String name, required String permissionsJson}) async {
    final companion = AppRolesCompanion.insert(
      name: name,
      permissionsJson: drift.Value(permissionsJson),
      isSynced: const drift.Value(false), // ليتم رفعه للسحابة فوراً
    );
    await _localApi.addRole(companion);
    await syncPendingData(); 
  }

  /// تحديث الصلاحيات لدور معين (مثال: إعطاء صلاحية الحذف لكل المدراء)
  Future<void> updateRolePermissions({required String roleId, required String permissionsJson}) async {
    await _localApi.updateRolePermissions(roleId, permissionsJson);
    await syncPendingData();
  }

  /// تعيين دور لمستخدم، أو إعطائه استثناءات، أو تجميد حسابه
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

    // 1. جلب البيانات الخام من قاعدة البيانات المخبأة
    final recentPayments = await _localApi.getRecentPayments(limitPerType);
    final recentContracts = await _localApi.getRecentContracts(limitPerType);
    final recentClients = await _localApi.getRecentClients(limitPerType);

    // 2. تحويل الدفعات إلى نشاطات
    for (var p in recentPayments) {
      allActivities.add(ActivityItem(
        entityId: p.id,
        type: ActivityType.payment,
        title: 'حركة مالية (دفعة/تعديل)',
        description: 'دفعة بقيمة ${p.amountPaid} للعقد ${p.contractId.substring(0, 5)}...', // أخذنا جزء من الآي دي للتوضيح
        timestamp: p.updatedAt,
        userId: p.userId,
      ));
    }

    // 3. تحويل العقود إلى نشاطات (وسنأخذ بعين الاعتبار إذا كان هناك إجراء رادار)
    for (var c in recentContracts) {
      if (c.lastActionDate != null && c.lastActionDate!.difference(c.updatedAt).inMinutes.abs() < 5) {
        // إذا كان وقت الإجراء قريباً جداً من وقت التحديث، نعتبره "إجراء إداري"
        allActivities.add(ActivityItem(
          entityId: c.id,
          type: ActivityType.adminAction,
          title: 'إجراء إداري (ملاحظة)',
          description: c.lastActionNote ?? 'تم تسجيل ملاحظة على العقد',
          timestamp: c.updatedAt,
          userId: c.userId,
        ));
      } else {
        // تحديث أو إضافة عقد عادي
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

    // 4. تحويل العملاء إلى نشاطات
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

    // 5. 🌟 ترتيب جميع النشاطات تنازلياً حسب الوقت (من الأحدث للأقدم)
    allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 6. قص القائمة لتكون بالعدد المطلوب فقط (مثلاً أحدث 30 حدث في كل النظام)
    final trimmedActivities = allActivities.length > finalLimit 
        ? allActivities.sublist(0, finalLimit) 
        : allActivities;

    // 7. 🕵️‍♂️ جلب أسماء المستخدمين بخطوة واحدة ذكية (لتجنب إرهاق القاعدة بالاستعلامات المتكررة)
    final allUsers = await _localApi.getAllLocalUsers();
    final Map<String, String> userNamesMap = {
      for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
    };

    // تعبئة الأسماء
    for (var activity in trimmedActivities) {
      if (userNamesMap.containsKey(activity.userId)) {
        activity.userName = userNamesMap[activity.userId]!;
      }
    }

    return trimmedActivities;
  }
  
}


// نموذج يمثل حركة أو نشاط واحد في النظام
enum ActivityType { payment, contract, client, adminAction }

class ActivityItem {
  final String entityId; // آي دي العنصر (للانتقال لصفحته عند الضغط)
  final ActivityType type; // نوع النشاط (دفعة، عقد، عميل...)
  final String title; // العنوان (مثال: دفعة جديدة، تعديل عقد)
  final String description; // التفاصيل (مثال: مبلغ 500$ للعقد كذا)
  final DateTime timestamp; // وقت حدوث التعديل
  final String userId; // آي دي المستخدم (لجلب اسمه لاحقاً)
  String userName; // اسم المستخدم (سيتم تعبئته لاحقاً)

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