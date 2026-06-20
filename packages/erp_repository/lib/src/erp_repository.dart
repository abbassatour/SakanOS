//packages\erp_repository\lib\src\erp_repository.dart
import 'dart:io';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart'; 
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/backup_repository.dart';
import 'repositories/sync_repository.dart';
import 'repositories/buildings_repository.dart';
import 'repositories/clients_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repositories/sync_repository.dart';
/// المدير الذكي بنظام (Offline-First) والمزامنة الشبحية ثنائية الاتجاه (Push & Pull)
class ErpRepository {
  // ==========================================
  // 🏗️ الدالة البانية والمستودعات الفرعية (Facade Setup)
  // ==========================================
  late final AuthRepository _authRepo;
  late final BackupRepository _backupRepo;
  late final SyncRepository _syncRepo;
  late final ClientsRepository _clientsRepo;
  late final BuildingsRepository _buildingsRepo;
  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient {
    
    // تهيئة المستودعات الفرعية
    _authRepo = AuthRepository(cloudApi: _cloudApi, localApi: _localApi);
    _backupRepo = BackupRepository(localApi: _localApi);
    _syncRepo = SyncRepository(localApi: _localApi, cloudApi: _cloudApi); 

    // 🌟 هيئه هنا ومرر له دالة جلب الـ ID
    _clientsRepo = ClientsRepository(
      localApi: _localApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _buildingsRepo = BuildingsRepository(
      localApi: _localApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    if (currentUserId != null) {
      _startCloudListener();
      _backupRepo.autoBackupSilent(); // 🌟 توجيه النداء للمستودع الفرعي

      _localApi.autoCleanOldDeletedClients();
      _localApi.autoCleanOldDeletedContracts();
      _localApi.autoCleanOldDeletedLedgerEntries();
      _localApi.database.autoCleanOldDeletedBuildingsAndApartments();
    }
  }
  
  // ==========================================
  // 🔐 المصادقة (Authentication Facade)
  // ==========================================
  String? get currentUserId => _authRepo.currentUserId;

  Future<void> signIn({required String email, required String password}) async {
    await _authRepo.signIn(email: email, password: password);
    // الربط الذكي: السحب والاستماع يتم إدارته من الـ Facade
    await pullDataFromCloud();
    _startCloudListener();
  }

  // ==========================================
  // 🌟 المتغيرات والدوال الداخلية (Internal State)
  // ==========================================  
  // ignore: depend_on_referenced_packages
  RealtimeChannel? _pricesChannel;

  void _startCloudListener() {
    _cloudApi.startListeningToCloudChanges(
      onDataChanged: () {
        // ignore: avoid_print
        print('🔄 جاري سحب الأسعار الجديدة من السحابة بسبب تحديث حي...');
        pullDataFromCloud(); 
      },
    );
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _authRepo.signUp(fullName: fullName, email: email, password: password);
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  // ==========================================
  // 🛡️ النسخ الاحتياطي والاستعادة (Backup Facade)
  // ==========================================
  Future<void> autoBackupSilent() => _backupRepo.autoBackupSilent();
  
  Future<String> backupDatabaseManually() => _backupRepo.backupDatabaseManually();
  
  Future<String> restoreDatabase() => _backupRepo.restoreDatabase();

  // ==========================================
  // 🔄 المزامنة (Sync Facade)
  // ==========================================
  Future<String> forceSyncWithCloud() => _syncRepo.forceSyncWithCloud();
  Future<void> pullDataFromCloud() => _syncRepo.pullDataFromCloud();
  Future<void> syncPendingData() => _syncRepo.syncPendingData();

  

  // ==========================================
  // 👥 العملاء (Clients Facade)
  // ==========================================
  Future<List<Client>> getClients() => _clientsRepo.getClients();

  Future<void> addClient({
    required String name,
    required String phone,
    String? nationalId,
  }) =>
      _clientsRepo.addClient(name: name, phone: phone, nationalId: nationalId);

  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) =>
      _clientsRepo.updateClient(
        id: id,
        name: name,
        phone: phone,
        nationalId: nationalId,
      );

  Future<void> deleteClient(String clientId) =>
      _clientsRepo.deleteClient(clientId);

  Future<List<Client>> getDeletedClients() =>
      _clientsRepo.getDeletedClients();

  Future<void> restoreClient(String clientId) =>
      _clientsRepo.restoreClient(clientId);

  Future<void> forceHardDeleteClient(String clientId) =>
      _clientsRepo.forceHardDeleteClient(clientId);

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

  // 🌟 [تم التعديل]: دعم الحقل الجديد للمبلغ (بدون طلب userId من الـ Cubit)
  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount, // 🌟 
  }) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateIndividualSchedule(
      id: scheduleId, 
      newDueDate: newDueDate, 
      notes: notes, 
      expectedAmount: expectedAmount, // 🌟
      userId: safeUserId
    );
    await syncPendingData(); 
  }

  // 🌟 [الدالة الجديدة]: إرسال أمر إضافة الدفعة الموسمية
  Future<void> addCustomSchedule(InstallmentsScheduleCompanion schedule) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final companionWithUser = schedule.copyWith(userId: drift.Value(safeUserId));
    await _localApi.addCustomSchedule(companionWithUser);
    await syncPendingData(); 
  }

  // 🌟 [هذه الدالة التي حُذفت بالخطأ - أعدناها الآن لكي يختفي الخطأ]
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
  // 🏢 إدارة المحاضر والشقق (Buildings Facade)
  // ==========================================
  Future<List<Building>> getBuildings() => _buildingsRepo.getBuildings();
  Future<List<Apartment>> getAllApartments() => _buildingsRepo.getAllApartments();

  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) =>
      _buildingsRepo.addBuilding(
        name: name,
        location: location,
        floorCoeffs: floorCoeffs,
        dirCoeffs: dirCoeffs,
      );

  Future<void> addApartment({
    required String buildingId,
    required String aptNumber,
    required double area,
    required String floorName,
    required String directionName,
    String unitType = 'apartment',
    Map<String, double> customCoeffs = const {},
  }) =>
      _buildingsRepo.addApartment(
        buildingId: buildingId,
        aptNumber: aptNumber,
        area: area,
        floorName: floorName,
        directionName: directionName,
        unitType: unitType,
        customCoeffs: customCoeffs,
      );

  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) =>
      _buildingsRepo.updateBuilding(id: id, name: name, location: location);

  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) =>
      _buildingsRepo.updateApartment(
        id: id,
        apartmentNumber: apartmentNumber,
        area: area,
        directionName: directionName,
      );

  Future<void> changeApartmentStatus(String apartmentId, String status) =>
      _buildingsRepo.changeApartmentStatus(apartmentId, status);

  Future<void> softDeleteApartment(String apartmentId) =>
      _buildingsRepo.softDeleteApartment(apartmentId);

  Future<void> softDeleteBuilding(String buildingId) =>
      _buildingsRepo.softDeleteBuilding(buildingId);

  Future<void> restoreApartment(String apartmentId) =>
      _buildingsRepo.restoreApartment(apartmentId);

  Future<void> restoreBuilding(String buildingId) =>
      _buildingsRepo.restoreBuilding(buildingId);

  Future<void> forceHardDeleteApartment(String apartmentId) =>
      _buildingsRepo.forceHardDeleteApartment(apartmentId);

  Future<void> forceHardDeleteBuilding(String buildingId) =>
      _buildingsRepo.forceHardDeleteBuilding(buildingId);

  Future<List<Building>> getDeletedBuildings() =>
      _buildingsRepo.getDeletedBuildings();

  Future<List<Apartment>> getDeletedApartments() =>
      _buildingsRepo.getDeletedApartments();
  
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
  // 💵 Mappers (Dollar Prices)
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
      id: drift.Value(cloudData['id']),
      effectiveDate: drift.Value(DateTime.parse(cloudData['effective_date']).toUtc()),
      exchangeRate: drift.Value((cloudData['exchange_rate'] as num).toDouble()),
      userId: drift.Value(cloudData['user_id']),
      createdAt: drift.Value(DateTime.parse(cloudData['created_at']).toUtc()),
      updatedAt: drift.Value(DateTime.parse(cloudData['updated_at']).toUtc()),
      isDeleted: drift.Value(cloudData['is_deleted'] == true),
      isSynced: const drift.Value(true),
    );
  }

  // ==========================================
  // 💵 دوال الدولار (Dollar Prices) للواجهات
  // ==========================================
  
  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() => 
      _localApi.watchLatestDollarPrice();

  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() => 
      _localApi.getAllDollarPricesHistory();

  Future<void> saveDollarPrice(DollarPricesHistoryCompanion prices) async {
    final newId = await _localApi.saveDollarPrice(prices);
    try {
      // 🌟 تم تصحيح استعلام Drift والمتغيرات هنا لتطابق ملفك
      final savedData = await (_localApi.database.select(_localApi.database.dollarPricesHistory)
          ..where((t) => t.id.equals(newId))).getSingle();
          
      await _cloudApi.upsertDollarPrice(_mapDollarPriceToCloud(savedData));
      
      await _localApi.syncDollarPrice(savedData.copyWith(isSynced: true).toCompanion(true));
    } catch (e) {
      print('⚠️ الحفظ المحلي تم، لكن الرفع السحابي فشل (بدون إنترنت). سُيرفع لاحقاً.');
    }
  }

  Future<void> softDeleteDollarPrice(String id) async {
    await _localApi.softDeleteDollarPrice(id);
    forceSyncWithCloud();
  }

} // <--- نهاية كلاس ErpRepository

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