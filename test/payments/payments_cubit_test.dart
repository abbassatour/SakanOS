// test/payments/payments_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';

import '../helpers/mocks.dart';

// 🌟 تسجيل الـ Fallback Values لتجنب مشاكل Mocktail مع القيم المسماة
class FakeDateTime extends Fake implements DateTime {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDateTime());
  });

  group('PaymentsCubit - Financial & Offline-First Behavior', () {
    late MockErpRepository mockErpRepository;

    final dummyContract = Contract(
      id: 'contract_1',
      clientId: 'client_1',
      contractType: 'متخصص',
      apartmentDetails: 'شقة تجريبية',
      totalArea: 100.0,
      baseMeterPriceAtSigning: 1000000.0,
      downPayment: 0.0,
      isPenaltyActive: false,
      penaltyPercentage: 0.0,
      penaltyIntervalMonths: 1,
      isHandedOver: false,
      gracePeriodMonths: 0,
      installmentsCount: 48,
      agreedMonthlyAmount: 100000.0,
      coefficients: '{}',
      contractDate: DateTime.now(),
      guarantorName: 'كفيل',
      userId: 'admin',
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: false,
    );

    final dummyPrices = MaterialPricesHistoryData(
      id: 'price_1',
      effectiveDate: DateTime.now(),
      ironPrice: 15000.0,
      cementPrice: 50000.0,
      block15Price: 5000.0,
      formworkAndPouringWages: 100000.0,
      aggregateMaterialsPrice: 20000.0,
      ordinaryWorkerWage: 50000.0,
      userId: 'admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: false,
    );

    setUp(() {
      mockErpRepository = MockErpRepository();
    });

    // =========================================================
    // 💰 1. اختبار الحساب المالي (تحويل النقد إلى أمتار)
    // =========================================================
    blocTest<PaymentsCubit, PaymentsState>(
      'emits [loading, loading, success] and calculates converted meters precisely on valid payment',
      build: () {
        when(
          () => mockErpRepository.getLatestPrices(),
        ).thenAnswer((_) async => dummyPrices);

        when(
          () => mockErpRepository.addLedgerEntry(
            contractId: any(named: 'contractId'),
            amountPaid: any(named: 'amountPaid'),
            meterPriceAtPayment: any(named: 'meterPriceAtPayment'),
            convertedMeters: any(named: 'convertedMeters'),
            pricesSnapshotJson: any(named: 'pricesSnapshotJson'),
            discountPercentage: any(named: 'discountPercentage'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockErpRepository.getContractLedger('contract_1'),
        ).thenAnswer((_) async => []);

        when(
          () => mockErpRepository.forceSyncWithCloud(),
        ).thenAnswer((_) async => 'Success');

        return PaymentsCubit(mockErpRepository);
      },
      seed: () => PaymentsState(
        status: PaymentsStatus.success,
        contracts: [dummyContract],
      ),
      act: (cubit) => cubit.addLedgerEntry(
        contractId: 'contract_1',
        amountPaid: 1090000.0,
      ),
      expect: () => [
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.loading,
        ),
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.loading,
        ),
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockErpRepository.addLedgerEntry(
            contractId: 'contract_1',
            amountPaid: 1090000.0,
            meterPriceAtPayment: 1090000.0,
            convertedMeters: 1.0,
            pricesSnapshotJson: any(named: 'pricesSnapshotJson'),
            discountPercentage: 0.0,
          ),
        ).called(1);
      },
    );

    // =========================================================
    // 🌐 2. اختبار مرونة النظام دون إنترنت (Offline-First)
    // =========================================================
    blocTest<PaymentsCubit, PaymentsState>(
      'swallows background sync errors to support Offline-First architecture without crashing',
      build: () {
        when(
          () => mockErpRepository.getLatestPrices(),
        ).thenAnswer((_) async => dummyPrices);

        when(
          () => mockErpRepository.addLedgerEntry(
            contractId: any(named: 'contractId'),
            amountPaid: any(named: 'amountPaid'),
            meterPriceAtPayment: any(named: 'meterPriceAtPayment'),
            convertedMeters: any(named: 'convertedMeters'),
            pricesSnapshotJson: any(named: 'pricesSnapshotJson'),
            discountPercentage: any(named: 'discountPercentage'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockErpRepository.getContractLedger('contract_1'),
        ).thenAnswer((_) async => []);

        // 🌟 الحل السحري هنا: نحدد نوع الـ Future صراحةً كـ Future<String> بدلاً من Never
        when(() => mockErpRepository.forceSyncWithCloud()).thenAnswer(
          (_) => Future<String>.error(
            Exception('SocketException: No Internet Connection'),
          ),
        );

        return PaymentsCubit(mockErpRepository);
      },
      seed: () => PaymentsState(
        status: PaymentsStatus.success,
        contracts: [dummyContract],
      ),
      act: (cubit) => cubit.addLedgerEntry(
        contractId: 'contract_1',
        amountPaid: 545000.0,
      ),
      expect: () => [
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.loading,
        ),
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.loading,
        ),
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.success,
        ),
      ],
    );

    // =========================================================
    // ⚠️ 3. اختبار الحماية من فقدان أسعار المواد
    // =========================================================
    blocTest<PaymentsCubit, PaymentsState>(
      'emits [loading, failure] when material prices are missing (Prevention of division by zero)',
      build: () {
        when(
          () => mockErpRepository.getLatestPrices(),
        ).thenAnswer((_) async => null);

        return PaymentsCubit(mockErpRepository);
      },
      seed: () => PaymentsState(
        status: PaymentsStatus.success,
        contracts: [dummyContract],
      ),
      act: (cubit) => cubit.addLedgerEntry(
        contractId: 'contract_1',
        amountPaid: 1000000.0,
      ),
      expect: () => [
        isA<PaymentsState>().having(
          (s) => s.status,
          'status',
          PaymentsStatus.loading,
        ),
        isA<PaymentsState>()
            .having((s) => s.status, 'status', PaymentsStatus.failure)
            .having((s) => s.errorMessage, 'error', contains('أسعار المواد')),
      ],
    );
  });
}
