//packages\erp_repository\lib\src\erp_repository.dart
import 'dart:io';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'repositories/auth_repository.dart';
import 'repositories/backup_repository.dart';
import 'repositories/sync_repository.dart';
import 'repositories/legal_repository.dart';
import 'repositories/buildings_repository.dart';
import 'repositories/contracts_repository.dart';
import 'repositories/clients_repository.dart';
import 'repositories/schedules_repository.dart';
import 'repositories/payments_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/admin_repository.dart';
import 'repositories/dashboard_repository.dart';
// تأكد من تصدير النماذج لكي تراها الواجهات:
export 'repositories/dashboard_repository.dart'
    show DashboardMetrics, ActivityItem, ActivityType, DashboardTimeFilter;

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
  late final ContractsRepository _contractsRepo;
  late final LegalRepository _legalRepo;
  late final SchedulesRepository _schedulesRepo;
  late final PaymentsRepository _paymentsRepo;
  late final SettingsRepository _settingsRepo;
  late final AdminRepository _adminRepo;
  late final DashboardRepository _dashboardRepo;
  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  }) : _localApi = localStorageApi,
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

    _contractsRepo = ContractsRepository(
      localApi: _localApi,
      cloudApi: _cloudApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _legalRepo = LegalRepository(
      localApi: _localApi,
      cloudApi: _cloudApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _schedulesRepo = SchedulesRepository(
      localApi: _localApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _paymentsRepo = PaymentsRepository(
      localApi: _localApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _settingsRepo = SettingsRepository(
      localApi: _localApi,
      syncRepo: _syncRepo,
      getCurrentUserId: () => currentUserId,
    );

    _adminRepo = AdminRepository(localApi: _localApi, syncRepo: _syncRepo);

    _dashboardRepo = DashboardRepository(localApi: _localApi);

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
    await _authRepo.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  // ==========================================
  // 🛡️ النسخ الاحتياطي والاستعادة (Backup Facade)
  // ==========================================
  Future<void> autoBackupSilent() => _backupRepo.autoBackupSilent();

  Future<String> backupDatabaseManually() =>
      _backupRepo.backupDatabaseManually();

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
  }) => _clientsRepo.updateClient(
    id: id,
    name: name,
    phone: phone,
    nationalId: nationalId,
  );

  Future<void> deleteClient(String clientId) =>
      _clientsRepo.deleteClient(clientId);

  Future<List<Client>> getDeletedClients() => _clientsRepo.getDeletedClients();

  Future<void> restoreClient(String clientId) =>
      _clientsRepo.restoreClient(clientId);

  Future<void> forceHardDeleteClient(String clientId) =>
      _clientsRepo.forceHardDeleteClient(clientId);

  // ==========================================
  // 📄 العقود (Contracts Facade)
  // ==========================================
  Future<List<Contract>> getAllContracts() => _contractsRepo.getAllContracts();
  Future<List<Contract>> getDeletedContracts() =>
      _contractsRepo.getDeletedContracts();
  Future<List<Contract>> getContractsForClient(String clientId) =>
      _contractsRepo.getContractsForClient(clientId);

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
  }) => _contractsRepo.addContract(
    clientId: clientId,
    contractType: contractType,
    details: details,
    apartmentId: apartmentId,
    area: area,
    basePrice: basePrice,
    downPayment: downPayment,
    installmentsCount: installmentsCount,
    guarantorName: guarantorName,
    agreedMonthlyAmount: agreedMonthlyAmount,
    coefficients: coefficients,
    customDate: customDate,
    agreedHandoverDate: agreedHandoverDate,
    gracePeriodMonths: gracePeriodMonths,
    isPenaltyActive: isPenaltyActive,
    penaltyPercentage: penaltyPercentage,
    penaltyIntervalMonths: penaltyIntervalMonths,
    histIron: histIron,
    histCement: histCement,
    histBlock: histBlock,
    histFormwork: histFormwork,
    histAggregates: histAggregates,
    histWorker: histWorker,
    histDollarRate: histDollarRate,
  );

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
  }) => _contractsRepo.updateContract(
    id: id,
    details: details,
    guarantorName: guarantorName,
    installmentsCount: installmentsCount,
    agreedMonthlyAmount: agreedMonthlyAmount,
    contractDate: contractDate,
    isPenaltyActive: isPenaltyActive,
    penaltyPercentage: penaltyPercentage,
    penaltyIntervalMonths: penaltyIntervalMonths,
  );

  Future<void> updateContractDateOnly({
    required String id,
    required DateTime contractDate,
  }) =>
      _contractsRepo.updateContractDateOnly(id: id, contractDate: contractDate);

  Future<void> deleteContract(String contractId, String? apartmentId) =>
      _contractsRepo.deleteContract(contractId, apartmentId);
  Future<void> restoreContract(
    String contractId,
    String? apartmentId,
    bool isHandedOver,
  ) => _contractsRepo.restoreContract(contractId, apartmentId, isHandedOver);
  Future<void> forceHardDeleteContract(String contractId) =>
      _contractsRepo.forceHardDeleteContract(contractId);

  Future<void> markContractAsHandedOver({
    required String contractId,
    required String? apartmentId,
    required DateTime actualHandoverDate,
    String? notes,
  }) => _contractsRepo.markContractAsHandedOver(
    contractId: contractId,
    apartmentId: apartmentId,
    actualHandoverDate: actualHandoverDate,
    notes: notes,
  );

  Future<void> cancelContractHandover({
    required String contractId,
    required String? apartmentId,
  }) => _contractsRepo.cancelContractHandover(
    contractId: contractId,
    apartmentId: apartmentId,
  );

  Future<void> toggleContractCompletion({
    required String contractId,
    required bool isCompleted,
  }) => _contractsRepo.toggleContractCompletion(
    contractId: contractId,
    isCompleted: isCompleted,
  );

  Future<void> attachContractFile(
    String contractId,
    File file,
    String extension,
  ) => _contractsRepo.attachContractFile(contractId, file, extension);

  Future<void> markContractActionTaken({
    required String contractId,
    required String note,
  }) => _contractsRepo.markContractActionTaken(
    contractId: contractId,
    note: note,
  );

  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) => _contractsRepo.restructureContractSchedule(
    contractId: contractId,
    newRemainingMonths: newRemainingMonths,
    newStartDate: newStartDate,
  );

  // ==========================================
  // 📅 جدول الاستحقاقات (Schedules Facade)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(
    String contractId,
  ) => _schedulesRepo.getContractSchedule(contractId);
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() =>
      _schedulesRepo.getAllOverdueSchedules();

  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String scheduleId,
    required String actionType,
    required DateTime nextDueDate,
  }) => _schedulesRepo.handleRollingCheckpoint(
    contractId: contractId,
    scheduleId: scheduleId,
    actionType: actionType,
    nextDueDate: nextDueDate,
  );

  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount,
  }) => _schedulesRepo.updateIndividualSchedule(
    scheduleId: scheduleId,
    newDueDate: newDueDate,
    notes: notes,
    expectedAmount: expectedAmount,
  );

  Future<void> updateScheduleStatus(String scheduleId, String status) =>
      _schedulesRepo.updateScheduleStatus(scheduleId, status);

  Future<void> addCustomSchedule({
    required String contractId,
    required DateTime dueDate,
    required String notes,
    required double expectedAmount,
  }) => _schedulesRepo.addCustomSchedule(
    contractId: contractId,
    dueDate: dueDate,
    notes: notes,
    expectedAmount: expectedAmount,
  );

  // ==========================================
  // 💰 المدفوعات (Payments Facade)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) =>
      _paymentsRepo.getContractLedger(contractId);
  Future<List<PaymentsLedgerData>> getAllPayments() =>
      _paymentsRepo.getAllPayments();
  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() =>
      _paymentsRepo.getDeletedLedgerEntries();

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
  }) => _paymentsRepo.addLedgerEntry(
    contractId: contractId,
    amountPaid: amountPaid,
    meterPriceAtPayment: meterPriceAtPayment,
    convertedMeters: convertedMeters,
    pricesSnapshotJson: pricesSnapshotJson,
    discountPercentage: discountPercentage,
    scheduleId: scheduleId,
    customDate: customDate,
    histDollarRate: histDollarRate,
    histIron: histIron,
    histCement: histCement,
    histBlock: histBlock,
    histFormwork: histFormwork,
    histAggregates: histAggregates,
    histWorker: histWorker,
  );

  Future<void> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
  }) => _paymentsRepo.updateLedgerEntryAmount(
    entryId: entryId,
    newAmount: newAmount,
    newDiscount: newDiscount,
    newConvertedMeters: newConvertedMeters,
  );

  Future<void> softDeleteLedgerEntry(String entryId) =>
      _paymentsRepo.softDeleteLedgerEntry(entryId);
  Future<void> restoreLedgerEntry(String entryId) =>
      _paymentsRepo.restoreLedgerEntry(entryId);
  Future<void> forceHardDeleteLedgerEntry(String entryId) =>
      _paymentsRepo.forceHardDeleteLedgerEntry(entryId);
  Future<void> markWhatsAppAsSent(String entryId) =>
      _paymentsRepo.markWhatsAppAsSent(entryId);

  // ==========================================
  // ⚙️ الإعدادات والأسعار (Settings & Prices Facade)
  // ==========================================
  Stream<MaterialPricesHistoryData?> watchLatestPrices() =>
      _settingsRepo.watchLatestPrices();
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() =>
      _settingsRepo.getAllMaterialPricesHistory();

  Future<void> saveMaterialPrices({
    required double iron,
    required double cement,
    required double block15,
    required double formwork,
    required double aggregates,
    required double worker,
    DateTime? effectiveDate,
  }) => _settingsRepo.saveMaterialPrices(
    iron: iron,
    cement: cement,
    block15: block15,
    formwork: formwork,
    aggregates: aggregates,
    worker: worker,
    effectiveDate: effectiveDate,
  );

  Future<void> softDeleteMaterialPrice(String priceId) =>
      _settingsRepo.softDeleteMaterialPrice(priceId);

  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() =>
      _settingsRepo.watchLatestDollarPrice();
  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() =>
      _settingsRepo.getAllDollarPricesHistory();

  Future<void> saveDollarPrice({
    required double exchangeRate,
    DateTime? effectiveDate,
  }) => _settingsRepo.saveDollarPrice(
    exchangeRate: exchangeRate,
    effectiveDate: effectiveDate,
  );

  Future<void> softDeleteDollarPrice(String id) =>
      _settingsRepo.softDeleteDollarPrice(id);

  Future<MaterialPricesHistoryData?> getLatestPrices() =>
      _settingsRepo.getLatestPrices();

  // ==========================================
  // 🏢 إدارة المحاضر والشقق (Buildings Facade)
  // ==========================================
  Future<List<Building>> getBuildings() => _buildingsRepo.getBuildings();
  Future<List<Apartment>> getAllApartments() =>
      _buildingsRepo.getAllApartments();

  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) => _buildingsRepo.addBuilding(
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
  }) => _buildingsRepo.addApartment(
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
  }) => _buildingsRepo.updateBuilding(id: id, name: name, location: location);

  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) => _buildingsRepo.updateApartment(
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
            print(
              '🔥 السحابة تقول: تم تغيير الأسعار! جاري التحديث التلقائي...',
            );
            pullDataFromCloud();
          },
        )
        .subscribe();
  }

  // ==========================================
  // 🌟 إرفاق ملف Word للعقد
  // ==========================================
  Future<void> attachFileToContract(
    String contractId,
    File file,
    String extension,
  ) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    try {
      final fileUrl = await _cloudApi.uploadContractFile(
        contractId: contractId,
        file: file,
        extension: extension,
      );

      final db = _localApi.database;
      await (db.update(
        db.contracts,
      )..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          contractFileUrl: drift.Value(fileUrl),
          userId: drift.Value(safeUserId),
          updatedAt: drift.Value(DateTime.now().toUtc()),
          isSynced: const drift.Value(false),
        ),
      );
      await syncPendingData();
    } catch (e, stacktrace) {
      print('❌❌ خطأ فادح أثناء إرفاق الملف: $e');
      print('🔍 التفاصيل: $stacktrace');
      throw Exception('فشل الإرفاق: $e');
    }
  }

  // ==========================================
  // 🛡️ الإدارة والمستخدمين (Admin Facade)
  // ==========================================
  Future<List<AppRole>> getAllRoles() => _adminRepo.getAllRoles();
  Future<List<LocalUser>> getAllUsers() => _adminRepo.getAllUsers();
  Future<LocalUser?> getLocalUserById(String id) =>
      _adminRepo.getLocalUserById(id);
  Future<AppRole?> getRoleById(String id) => _adminRepo.getRoleById(id);

  Future<void> createRole({
    required String name,
    required List<String> permissions,
  }) => _adminRepo.createRole(name: name, permissions: permissions);

  Future<void> updateRolePermissions({
    required String roleId,
    required List<String> permissions,
  }) => _adminRepo.updateRolePermissions(
    roleId: roleId,
    permissions: permissions,
  );

  Future<void> updateUserRoleAndPermissions({
    required String userId,
    required String roleId,
    List<String>? extraPermissions,
    List<String>? revokedPermissions,
    bool? isActive,
  }) => _adminRepo.updateUserRoleAndPermissions(
    userId: userId,
    roleId: roleId,
    extraPermissions: extraPermissions,
    revokedPermissions: revokedPermissions,
    isActive: isActive,
  );

  // ==========================================
  // ⚖️ الإجراءات القانونية (Legal Facade)
  // ==========================================
  Future<List<LegalAction>> getLegalActionsForContract(String contractId) =>
      _legalRepo.getLegalActionsForContract(contractId);

  Future<List<LegalAction>> getAllLegalActions() =>
      _legalRepo.getAllLegalActions();

  Future<List<LegalActionAttachment>> getAllLegalActionAttachments() =>
      _legalRepo.getAllLegalActionAttachments();

  Future<void> addLegalAction({
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) => _legalRepo.addLegalAction(
    contractId: contractId,
    actionType: actionType,
    actionDate: actionDate,
    notes: notes,
  );

  Future<void> updateLegalAction({
    required String actionId,
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) => _legalRepo.updateLegalAction(
    actionId: actionId,
    contractId: contractId,
    actionType: actionType,
    actionDate: actionDate,
    notes: notes,
  );

  Future<void> deleteLegalAction(String actionId) =>
      _legalRepo.deleteLegalAction(actionId);

  Future<void> attachFileToLegalAction({
    required String actionId,
    required File file,
    required String extension,
    required String originalFileName,
  }) => _legalRepo.attachFileToLegalAction(
    actionId: actionId,
    file: file,
    extension: extension,
    originalFileName: originalFileName,
  );

  Future<void> deleteLegalActionAttachment(String attachmentId) =>
      _legalRepo.deleteLegalActionAttachment(attachmentId);

  // ==========================================
  // 📊 لوحة التحكم والإحصائيات (Dashboard Facade)
  // ==========================================
  Future<DashboardMetrics> getDashboardMetrics({
    required DashboardTimeFilter timeFilter,
    required DateTime refDate,
  }) => _dashboardRepo.getDashboardMetrics(
    timeFilter: timeFilter,
    refDate: refDate,
  );
  // ==========================================
  // 🧹 تنظيف الذاكرة وإغلاق القنوات (Dispose)
  // ==========================================
  void dispose() {
    _pricesChannel?.unsubscribe();
  }
}
