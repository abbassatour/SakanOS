//packages\local_storage_api\lib\src\database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

// ==========================================
// 1. جدول العملاء (الفريق الثاني)
// =========================================
@TableIndex(name: 'idx_clients_sync', columns: {#isDeleted, #updatedAt})

class Clients extends Table {
  // 🌟 تم التحويل إلى v7 لتحسين الأداء وتسريع الفهرسة
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text()(); 
  TextColumn get nationalId => text().nullable()(); 
  
  // 🌟 من قام بإضافة هذا العميل؟ (حقل التدقيق المالي)
  TextColumn get userId => text()(); 

  // 🌍[تعديل التوقيت]: تم استبدال currentDateAndTime (الذي يأخذ التوقيت المحلي)
  // بـ clientDefault(() => DateTime.now().toUtc()) لضمان حفظ الوقت بالتوقيت العالمي
  // لتجنب أي مشاكل عند المزامنة مع السحابة أو عند فتح التطبيق في دول مختلفة
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 🏢 2. جدول المحاضر (Buildings) - يحتوي على القوالب العامة
// ==========================================
@TableIndex(name: 'idx_buildings_sync', columns: {#isDeleted, #updatedAt})

class Buildings extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get name => text()(); // مثال: محضر النسيم
  TextColumn get location => text().nullable()(); // مثال: مشروع الأوقاف
  
  // 🌟 قوالب النسب المئوية العامة (تُحفظ كـ JSON)
  TextColumn get floorCoefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get directionCoefficients => text().withDefault(const Constant('{}'))(); 
  
  // حقول المزامنة (جاهزة للمستقبل، لكننا لن نستخدمها الآن)
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 🌍[تعديل التوقيت]: الحفظ بـ UTC لتوحيد الزمن في كامل النظام
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 🚪 3. جدول الشقق (Apartments) - يحتوي على الخصائص المحددة
// ==========================================
@TableIndex(name: 'idx_apartments_sync', columns: {#isDeleted, #updatedAt, #buildingId})
class Apartments extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get buildingId => text().references(Buildings, #id)(); // 🌟 الارتباط بالمحضر
  
    // 🌟 السطر الجديد: لتحديد هل هي شقة أم محل تجاري
  TextColumn get unitType => text().withDefault(const Constant('apartment'))(); 
  
  
  TextColumn get apartmentNumber => text()(); // مثال: 101 أو A1
  RealColumn get area => real()(); 
  
  // 🌟 الخصائص التي ستبحث في قوالب المحضر لمعرفة نسبتها
  TextColumn get floorName => text()(); // مثال: "الطابق الثاني"
  TextColumn get directionName => text()(); // مثال: "جنوبي"
  
  // 🌟 نسب مئوية خاصة بهذه الشقة فقط (تُحفظ كـ JSON)
  TextColumn get customCoefficients => text().withDefault(const Constant('{}'))(); 
  
  // حالة الشقة: متاحة، مباعة، محجوزة
  TextColumn get status => text().withDefault(const Constant('available'))(); 
  
  // حقول المزامنة
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 🌍[تعديل التوقيت]: حفظ التواريخ دائماً كـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 4. جدول العقود (Contracts)
// ==========================================
@TableIndex(name: 'idx_contracts_sync', columns: {#isDeleted, #updatedAt, #clientId})
class Contracts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get clientId => text().references(Clients, #id)(); 
  TextColumn get apartmentId => text().nullable().references(Apartments, #id)(); 
  TextColumn get apartmentDetails => text().withDefault(const Constant('أسهم/غير مخصص'))();

  TextColumn get contractType => text().withDefault(const Constant('لاحق التخصص'))(); 
  RealColumn get totalArea => real()(); 
  RealColumn get baseMeterPriceAtSigning => real()(); 
  
  // 🌟 [الإضافة الجديدة]: الدفعة الأولى (المقدمة) المرفقة مع العقد
  RealColumn get downPayment => real().withDefault(const Constant(0.0))(); 


  
  // 🌟 [الإضافات الجديدة]: إدارة تسليم الشقة (Handover Management)
  BoolColumn get isHandedOver => boolean().withDefault(const Constant(false))(); 
  DateTimeColumn get agreedHandoverDate => dateTime().nullable()(); // الموعد المتفق عليه بالعقد
  DateTimeColumn get actualHandoverDate => dateTime().nullable()(); // موعد التسليم الفعلي
  IntColumn get gracePeriodMonths => integer().withDefault(const Constant(0))(); // فترة السماح بالأشهر
  TextColumn get handoverNotes => text().nullable()(); // ملاحظات الاستلام
  IntColumn get installmentsCount => integer().withDefault(const Constant(48))(); 
  TextColumn get coefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get guarantorName => text()();
  TextColumn get contractFileUrl => text().nullable()();
  
  RealColumn get agreedMonthlyAmount => real().withDefault(const Constant(0.0))(); 
  
  TextColumn get userId => text()();
  
  DateTimeColumn get contractDate => dateTime()(); 
  
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))(); 
  
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  DateTimeColumn get lastActionDate => dateTime().nullable()();
  TextColumn get lastActionNote => text().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 5. جدول سجل أسعار المواد (Material Prices History)
// ==========================================
@TableIndex(name: 'idx_prices_sync', columns: {#isDeleted, #updatedAt, #effectiveDate})
class MaterialPricesHistory extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  
  // 🌍 [تعديل التوقيت]: سريان مفعول السعر يجب أن يسجل كـ UTC
  DateTimeColumn get effectiveDate => dateTime().clientDefault(() => DateTime.now().toUtc())(); 
  
  RealColumn get ironPrice => real()(); 
  RealColumn get cementPrice => real()(); 
  RealColumn get block15Price => real()(); 
  RealColumn get formworkAndPouringWages => real()(); 
  RealColumn get aggregateMaterialsPrice => real()(); 
  RealColumn get ordinaryWorkerWage => real()(); 

  // 🌟 من المدير الذي عدل الأسعار في هذا اليوم؟
  TextColumn get userId => text()();

  // 🌍 [تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 6. جدول الاستحقاقات (Installments Schedule) - ما يجب دفعه
// ==========================================
@TableIndex(name: 'idx_schedules_sync', columns: {#isDeleted, #updatedAt, #contractId})

// 1. في جدول الأقساط، أضف السطر الخاص بالملاحظات:
class InstallmentsSchedule extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  IntColumn get installmentNumber => integer()(); 
  DateTimeColumn get dueDate => dateTime()(); 
  TextColumn get status => text().withDefault(const Constant('pending'))();
  
  // 🌟 السطر الجديد: حقل الملاحظات
  TextColumn get notes => text().nullable()(); 
  
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}


// ==========================================
// 7. الأقساط للمدفوعات (Payments Ledger) 🚨 الأهم!
// ==========================================
// هذا الجدول يسجل "الأموال الحقيقية" والأمتار التي اشترتها لحظة الدفع
@TableIndex(name: 'idx_payments_sync', columns: {#isDeleted, #updatedAt, #contractId})

class PaymentsLedger extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  TextColumn get scheduleId => text().nullable().references(InstallmentsSchedule, #id)();
  
  // 🌍 ملاحظة: يجب تمريره من الـ Logic كـ UTC (مثلاً الدفع تم الآن، فنأخذ الآن بالتوقيت العالمي)
  DateTimeColumn get paymentDate => dateTime()(); 
  
  RealColumn get amountPaid => real()(); 
  
  // 🌟 جوهر النظام: تجميد السعر والأمتار في لحظة الدفع لكي لا تتغير لاحقاً
  RealColumn get meterPriceAtPayment => real()(); 
  RealColumn get convertedMeters => real()(); 

   // 🌟 [السطر الجديد]: لقطة الأسعار التاريخية لحظة الدفع (تُحفظ كـ JSON)
  TextColumn get pricesSnapshot => text().withDefault(const Constant('{}'))(); 

  RealColumn get fees => real().withDefault(const Constant(0))(); 
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  
  // 🌟 من المحاسب الذي استلم هذا المبلغ وقبضه؟ (مهم جداً للتدقيق المالي)
  TextColumn get userId => text()();

  // 🌍 [تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); 

  @override
  Set<Column> get primaryKey => {id};

  
}



// ==========================================
// 🛡️ 8. جدول الأدوار/القوالب (App Roles)
// ==========================================
@TableIndex(name: 'idx_roles_sync', columns: {#isDeleted, #updatedAt})
class AppRoles extends Table {
  // 🌟 تم التحويل إلى v7
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  
  TextColumn get name => text()(); // اسم الدور: مدير، محاسب
  
  // 🌟 مصفوفة الصلاحيات (تحفظ كنص JSON)
  TextColumn get permissionsJson => text().withDefault(const Constant('[]'))();
  
  BoolColumn get isSystemRole => boolean().withDefault(const Constant(false))();

  // 🌍 حقول المزامنة (Offline First)
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 🧑‍💼 9. جدول المستخدمين المحلي (Local Users)
// ==========================================
@TableIndex(name: 'idx_users_sync', columns: {#isDeleted, #updatedAt})
class LocalUsers extends Table {
  // ⚠️ ملاحظة هامة: هذا الـ ID يأتي من Supabase Auth، لذلك لا نستخدم هنا clientDefault
  // بل سيتم إدخاله برمجياً عند المزامنة
  TextColumn get id => text()(); 
  
  TextColumn get fullName => text().nullable()();
  TextColumn get email => text()();
  
  // 🌟 الارتباط بالدور (قالب الصلاحيات)
  TextColumn get roleId => text().nullable().references(AppRoles, #id)();
  
  // 🌟 الاستثناءات المخصصة (Extra & Revoked) تُحفظ كـ JSON
  TextColumn get extraPermissionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get revokedPermissionsJson => text().withDefault(const Constant('[]'))();
  
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // 🌍 حقول المزامنة
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// ==========================================
// التكوين الرئيسي لقاعدة البيانات
// ==========================================
// ==========================================

@DriftDatabase(tables:[
  Clients, 
  Contracts, 
  Buildings,      // 🌟 أضفناه
  Apartments,     // 🌟 أضفناه
  MaterialPricesHistory, 
  InstallmentsSchedule, 
  PaymentsLedger,
  AppRoles,       // 🌟 تمت الإضافة
  LocalUsers      // 🌟 تمت الإضافة
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // سنبقيها 1 ونقوم بحذف القاعدة القديمة من الجهاز يدوياً

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
  
  /// حذف عميل (يحذف معه آلياً: عقوده، أقساطه، ومدفوعاته)
  Future<void> softDeleteClient(String clientId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. حذف العميل
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // 2. حذف توابعه (العقود والأقساط والدفعات) مع توثيق من قام بالحذف
      final clientContracts = await (select(contracts)..where((t) => t.clientId.equals(clientId))).get();
      for (final contract in clientContracts) {
        await (update(contracts)..where((t) => t.id.equals(contract.id))).write(
          ContractsCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
        );
        await (update(installmentsSchedule)..where((t) => t.contractId.equals(contract.id))).write(
          InstallmentsScheduleCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
        );
        await (update(paymentsLedger)..where((t) => t.contractId.equals(contract.id))).write(
          PaymentsLedgerCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
        );
      }
    });
  }




  // ==========================================
  // --- استعلامات العقود ---
  // ==========================================


  // ==========================================
  // 🎯 تسجيل إجراء إداري على العقد (لإسكات الرادار)
  // ==========================================
  Future<int> markContractActionTaken(String contractId, String note, String userId) {
    final nowUtc = DateTime.now().toUtc();
    return (update(contracts)..where((t) => t.id.equals(contractId))).write(
      ContractsCompanion(
        lastActionDate: Value(nowUtc),
        lastActionNote: Value(note),
        userId: Value(userId), // 🌟 حفظ آي دي الشخص الذي سجل الملاحظة
        updatedAt: Value(nowUtc), 
        isSynced: const Value(false)
      )
    );
  }

  // ==========================================
  // 🎯 تسجيل تسليم الشقة للعميل (للعقود المتخصصة)
  // ==========================================
  Future<int> markContractAsHandedOver(String contractId, DateTime actualDate, String? notes, String userId) {
    final nowUtc = DateTime.now().toUtc();
    return (update(contracts)..where((t) => t.id.equals(contractId))).write(
      ContractsCompanion(
        isHandedOver: const Value(true),
        actualHandoverDate: Value(actualDate.toUtc()), // 🌍 حفظ التاريخ الفعلي بـ UTC
        handoverNotes: Value(notes),
        userId: Value(userId), 
        updatedAt: Value(nowUtc), 
        isSynced: const Value(false) 
      )
    );
  }
  

  // ==========================================
  // --- إضافة عقد مع قسط البداية فقط (نظام المدة المفتوحة) ---
  // ==========================================
  Future<void> insertContractWithSchedules(
    ContractsCompanion contract, 
    int installmentsCount, 
    DateTime startDate, 
    String userId,
    String contractType, 
  ) async {
    return transaction(() async {
      // 1. إضافة العقد والحصول على الـ ID الخاص به
      final contractRow = await into(contracts).insertReturning(contract);
      final String newContractId = contractRow.id;

      // 🌟 2. الذكاء الجديد: 
      // بغض النظر عن نوع العقد أو عدد الأشهر، نولد القسط الأول (1) فقط!
      // وبقية الأقساط ستتولد لاحقاً عند دفع هذا القسط عبر محرك (Rolling Checkpoint).
      final int loopCount = 1; 

      // 3. توليد القسط الأول المستحق في الشهر القادم
      for (int i = 1; i <= loopCount; i++) {
        final dueDate = DateTime.utc(startDate.year, startDate.month + i, startDate.day);
        
        final entry = InstallmentsScheduleCompanion.insert(
          contractId: newContractId, 
          installmentNumber: i, 
          dueDate: dueDate,
          status: const Value('pending'), 
          userId: userId, 
        );
        await into(installmentsSchedule).insert(entry);
      }
    });
  }
  
  Future<List<Contract>> getActiveContracts() =>   (select(contracts)..where((t) => t.isDeleted.equals(false))).get();
  
  
  
  /// حذف عقد (يحذف معه آلياً: أقساطه ومدفوعاته)
  Future<void> softDeleteContract(String contractId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
      await (update(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
      await (update(paymentsLedger)..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(isDeleted: const Value(true), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
    });
  }


  // ==========================================
  // --- استعلامات دفتر المدفوعات (Ledger) ---
  // ==========================================
  Future<List<PaymentsLedgerData>> getLedgerForContract(String contractId) => 
      (select(paymentsLedger)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)])
      ).get();
      
  // 🌟 جلب كل الدفعات في النظام (للوحة التحكم)
  Future<List<PaymentsLedgerData>> getAllActivePayments() => 
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(false))).get();


  Future<String> insertLedgerEntry(PaymentsLedgerCompanion entry) async {
    final row = await into(paymentsLedger).insertReturning(entry);
    return row.id;
  }
  
  // ==========================================
  // 2. إرسال الواتساب
  // ==========================================
  Future<int> markWhatsAppAsSent(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isWhatsAppSent: const Value(true), 
        userId: Value(userId), // 🌟 توثيق من ضغط زر الإرسال
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      ),
    );
  }

  // ==========================================
  // --- استعلامات سجل أسعار المواد ---
  // ==========================================
  // 🌟 جلب كل سجلات أسعار المواد للإحصائيات
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => 
      (select(materialPricesHistory)..where((t) => t.isDeleted.equals(false))).get();
      
  // جلب أحدث سعر فعّال
  Future<MaterialPricesHistoryData?> getLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false)) // 🌟 1. أعدنا شرط تجاهل المحذوف
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate), // 🌟 2. الترتيب الأول حسب تاريخ السريان
            (t) => OrderingTerm.desc(t.createdAt),     // 🌟 3. كاسر التعادل: الترتيب الثاني حسب وقت الإضافة بالثانية
          ])
          ..limit(1))
        .getSingleOrNull();
  }
  
  // 🌟 (النسخة المعدلة) إضافة التسعيرة الجديدة فقط دون لمس السجل القديم
  Future<String> insertMaterialPriceRecord(MaterialPricesHistoryCompanion prices) async {
    // تم حذف الـ transaction والكود الذي يقوم بحذف الأسعار القديمة
    // الآن سيتم إضافة التسعيرة الجديدة فقط كسجل تاريخي جديد
    final row = await into(materialPricesHistory).insertReturning(prices);
    return row.id;
  }

  // ==========================================
  // --- استعلامات الأقساط (جدول الاستحقاقات) ---
  // ==========================================
  
  // جلب جميع الأقساط المجدولة لعقد معين مرتبة تصاعدياً حسب تاريخ الاستحقاق
  Future<List<InstallmentsScheduleData>> getScheduleForContract(String contractId) => 
      (select(installmentsSchedule)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
      ).get();

  

  // تحديث حالة القسط (مثلاً من pending إلى paid)
  Future<int> updateScheduleStatus(String id, String status, String userId) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        status: Value(status), 
        userId: Value(userId), // 🌟 حفظ من قام بتغيير الحالة
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      )
    );
  }

  // حذف قسط مجدول (Soft Delete)
  Future<int> softDeleteScheduleEntry(String id) {
    // 🌍 تسجيل وقت الحذف الوهمي بصيغة UTC
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        isDeleted: const Value(true), 
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      )
    );
  }
  

  // 🌟 جلب كل الأقساط المتأخرة في كامل النظام
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() {
    final nowUtc = DateTime.now().toUtc();
    return (select(installmentsSchedule)
      ..where((t) => t.isDeleted.equals(false) & t.status.equals('pending') & t.dueDate.isSmallerThanValue(nowUtc))
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
    ).get();
  }


  // ==========================================
  // ✏️ تعديل قسط فردي (تأجيل + ملاحظات)
  // ==========================================
  Future<int> updateIndividualSchedule(String scheduleId, DateTime newDueDate, String? notes, String userId) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(scheduleId))).write(
      InstallmentsScheduleCompanion(
        dueDate: Value(newDueDate.toUtc()), 
        notes: Value(notes),
        userId: Value(userId), // 🌟 حفظ آي دي الشخص الذي أجل القسط
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false) 
      )
    );
  }

  // ==========================================
  // 🔄 إعادة الجدولة الذكية (Smart Restructuring)
  // ==========================================
  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
    required String userId,
  }) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. جلب جميع الأقساط المدفوعة لمعرفة أين توقفنا في الترقيم
      final paidSchedules = await (select(installmentsSchedule)
            ..where((t) => t.contractId.equals(contractId) & t.status.equals('paid') & t.isDeleted.equals(false)))
          .get();

      // إيجاد أعلى رقم قسط مدفوع (إذا لم يدفع شيئاً، سيكون 0)
      int lastPaidNumber = 0;
      for (var s in paidSchedules) {
        if (s.installmentNumber > lastPaidNumber) {
          lastPaidNumber = s.installmentNumber;
        }
      }

      // 2. الحذف الوهمي (Soft Delete) لجميع الأقساط "المعلقة" الحالية
      await (update(installmentsSchedule)
            ..where((t) => t.contractId.equals(contractId) & t.status.equals('pending') & t.isDeleted.equals(false)))
          .write(
        InstallmentsScheduleCompanion(
          isDeleted: const Value(true),
          updatedAt: nowUtc,
          isSynced: const Value(false), // إجبار السحابة على مسحهم
        ),
      );

      // 3. توليد الأقساط الجديدة المتبقية بالتاريخ الجديد
      for (int i = 1; i <= newRemainingMonths; i++) {
        // نستخدم DateTime.utc لضمان التوقيت العالمي، والـ Dart ذكية ستعالج زيادة الأشهر تلقائياً للسنوات القادمة
        final dueDate = DateTime.utc(newStartDate.year, newStartDate.month + (i - 1), newStartDate.day);

        final entry = InstallmentsScheduleCompanion.insert(
          contractId: contractId,
          installmentNumber: lastPaidNumber + i, // إكمال الترقيم من حيث انتهى
          dueDate: dueDate,
          status: const Value('pending'),
          userId: userId,
        );
        await into(installmentsSchedule).insert(entry);
      }

      // 4. تحديث مدة العقد الإجمالية في جدول العقود لتتوافق مع الجدولة الجديدة
      final int newTotalInstallments = lastPaidNumber + newRemainingMonths;
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          installmentsCount: Value(newTotalInstallments),
          updatedAt: nowUtc,
          isSynced: const Value(false), // إجبار المزامنة للعقد
        ),
      );
    });
  }
  


  // ==========================================
  // --- البث الحي للأسعار (Stream) ---
  // ==========================================
  Stream<MaterialPricesHistoryData?> watchLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false)) // 🌟 نفس التعديل هنا مهم جداً للداشبورد
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
  // جلب كل الشقق المتاحة في النظام
  Future<List<Apartment>> getAllActiveApartments() => 
      (select(apartments)..where((t) => t.isDeleted.equals(false))).get();

  // جلب الشقق الخاصة بمحضر معين فقط
  Future<List<Apartment>> getApartmentsForBuilding(String buildingId) => 
      (select(apartments)
        ..where((t) => t.buildingId.equals(buildingId) & t.isDeleted.equals(false))
      ).get();

  Future<String> insertApartment(ApartmentsCompanion apartment) async {
    final row = await into(apartments).insertReturning(apartment);
    return row.id;
  }

  // 🌟 أهم دالة: تغيير حالة الشقة 
  Future<int> updateApartmentStatus(String apartmentId, String newStatus, String userId) {
    return (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
      ApartmentsCompanion(
        status: Value(newStatus), 
        userId: Value(userId), // 🌟 توثيق من قام بتغيير الحالة
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      )
    );
  }

  // ==========================================
  // --- تفريغ القاعدة ---
  // ==========================================
  Future<void> clearAllData() {
    return transaction(() async {
      await delete(localUsers).go(); // 🌟 جديد
      await delete(appRoles).go();   // 🌟 جديد
      await delete(paymentsLedger).go();
      await delete(installmentsSchedule).go();
      await delete(materialPricesHistory).go();
      await delete(contracts).go();
      await delete(apartments).go();
      await delete(buildings).go();
      await delete(clients).go();
    });
  }
  
  // ==========================================
  // ☁️ دوال الحقن السحابي (Aggressive Cloud Sync Upserts)
  // ==========================================
  Future<void> syncClient(ClientsCompanion entity) => 
      into(clients).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncContract(ContractsCompanion entity) => 
      into(contracts).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncMaterialPrice(MaterialPricesHistoryCompanion entity) => 
      into(materialPricesHistory).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncSchedule(InstallmentsScheduleCompanion entity) => 
      into(installmentsSchedule).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncPayment(PaymentsLedgerCompanion entity) => 
      into(paymentsLedger).insert(entity, mode: InsertMode.insertOrReplace);

  Future<void> syncBuilding(BuildingsCompanion entity) => 
      into(buildings).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncApartment(ApartmentsCompanion entity) => 
      into(apartments).insert(entity, mode: InsertMode.insertOrReplace);


      // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العملاء
  // ==========================================
  
  // 1. جلب العملاء المحذوفين
  Future<List<Client>> getDeletedClients() => 
      (select(clients)..where((t) => t.isDeleted.equals(true))).get();

  // 2. استعادة عميل محذوف
  Future<void> restoreSoftDeletedClient(String clientId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(
          isDeleted: const Value(false), 
          userId: Value(userId), // 🌟 توثيق من استعاده
          updatedAt: nowUtc, 
          isSynced: const Value(false) 
        ),
      );
    });
  }

  // 3. الحذف النهائي اليدوي (Hard Delete)
  Future<void> hardDeleteClient(String clientId) async {
    await (delete(clients)..where((t) => t.id.equals(clientId))).go();
  }

  // 4. التنظيف التلقائي (مسح أي عنصر محذوف مر عليه 7 أيام)
  Future<void> autoCleanOldDeletedClients() async {
    // تحديد نقطة الزمن (منذ 7 أيام)
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    
    await (delete(clients)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();
  }
      


  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العقود
  // ==========================================
  
  // 1. جلب العقود المحذوفة
  Future<List<Contract>> getDeletedContracts() => 
      (select(contracts)..where((t) => t.isDeleted.equals(true))).get();

  // 2. استعادة عقد (ويستعيد معه جداول الأقساط والمدفوعات الخاصة به)
  Future<void> restoreSoftDeletedContract(String contractId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(isDeleted: const Value(false), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
      await (update(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(isDeleted: const Value(false), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
      await (update(paymentsLedger)..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(isDeleted: const Value(false), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
    });
  }

  // 3. الحذف النهائي اليدوي لعقد (Hard Delete)
  Future<void> hardDeleteContract(String contractId) async {
    return transaction(() async {
      // يجب حذف الأبناء أولاً (الأقساط والمدفوعات) لمنع الأخطاء
      await (delete(paymentsLedger)..where((t) => t.contractId.equals(contractId))).go();
      await (delete(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).go();
      
      // ثم حذف الأب (العقد)
      await (delete(contracts)..where((t) => t.id.equals(contractId))).go();
    });
  }

  // 4. التنظيف التلقائي للعقود القديمة المحذوفة
  Future<void> autoCleanOldDeletedContracts() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    
    // جلب العقود التي مر عليها 7 أيام في الحذف
    final oldContracts = await (select(contracts)..where((t) => t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo))).get();
    
    // حذفها نهائياً مع توابعها
    for (var c in oldContracts) {
      await hardDeleteContract(c.id);
    }
  }

  // ==========================================
  // 🗑️ سلة المحذوفات وتعديل المدفوعات (Ledger)
  // ==========================================

  // ==========================================
  // 1. تعديل دفعة قديمة (تحديث المبلغ والخصم والأمتار)
  // ==========================================
  Future<int> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
    required String userId, // 🌟 استلام المستخدم
  }) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        amountPaid: Value(newAmount),
        fees: Value(newDiscount),
        convertedMeters: Value(newConvertedMeters),
        userId: Value(userId), // 🌟 حفظ من قام بتعديل المبلغ
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false),
      ),
    );
  }

  // ==========================================
  // 3. الحذف الوهمي لدفعة (Soft Delete)
  // ==========================================
  Future<int> softDeleteLedgerEntry(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(true),
        userId: Value(userId), // 🌟 توثيق من قام بحذف الدفعة
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 3. جلب الدفعات المحذوفة
  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() => 
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(true))).get();

  // 4. استعادة دفعة من المحذوفات
  Future<int> restoreLedgerEntry(String entryId, String userId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(false),
        userId: Value(userId), // 🌟 توثيق
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 5. الحذف النهائي لدفعة (Hard Delete المدمر)
  Future<int> forceHardDeleteLedgerEntry(String entryId) {
    return (delete(paymentsLedger)..where((t) => t.id.equals(entryId))).go();
  }

  // 6. التنظيف التلقائي بعد 7 أيام (لتوفير المساحة)
  Future<void> autoCleanOldDeletedLedgerEntries() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    await (delete(paymentsLedger)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();
  }

  // ==========================================
  // 🔄 محرك نقاط التفاعل (Rolling Checkpoints) لـ "لاحق التخصص"
  // ==========================================
  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String currentScheduleId,
    required String actionType, // 'paid' أو 'missed'
    required DateTime nextDueDate,
    required String userId,
  }) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. إغلاق القسط الحالي بالحالة المطلوبة (دفع أو تخلّف)
      await (update(installmentsSchedule)..where((t) => t.id.equals(currentScheduleId))).write(
        InstallmentsScheduleCompanion(
          status: Value(actionType),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        )
      );

      // 2. إيجاد رقم القسط الحالي لمعرفة الرقم التالي
      final currentSchedule = await (select(installmentsSchedule)..where((t) => t.id.equals(currentScheduleId))).getSingle();
      final int nextNumber = currentSchedule.installmentNumber + 1;

      // 3. توليد نقطة التفاعل القادمة (القسط الجديد)
      final newEntry = InstallmentsScheduleCompanion.insert(
        contractId: contractId,
        installmentNumber: nextNumber,
        dueDate: nextDueDate.toUtc(), // التاريخ الذي يحدده المحاسب
        status: const Value('pending'),
        userId: userId,
      );
      await into(installmentsSchedule).insert(newEntry);

      // 4. تحديث عداد الأقساط في العقد ليتوافق مع السجل
      final contract = await (select(contracts)..where((t) => t.id.equals(contractId))).getSingle();
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          installmentsCount: Value(contract.installmentsCount + 1),
          updatedAt: nowUtc,
          isSynced: const Value(false),
        )
      );
    });
  }



  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - المحاضر والشقق
  // ==========================================

  // 1. الحذف الوهمي لمحضر (يحذف معه الشقق التابعة له آلياً)
  Future<void> softDeleteBuilding(String buildingId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // أ. حذف المحضر
      await (update(buildings)..where((t) => t.id.equals(buildingId))).write(
        BuildingsCompanion(
          isDeleted: const Value(true), 
          userId: Value(userId), // 🌟 توثيق من حذف المحضر
          updatedAt: nowUtc, 
          isSynced: const Value(false)
        ),
      );

      // ب. حذف الشقق التابعة له
      await (update(apartments)..where((t) => t.buildingId.equals(buildingId))).write(
        ApartmentsCompanion(
          isDeleted: const Value(true), 
          userId: Value(userId), // 🌟 توثيق من حذف الشقق تبعا للمحضر
          updatedAt: nowUtc, 
          isSynced: const Value(false)
        ),
      );
    });
  }

  // 2. استعادة محضر (يستعيد معه الشقق التابعة له آلياً)
  Future<void> restoreSoftDeletedBuilding(String buildingId, String userId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(buildings)..where((t) => t.id.equals(buildingId))).write(
        BuildingsCompanion(isDeleted: const Value(false), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
      await (update(apartments)..where((t) => t.buildingId.equals(buildingId))).write(
        ApartmentsCompanion(isDeleted: const Value(false), userId: Value(userId), updatedAt: nowUtc, isSynced: const Value(false)),
      );
    });
  }

  // 3. الحذف الوهمي لشقة/محل بشكل مستقل
  Future<int> softDeleteApartment(String apartmentId, String userId) {
    return (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
      ApartmentsCompanion(
        isDeleted: const Value(true),
        userId: Value(userId), // 🌟 توثيق من حذف الشقة
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 4. استعادة شقة/محل بشكل مستقل
  Future<int> restoreSoftDeletedApartment(String apartmentId, String userId) {
    return (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
      ApartmentsCompanion(
        isDeleted: const Value(false),
        userId: Value(userId), // 🌟 توثيق
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 5. جلب المحاضر المحذوفة (لسلة المحذوفات)
  Future<List<Building>> getDeletedBuildings() => 
      (select(buildings)..where((t) => t.isDeleted.equals(true))).get();

  // 6. جلب الشقق المحذوفة (لسلة المحذوفات)
  Future<List<Apartment>> getDeletedApartments() => 
      (select(apartments)..where((t) => t.isDeleted.equals(true))).get();

  // 7. الحذف النهائي لمحضر (Hard Delete) - مدمر!
  Future<void> hardDeleteBuilding(String buildingId) async {
    return transaction(() async {
      // يجب حذف الأبناء (الشقق) أولاً
      await (delete(apartments)..where((t) => t.buildingId.equals(buildingId))).go();
      // ثم حذف الأب (المحضر)
      await (delete(buildings)..where((t) => t.id.equals(buildingId))).go();
    });
  }

  // 8. الحذف النهائي لشقة (Hard Delete)
  Future<int> hardDeleteApartment(String apartmentId) {
    return (delete(apartments)..where((t) => t.id.equals(apartmentId))).go();
  }

  // 9. التنظيف التلقائي للمحاضر والشقق القديمة (مر عليها 7 أيام)
  Future<void> autoCleanOldDeletedBuildingsAndApartments() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    
    // الشقق أولاً (لأنها تعتمد على المحاضر)
    await (delete(apartments)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();

    // المحاضر ثانياً
    await (delete(buildings)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();
  }


  // ==========================================
  // 🛡️ --- استعلامات الصلاحيات والمستخدمين ---
  // ==========================================

  // 1. جلب كل الأدوار (لواجهة لوحة التحكم)
  Future<List<AppRole>> getAllRoles() => 
      (select(appRoles)..where((t) => t.isDeleted.equals(false))).get();

  // 2. جلب كل المستخدمين (لواجهة لوحة التحكم)
  Future<List<LocalUser>> getAllLocalUsers() => 
      (select(localUsers)..where((t) => t.isDeleted.equals(false))).get();

  // 3. إضافة دور (قالب جديد)
  Future<String> insertRole(AppRolesCompanion role) async {
    final row = await into(appRoles).insertReturning(role);
    return row.id;
  }

  // 4. تحديث قالب دور (تعديل صلاحيات المحاسب مثلاً)
  Future<int> updateRolePermissions(String roleId, String newPermissionsJson) {
    return (update(appRoles)..where((t) => t.id.equals(roleId))).write(
      AppRolesCompanion(
        permissionsJson: Value(newPermissionsJson),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false)
      )
    );
  }

  // 5. تعيين دور لمستخدم (Assign Role) مع إضافة استثناءات إن وجدت
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
        extraPermissionsJson: extraPermissionsJson != null ? Value(extraPermissionsJson) : const Value.absent(),
        revokedPermissionsJson: revokedPermissionsJson != null ? Value(revokedPermissionsJson) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false)
      )
    );
  }

  // ==========================================
  // ☁️ دوال الحقن السحابي الجديدة (Sync Upserts)
  // ==========================================
  Future<void> syncAppRole(AppRolesCompanion entity) => 
      into(appRoles).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncLocalUser(LocalUsersCompanion entity) => 
      into(localUsers).insert(entity, mode: InsertMode.insertOrReplace);
  

  // جلب مستخدم محلي بناءً على الآي دي
  Future<LocalUser?> getLocalUserById(String id) => 
      (select(localUsers)..where((t) => t.id.equals(id))).getSingleOrNull();

  // جلب قالب بناءً على الآي دي
  Future<AppRole?> getRoleById(String id) => 
      (select(appRoles)..where((t) => t.id.equals(id))).getSingleOrNull();


  // ==========================================
  // 🕒 استعلامات سجل النشاطات (Activity Log) السريعة
  // ==========================================
  
  // 1. جلب أحدث الدفعات
  Future<List<PaymentsLedgerData>> getRecentPayments(int limitCount) => 
      (select(paymentsLedger)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(limitCount)
      ).get();

  // 2. جلب أحدث العقود (إضافة أو تعديل)
  Future<List<Contract>> getRecentContracts(int limitCount) => 
      (select(contracts)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(limitCount)
      ).get();

  // 3. جلب أحدث العملاء
  Future<List<Client>> getRecentClients(int limitCount) => 
      (select(clients)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(limitCount)
      ).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory(); 
    // 🌟 تغيير الاسم لإنشاء قاعدة جديدة نظيفة تماماً للعمل مع UUID v7 الجديد
    final file = File(p.join(dbFolder.path, 'our_home_erp_v11_permissions.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}




