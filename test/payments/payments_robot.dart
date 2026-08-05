// test/payments/payments_robot.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/view/payments_page.dart';

class PaymentsRobot {
  PaymentsRobot(this.tester);
  final WidgetTester tester;

  // 1. أمر تجهيز الشاشة (Pump)
  Future<void> pumpPaymentsView({
    required AuthCubit authCubit,
    required PaymentsCubit paymentsCubit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authCubit),
            BlocProvider.value(value: paymentsCubit),
          ],
          child: const PaymentsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // 2. أمر التأكد أن الزر معطل (Disabled)
  void expectAddPaymentButtonDisabled() {
    // نبحث عن الزر الذي يحمل نص "إدخال دفعة"
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'إدخال دفعة'),
    );
    // نتأكد أن الـ onPressed فارغ (مما يعني أن الزر معطل بصرياً ووظيفياً)
    expect(button.enabled, isFalse);
  }

  // 3. أمر التأكد أن الزر مُفعل (Enabled)
  void expectAddPaymentButtonEnabled() {
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'إدخال دفعة'),
    );
    // نتأكد أن الـ onPressed يحتوي على دالة (مما يعني أنه قابل للنقر)
    expect(button.enabled, isTrue);
  }
}
