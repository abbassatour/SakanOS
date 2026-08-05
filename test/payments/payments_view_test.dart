// test/payments/payments_view_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';

import '../helpers/mocks.dart';
import 'payments_robot.dart';

void main() {
  group('PaymentsView - UI Permissions Rendering (Robot Pattern)', () {
    late MockAuthCubit mockAuthCubit;
    late MockPaymentsCubit mockPaymentsCubit;

    // تجهيز بيانات وهمية ليتم عرض الواجهة بدون رسائل "لا يوجد بيانات"
    final dummyClient = Client(
      id: 'c1',
      name: 'عميل تجريبي',
      phone: '123',
      userId: 'admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: true,
    );

    final dummyContract = Contract(
      id: 'co1',
      clientId: 'c1',
      totalArea: 100,
      baseMeterPriceAtSigning: 1000,
      contractDate: DateTime.now(),
      userId: 'admin',
      contractType: 'متخصص',
      apartmentDetails: 'تفاصيل',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: true,
      downPayment: 0,
      penaltyPercentage: 0,
      penaltyIntervalMonths: 1,
      installmentsCount: 48,
      agreedMonthlyAmount: 100,
      guarantorName: 'Test',
      isPenaltyActive: false,
      isHandedOver: false,
      gracePeriodMonths: 0,
      coefficients: '{}',
      isCompleted: false,
    );

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockPaymentsCubit = MockPaymentsCubit();

      // تجهيز حالة الـ PaymentsCubit بوجود عقد محدد (لكي يظهر الزر في الـ TopBar)
      when(() => mockPaymentsCubit.state).thenReturn(
        PaymentsState(
          status: PaymentsStatus.success,
          clients: [dummyClient],
          contracts: [dummyContract],
          selectedContractId: 'co1',
        ),
      );
    });

    testWidgets('Add Payment button is DISABLED when user lacks permission', (
      tester,
    ) async {
      // Arrange
      final robot = PaymentsRobot(tester);
      when(() => mockAuthCubit.state).thenReturn(
        const AuthState(
          status: AuthStatus.authenticated,
          isSystemAdmin: false,
          permissions: [], // 🔴 لا يملك صلاحية إضافة دفعة
        ),
      );

      // Act
      await robot.pumpPaymentsView(
        authCubit: mockAuthCubit,
        paymentsCubit: mockPaymentsCubit,
      );

      // Assert (انظر كم هو سهل قراءة الكود!)
      robot.expectAddPaymentButtonDisabled();
    });

    testWidgets('Add Payment button is ENABLED when user has permission', (
      tester,
    ) async {
      // Arrange
      final robot = PaymentsRobot(tester);
      when(() => mockAuthCubit.state).thenReturn(
        const AuthState(
          status: AuthStatus.authenticated,
          isSystemAdmin: false,
          permissions: [AppPermissions.addPayments], // 🟢 يملك الصلاحية
        ),
      );

      // Act
      await robot.pumpPaymentsView(
        authCubit: mockAuthCubit,
        paymentsCubit: mockPaymentsCubit,
      );

      // Assert
      robot.expectAddPaymentButtonEnabled();
    });
  });
}
