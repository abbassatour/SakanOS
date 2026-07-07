// test/schedule/schedule_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/schedule/cubit/schedule_cubit.dart';

import '../helpers/mocks.dart';

void main() {
  group('ScheduleCubit - Smart Radar Engine', () {
    late MockErpRepository mockErpRepository;

    final now = DateTime.now().toUtc();

    final dummyClient = Client(
      id: 'client_1',
      name: 'العميل المستهدف',
      phone: '0900000000',
      userId: 'admin',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      isSynced: true,
    );

    setUp(() {
      mockErpRepository = MockErpRepository();

      when(
        () => mockErpRepository.getClients(),
      ).thenAnswer((_) async => [dummyClient]);
    });

    // =========================================================
    // 🚨 1. اختبار رادار الديون المتأخرة (Overdue Radar)
    // =========================================================
    blocTest<ScheduleCubit, ScheduleState>(
      'classifies overdue severity correctly (critical >= 60 days, warning >= 30 days)',
      build: () {
        // العقد المرتبط بالدين
        final contract = Contract(
          id: 'contract_1',
          clientId: 'client_1',
          totalArea: 100,
          baseMeterPriceAtSigning: 1000,
          contractType: 'متخصص',
          apartmentDetails: 'شقة',
          contractDate: now,
          userId: 'admin',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
          isSynced: true,
          downPayment: 0,
          penaltyPercentage: 0,
          penaltyIntervalMonths: 1,
          installmentsCount: 48,
          agreedMonthlyAmount: 100000,
          guarantorName: 'كفيل',
          isPenaltyActive: false,
          isHandedOver: false,
          gracePeriodMonths: 0,
          coefficients: '{}',
        );

        // قسط متأخر منذ 65 يوماً (يجب أن يكون critical - حرج)
        final overdueSchedule = InstallmentsScheduleData(
          id: 'sch_1',
          contractId: 'contract_1',
          installmentNumber: 1,
          dueDate: now.subtract(const Duration(days: 65)), // 👈 65 يوماً تأخير
          status: 'pending',
          userId: 'admin',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
          isSynced: true,
        );

        when(
          () => mockErpRepository.getAllContracts(),
        ).thenAnswer((_) async => [contract]);
        when(
          () => mockErpRepository.getAllOverdueSchedules(),
        ).thenAnswer((_) async => [overdueSchedule]);

        // Mock فارغ لرادار التخصص لكي لا يتعطل الاختبار
        when(
          () => mockErpRepository.getContractLedger(any()),
        ).thenAnswer((_) async => []);

        return ScheduleCubit(mockErpRepository);
      },
      act: (cubit) => cubit.fetchInitialData(),
      verify: (cubit) {
        final overdueAlerts = cubit.state.overdueAlerts;
        expect(overdueAlerts.length, 1);

        final alert = overdueAlerts.first;
        expect(alert.client.name, 'العميل المستهدف');
        expect(alert.maxDaysOverdue, greaterThanOrEqualTo(65));

        // 🎯 التحقق الأهم: النظام يجب أن يصنف العميل كحالة (حرجة)
        expect(alert.severity, 'critical');
      },
    );

    // =========================================================
    // 📊 2. اختبار رادار سرعة التخصص (Allocation Radar)
    // =========================================================
    blocTest<ScheduleCubit, ScheduleState>(
      'calculates allocation speed and estimates months left to reach the 50m target',
      build: () {
        // عقد (لاحق التخصص) تم توقيعه قبل 6 أشهر (180 يوماً)
        final unallocatedContract = Contract(
          id: 'contract_unallocated',
          clientId: 'client_1',
          totalArea: 0,
          baseMeterPriceAtSigning: 0,
          contractType: 'لاحق التخصص', // 👈 الشرط الأساسي
          apartmentDetails: 'محفظة',
          contractDate: now.subtract(const Duration(days: 180)), // 👈 6 أشهر
          userId: 'admin',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
          isSynced: true,
          downPayment: 0,
          penaltyPercentage: 0,
          penaltyIntervalMonths: 1,
          installmentsCount: 0,
          agreedMonthlyAmount: 0,
          guarantorName: 'كفيل',
          isPenaltyActive: false,
          isHandedOver: false,
          gracePeriodMonths: 0,
          coefficients: '{}',
        );

        // سجل مدفوعات العميل يحتوي على دفعتين مجموعها 12 متراً (12 متر / 6 أشهر = 2 متر شهرياً)
        final payment1 = PaymentsLedgerData(
          id: 'pay_1',
          contractId: 'contract_unallocated',
          paymentDate: now,
          amountPaid: 1000,
          meterPriceAtPayment: 100,
          convertedMeters: 6.0,
          pricesSnapshot: '',
          fees: 0,
          isWhatsAppSent: false,
          userId: 'admin',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
          isSynced: true,
        );
        final payment2 = PaymentsLedgerData(
          id: 'pay_2',
          contractId: 'contract_unallocated',
          paymentDate: now,
          amountPaid: 1000,
          meterPriceAtPayment: 100,
          convertedMeters: 6.0,
          pricesSnapshot: '',
          fees: 0,
          isWhatsAppSent: false,
          userId: 'admin',
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
          isSynced: true,
        );

        when(
          () => mockErpRepository.getAllContracts(),
        ).thenAnswer((_) async => [unallocatedContract]);
        when(
          () => mockErpRepository.getAllOverdueSchedules(),
        ).thenAnswer((_) async => []);
        when(
          () => mockErpRepository.getContractLedger('contract_unallocated'),
        ).thenAnswer((_) async => [payment1, payment2]);

        return ScheduleCubit(mockErpRepository);
      },
      act: (cubit) => cubit.fetchInitialData(),
      verify: (cubit) {
        final allocationAlerts = cubit.state.allocationAlerts;
        expect(allocationAlerts.length, 1);

        final alert = allocationAlerts.first;

        // 🎯 التحليل الرياضي:
        // الأمتار المكتسبة = 12
        // الأشهر المنقضية = 6
        // متوسط السرعة = 12 / 6 = 2 متر/شهر
        // الهدف = 50 متر
        // المتبقي للهدف = 50 - 12 = 38 متر
        // الأشهر المقدرة للوصول للهدف = 38 / 2 = 19 شهر

        expect(alert.accumulatedMeters, 12.0);
        expect(alert.averageMetersPerMonth, 2.0);
        expect(alert.estimatedMonthsLeft, 19);

        // بما أن المتبقي 19 شهراً (أكبر من 6)، فالحالة آمنة (low)
        expect(alert.urgencyLevel, 'low');
      },
    );
  });
}
