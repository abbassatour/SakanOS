//packages\local_storage_api\lib\src\local_storage_api.dart
import 'database.dart';
export 'database.dart';


class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;
  AppDatabase get database => _db;

  // ==========================================
  // 🏢 المحاضر (Buildings)
  // ==========================================
  Future<List<Building>> getBuildings() => _db.getActiveBuildings();
  Future<String> addBuilding(BuildingsCompanion building) => _db.insertBuilding(building);

  // ==========================================
  // 🚪 الشقق (Apartments)
  // ==========================================
  Future<List<Apartment>> getAllApartments() => _db.getAllActiveApartments();
  Future<List<Apartment>> getApartmentsByBuilding(String buildingId) => _db.getApartmentsForBuilding(buildingId);
  Future<String> addApartment(ApartmentsCompanion apartment) => _db.insertApartment(apartment);
  // استبدل الدالة القديمة لتغيير حالة الشقة بهذه:
  Future<int> changeApartmentStatus(String id, String status, String userId) => 
      _db.updateApartmentStatus(id, status, userId);

  // ==========================================
  // 👥 العملاء
  // ==========================================
  Future<List<Client>> getClients() => _db.getActiveClients();
  Future<String> addClient(ClientsCompanion client) => _db.insertClient(client);
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  Future<void> deleteClient(String id, String userId) => _db.softDeleteClient(id, userId);

  // ==========================================
  // 📄 العقود
  // ==========================================
  Future<List<Contract>> getAllContracts() => _db.getActiveContracts();
  Future<void> addContractWithSchedules(ContractsCompanion contract, int count, DateTime start, String userId, String contractType) => 
      _db.insertContractWithSchedules(contract, count, start, userId, contractType);
  Future<void> deleteContract(String id, String userId) => _db.softDeleteContract(id, userId);
  Future<int> markContractActionTaken(String contractId, String note, String userId) => 
      _db.markContractActionTaken(contractId, note, userId);


    // 🌟 دالة تسليم الشقة
  Future<void> markContractAsHandedOver(String contractId, String? apartmentId, DateTime actualDate, String? notes, String userId) => 
      _db.markContractAsHandedOver(contractId, apartmentId, actualDate, notes, userId);


  Future<void> cancelContractHandover(String contractId, String? apartmentId, String userId) => 
      _db.cancelContractHandover(contractId, apartmentId, userId);
      

      // 🌟 دالة إغلاق العقد
  Future<int> toggleContractCompletion(String contractId, bool isCompleted, String userId) => 
      _db.toggleContractCompletion(contractId, isCompleted, userId);


  
      
  
      
  // ==========================================
  // 💰 الأقساط
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _db.getLedgerForContract(contractId);
  Future<String> addLedgerEntry(PaymentsLedgerCompanion entry) => _db.insertLedgerEntry(entry);
  Future<int> updateWhatsAppStatus(String entryId, String userId) => _db.markWhatsAppAsSent(entryId, userId);
  Future<List<PaymentsLedgerData>> getAllPayments() => _db.getAllActivePayments();


  // ==========================================
  // ⚙️ الإعدادات والأسعار
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _db.getLatestPrices();
  Future<String> savePrices(MaterialPricesHistoryCompanion prices) => _db.insertMaterialPriceRecord(prices);
  Stream<MaterialPricesHistoryData?> watchLatestPrices() => _db.watchLatestPrices();
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => _db.getAllMaterialPricesHistory();
  
  // ==========================================
  // 📅 جدول الاستحقاقات (Installments Schedule)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => _db.getScheduleForContract(contractId);
  Future<int> updateScheduleStatus(String id, String status, String userId) => 
      _db.updateScheduleStatus(id, status, userId);
  Future<int> deleteScheduleEntry(String id) => _db.softDeleteScheduleEntry(id);
  // 🌟 أضف هذا السطر في قسم (جدول الاستحقاقات)
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() => _db.getAllOverdueSchedules();
  // 🌟 السطر الجديد
  Future<int> updateIndividualSchedule(String id, DateTime newDueDate, String? notes, String userId) => 
      _db.updateIndividualSchedule(id, newDueDate, notes, userId);
  Future<void> restructureContractSchedule({required String contractId, required int newRemainingMonths, required DateTime newStartDate, required String userId}) =>
      _db.restructureContractSchedule(contractId: contractId, newRemainingMonths: newRemainingMonths, newStartDate: newStartDate, userId: userId);
Future<void> handleRollingCheckpoint(String contractId, String scheduleId, String action, DateTime nextDate, String userId) =>
      _db.handleRollingCheckpoint(contractId: contractId, currentScheduleId: scheduleId, actionType: action, nextDueDate: nextDate, userId: userId);

  // ==========================================
  // 🧹 فرمتة القاعدة
  // ==========================================
  Future<void> formatDatabase() => _db.clearAllData();

  // ==========================================
  // ☁️ دوال الحقن السحابي (Cloud Sync Upserts)
  // ==========================================
  Future<void> syncClient(ClientsCompanion c) => _db.into(_db.clients).insertOnConflictUpdate(c);
  Future<void> syncContract(ContractsCompanion c) => _db.into(_db.contracts).insertOnConflictUpdate(c);
  Future<void> syncPrice(MaterialPricesHistoryCompanion c) => _db.into(_db.materialPricesHistory).insertOnConflictUpdate(c);
  Future<void> syncSchedule(InstallmentsScheduleCompanion c) => _db.into(_db.installmentsSchedule).insertOnConflictUpdate(c);
  Future<void> syncPayment(PaymentsLedgerCompanion c) => _db.into(_db.paymentsLedger).insertOnConflictUpdate(c);
  
  Future<void> syncBuilding(BuildingsCompanion c) => _db.into(_db.buildings).insertOnConflictUpdate(c);
  Future<void> syncApartment(ApartmentsCompanion c) => _db.into(_db.apartments).insertOnConflictUpdate(c);


  // ==========================================
  // 🗑️ دوال سلة المحذوفات (العملاء)
  // ==========================================
  Future<List<Client>> getDeletedClients() => _db.getDeletedClients();
  Future<void> restoreClient(String id, String userId) => _db.restoreSoftDeletedClient(id, userId);
  Future<void> hardDeleteClientLocal(String id) => _db.hardDeleteClient(id);
  Future<void> autoCleanOldDeletedClients() => _db.autoCleanOldDeletedClients();
  
  // ==========================================
  // 🗑️ دوال سلة المحذوفات (العقود)
  // ==========================================
  Future<List<Contract>> getDeletedContracts() => _db.getDeletedContracts();
  Future<void> restoreContract(String id, String userId) => _db.restoreSoftDeletedContract(id, userId);
  Future<void> hardDeleteContractLocal(String id) => _db.hardDeleteContract(id);
  Future<void> autoCleanOldDeletedContracts() => _db.autoCleanOldDeletedContracts();
  


  // ==========================================
  // 💰 دوال التعديل وسلة محذوفات المدفوعات
  // ==========================================
    Future<int> updateLedgerEntryAmount({
    required String entryId, 
    required double newAmount, 
    required double newDiscount, 
    required double newConvertedMeters, 
    required String userId, // 🌟
  }) => _db.updateLedgerEntryAmount(
      entryId: entryId, 
      newAmount: newAmount, 
      newDiscount: newDiscount, 
      newConvertedMeters: newConvertedMeters, 
      userId: userId
  );


  Future<int> softDeleteLedgerEntry(String id, String userId) => _db.softDeleteLedgerEntry(id, userId);
  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() => _db.getDeletedLedgerEntries();
  Future<int> restoreLedgerEntry(String id, String userId) => _db.restoreLedgerEntry(id, userId);
  Future<int> forceHardDeleteLedgerEntry(String id) => _db.forceHardDeleteLedgerEntry(id);
  Future<void> autoCleanOldDeletedLedgerEntries() => _db.autoCleanOldDeletedLedgerEntries();


  // ==========================================
  // 🛡️ الصلاحيات والمستخدمين (Roles & Users)
  // ==========================================
  Future<List<AppRole>> getAllRoles() => _db.getAllRoles();
  Future<List<LocalUser>> getAllLocalUsers() => _db.getAllLocalUsers();
  
  Future<String> addRole(AppRolesCompanion role) => _db.insertRole(role);
  Future<int> updateRolePermissions(String roleId, String newPermissionsJson) => 
      _db.updateRolePermissions(roleId, newPermissionsJson);
      
  Future<int> updateUserRoleAndPermissions({
    required String userId,
    required String roleId,
    String? extraPermissionsJson,
    String? revokedPermissionsJson,
    bool? isActive,
  }) => _db.updateUserRoleAndPermissions(
    userId: userId, 
    roleId: roleId, 
    extraPermissionsJson: extraPermissionsJson, 
    revokedPermissionsJson: revokedPermissionsJson, 
    isActive: isActive
  );

  // --- دوال الحقن السحابي الخاصة بالصلاحيات ---
  Future<void> syncAppRole(AppRolesCompanion r) => _db.syncAppRole(r);
  Future<void> syncLocalUser(LocalUsersCompanion u) => _db.syncLocalUser(u);
  

  Future<LocalUser?> getLocalUserById(String id) => _db.getLocalUserById(id);
  Future<AppRole?> getRoleById(String id) => _db.getRoleById(id);


  // ==========================================
  // ⚖️ الإجراءات القانونية
  // ==========================================
  Future<List<LegalAction>> getLegalActionsForContract(String contractId) => _db.getLegalActionsForContract(contractId);
  
  Future<String> addLegalAction(LegalActionsCompanion action) => _db.insertLegalAction(action);
  
  // 🌟 سطر التعديل
  Future<void> updateLegalAction(LegalActionsCompanion action) => _db.updateLegalAction(action);
  
  Future<int> deleteLegalAction(String id, String userId) => _db.softDeleteLegalAction(id, userId);

  // ==========================================
  // 🕒 دوال تتبع النشاطات (Activity Log)
  // ==========================================
  Future<List<PaymentsLedgerData>> getRecentPayments(int limit) => _db.getRecentPayments(limit);
  Future<List<Contract>> getRecentContracts(int limit) => _db.getRecentContracts(limit);
  Future<List<Client>> getRecentClients(int limit) => _db.getRecentClients(limit);

  // ==========================================
  // 📎 المرفقات القانونية
  // ==========================================
  Future<List<LegalActionAttachment>> getAttachmentsForAction(String actionId) => 
      _db.getAttachmentsForAction(actionId);
      
  Future<String> addLegalActionAttachment(LegalActionAttachmentsCompanion attachment) => 
      _db.insertLegalActionAttachment(attachment);
      
  Future<int> deleteLegalActionAttachment(String id, String userId) => 
      _db.softDeleteLegalActionAttachment(id, userId);
      
  Future<List<LegalAction>> getAllLegalActions() => _db.getAllLegalActions();
  Future<List<LegalActionAttachment>> getAllLegalActionAttachments() => _db.getAllLegalActionAttachments();

  
  // ==========================================
  // 💵 أسعار الدولار
  // ==========================================
  Future<DollarPricesHistoryData?> getLatestDollarPrice() => _db.getLatestDollarPrice();
  Future<String> saveDollarPrice(DollarPricesHistoryCompanion prices) => _db.insertDollarPriceRecord(prices);
  Stream<DollarPricesHistoryData?> watchLatestDollarPrice() => _db.watchLatestDollarPrice();
  Future<List<DollarPricesHistoryData>> getAllDollarPricesHistory() => _db.getAllDollarPricesHistory();
  
  // ولا تنسَ إضافتها في قسم Rights / Sync Upserts في نفس الملف:
  Future<void> syncDollarPrice(DollarPricesHistoryCompanion c) => _db.syncDollarPrice(c);
  Future<int> softDeleteDollarPrice(String id) => _db.softDeleteDollarPrice(id);
  
}
