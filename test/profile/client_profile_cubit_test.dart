// test/profile/client_profile_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/profile/cubit/client_profile_cubit.dart';

import '../helpers/mocks.dart';

void main() {
  group(
    'ClientProfileCubit - Advanced Financial Guardrails (Penalties & Overdue)',
    () {
      late MockErpRepository mockErpRepository;

      // 🌟 توحيد التواريخ لضمان دقة الرياضيات في الاختبار
      final now = DateTime.now().toUtc();
      // عقد تم توقيعه قبل 100 يوم (يضمن مرور 3 أشهر فعلية على الأقل)
      final contractDate = now.subtract(const Duration(days: 100));
      // شقة تم تسليمها قبل 70 يوماً (يضمن مرور شهرين كاملين على الاستلام)
      final handoverDate = now.subtract(const Duration(days: 70));

      final dummyClient = Client(
        id: 'client_1',
        name: 'عميل اختبار الغرامات',
        phone: '0999999999',
        userId: 'admin',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        isSynced: true,
      );

      // تجهيز دفعة واحدة (مقدم 50,000 ل.س)
      final dummyPayment = PaymentsLedgerData(
        id: 'pay_1',
        contractId: 'contract_1',
        paymentDate: contractDate,
        amountPaid: 50000.0,
        meterPriceAtPayment: 1000.0,
        convertedMeters: 50.0,
        pricesSnapshot: '{}',
        fees: 0.0,
        isWhatsAppSent: false,
        userId: 'admin',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        isSynced: true,
      );

      setUp(() {
        mockErpRepository = MockErpRepository();

        // Mocks الافتراضية الثابتة لمعظم الاختبارات هنا
        when(
          () => mockErpRepository.getAllPayments(),
        ).thenAnswer((_) async => [dummyPayment]);
        when(
          () => mockErpRepository.getContractSchedule(any()),
        ).thenAnswer((_) async => []); // لن تؤثر على الحساب المالي المباشر
        when(
          () => mockErpRepository.getAllLegalActions(),
        ).thenAnswer((_) async => []); // لا يوجد إجراءات
      });

      // =========================================================
      // 📊 1. حساب الديون المتأخرة بدون غرامات (الوضع الطبيعي)
      // =========================================================
      blocTest<ClientProfileCubit, ClientProfileState>(
        'calculates exact base overdue amount without penalties for a regular late client',
        build: () {
          // تجهيز عقد عادي غير مسلم، والقسط الشهري 10,000 ل.س
          final regularContract = Contract(
            id: 'contract_1',
            clientId: 'client_1',
            contractType: 'متخصص',
            apartmentDetails: 'شقة 1',
            totalArea: 100,
            baseMeterPriceAtSigning: 1000,
            downPayment: 50000.0, // دفع المقدم
            agreedMonthlyAmount: 10000.0, // القسط 10 آلاف
            installmentsCount: 48,
            contractDate: contractDate, // مر عليه 3 أشهر
            isHandedOver: false, // 👈 لم يتم التسليم بعد (لا توجد غرامة)
            isPenaltyActive: false,
            penaltyPercentage: 0,
            penaltyIntervalMonths: 1,
            guarantorName: 'كفيل',
            isCompleted: false,
            userId: 'admin',
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
            isSynced: true,
            coefficients: '{}',
            gracePeriodMonths: 0,
          );

          when(
            () => mockErpRepository.getContractsForClient('client_1'),
          ).thenAnswer((_) async => [regularContract]);

          return ClientProfileCubit(mockErpRepository);
        },
        act: (cubit) => cubit.fetchClientData(dummyClient),
        expect: () => [
          isA<ClientProfileState>().having(
            (s) => s.status,
            'status',
            ClientProfileStatus.loading,
          ),
          isA<ClientProfileState>().having(
            (s) => s.status,
            'status',
            ClientProfileStatus.success,
          ),
        ],
        verify: (cubit) {
          final summary = cubit.state.contractsSummary.first;

          // 🎯 التحليل المحاسبي المتوقع:
          // المدفوع: 50,000 (المقدم)
          // الأشهر المنقضية: 3 أشهر
          // المطلوب: 50,000 (المقدم) + (3 * 10,000) = 80,000
          // المتأخرات الأساسية: 80,000 - 50,000 = 30,000 ل.س

          expect(summary.totalPaid, 50000.0);
          expect(summary.baseOverdueAmount, 30000.0);
          expect(summary.penaltyAmount, 0.0); // الغرامة صفر لأن الشقة غير مسلمة
          expect(summary.totalOverdueWithPenalty, 30000.0);
          expect(cubit.state.totalOverdueAcrossAll, 30000.0);
        },
      );

      // =========================================================
      // 🚨 2. حساب الغرامات المركبة (الوضع الحرج للمحاسب)
      // =========================================================
      blocTest<ClientProfileCubit, ClientProfileState>(
        'calculates composite penalty correctly if contract is handed over and penalty is active',
        build: () {
          // تجهيز عقد مسلم، والغرامة 5% تطبق كل 1 شهر
          final penalizedContract = Contract(
            id: 'contract_1',
            clientId: 'client_1',
            contractType: 'متخصص',
            apartmentDetails: 'شقة 1',
            totalArea: 100,
            baseMeterPriceAtSigning: 1000,
            downPayment: 50000.0,
            agreedMonthlyAmount: 10000.0,
            installmentsCount: 48,
            contractDate: contractDate, // مر 3 أشهر
            isHandedOver: true, // 👈 تم التسليم
            actualHandoverDate: handoverDate, // مر على التسليم شهرين
            isPenaltyActive: true, // 👈 الغرامة مفعلة
            penaltyPercentage: 5.0, // الغرامة 5%
            penaltyIntervalMonths: 1, // كل 1 شهر
            guarantorName: 'كفيل',
            isCompleted: false,
            userId: 'admin',
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
            isSynced: true,
            coefficients: '{}',
            gracePeriodMonths: 0,
          );

          when(
            () => mockErpRepository.getContractsForClient('client_1'),
          ).thenAnswer((_) async => [penalizedContract]);

          return ClientProfileCubit(mockErpRepository);
        },
        act: (cubit) => cubit.fetchClientData(dummyClient),
        verify: (cubit) {
          final summary = cubit.state.contractsSummary.first;

          // 🎯 التحليل المحاسبي المتوقع:
          // المتأخرات الأساسية: 30,000 ل.س
          // مرت فترة (شهرين) على استلام الشقة.
          // الغرامة = 5% من الدين الأساسي لكل شهر. (5% من 30,000 = 1,500)
          // 1,500 * 2 شهر = 3,000 ل.س غرامة إجمالية!
          // الإجمالي المطلوب = 30,000 + 3,000 = 33,000 ل.س

          expect(summary.totalPaid, 50000.0);
          expect(summary.baseOverdueAmount, 30000.0);
          expect(summary.penaltyAmount, 3000.0); // 🚨 الغرامة الدقيقة!
          expect(summary.totalOverdueWithPenalty, 33000.0);
          expect(cubit.state.totalOverdueAcrossAll, 33000.0);
        },
      );
    },
  );
}
