// test/database/cascading_delete_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  group('Database Integration - Cascading Soft Delete', () {
    late AppDatabase db;

    setUp(() {
      // 🌟 السحر هنا: إنشاء قاعدة بيانات SQLite حقيقية ولكن في الذاكرة العشوائية RAM!
      // ستكون سريعة جداً، معزولة، وتختفي بمجرد انتهاء الاختبار.
      db = AppDatabase(e: NativeDatabase.memory());
    });

    tearDown(() async {
      // إغلاق قاعدة البيانات بعد كل اختبار لتفريغ الذاكرة
      await db.close();
    });

    test(
      'softDeleteClient safely deletes client, their contracts, schedules, and payments',
      () async {
        // =========================================================
        // 🏗️ Arrange (تجهيز البيانات المرتبطة ببعضها)
        // =========================================================
        const clientId = 'client_99';
        const contractId = 'contract_99';
        const scheduleId = 'schedule_99';
        const paymentId = 'payment_99';
        const adminUser = 'admin_user';

        // 1. إدخال عميل
        await db
            .into(db.clients)
            .insert(
              ClientsCompanion.insert(
                id: const drift.Value(clientId),
                name: 'عميل خطير',
                phone: '0999999999',
                userId: adminUser,
              ),
            );

        // 2. إدخال عقد تابع للعميل
        await db
            .into(db.contracts)
            .insert(
              ContractsCompanion.insert(
                id: const drift.Value(contractId),
                clientId: clientId, // 🔗 ربط العقد بالعميل
                totalArea: 100.0,
                baseMeterPriceAtSigning: 1000.0,
                guarantorName: 'كفيل تجريبي', // 🌟 تم إضافة الحقل الإجباري هنا
                contractDate: SecureTime.now(),
                userId: adminUser,
              ),
            );

        // 3. إدخال قسط استحقاق تابع للعقد
        await db
            .into(db.installmentsSchedule)
            .insert(
              InstallmentsScheduleCompanion.insert(
                id: const drift.Value(scheduleId),
                contractId: contractId, // 🔗 ربط القسط بالعقد
                installmentNumber: 1,
                dueDate: SecureTime.now(),
                userId: adminUser,
              ),
            );

        // 4. إدخال دفعة مالية تابعة للعقد
        await db
            .into(db.paymentsLedger)
            .insert(
              PaymentsLedgerCompanion.insert(
                id: const drift.Value(paymentId),
                contractId: contractId, // 🔗 ربط الدفعة بالعقد
                paymentDate: SecureTime.now(),
                amountPaid: 50000.0,
                meterPriceAtPayment: 1000.0,
                convertedMeters: 50.0,
                userId: adminUser,
              ),
            );

        // =========================================================
        // 🚀 Act (تنفيذ العملية الخطيرة)
        // =========================================================
        // المدير قرر حذف العميل، فيجب على الداتابيز أن تنظف كل شيء متعلق به آلياً.
        await db.softDeleteClient(clientId, 'super_admin');

        // =========================================================
        // 🕵️‍♂️ Assert (التحقق من النتائج)
        // =========================================================

        // جلب السجلات من الجداول مباشرة (متجاهلين فلتر isDeleted الافتراضي)
        final client = await (db.select(
          db.clients,
        )..where((t) => t.id.equals(clientId))).getSingle();
        final contract = await (db.select(
          db.contracts,
        )..where((t) => t.id.equals(contractId))).getSingle();
        final schedule = await (db.select(
          db.installmentsSchedule,
        )..where((t) => t.id.equals(scheduleId))).getSingle();
        final payment = await (db.select(
          db.paymentsLedger,
        )..where((t) => t.id.equals(paymentId))).getSingle();

        // 🎯 التأكد من أن خاصية (محذوف) طبقت على الجميع تعاقبياً
        expect(client.isDeleted, isTrue, reason: 'Client should be deleted');
        expect(
          contract.isDeleted,
          isTrue,
          reason: 'Contract should be deleted',
        );
        expect(
          schedule.isDeleted,
          isTrue,
          reason: 'Schedule should be deleted',
        );
        expect(payment.isDeleted, isTrue, reason: 'Payment should be deleted');

        // 🎯 التأكد من توثيق "مَن قام بالحذف" (super_admin)
        expect(client.userId, 'super_admin');
        expect(contract.userId, 'super_admin');
        expect(schedule.userId, 'super_admin');
        expect(payment.userId, 'super_admin');

        // 🎯 التأكد من تأشير الحقول كـ "غير متزامنة" لتطبيق التغيير على السحابة لاحقاً
        expect(client.isSynced, isFalse);
        expect(contract.isSynced, isFalse);
        expect(schedule.isSynced, isFalse);
        expect(payment.isSynced, isFalse);
      },
    );
  });
}
