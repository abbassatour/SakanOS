// test/calculator_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:our_home_erp_app/core/utils/calculator_helper.dart';

void main() {
  group('CalculatorHelper.applySpecialDiscount', () {
    group('VIP customers', () {
      test('applies long-term VIP discount (30%) when loyalYears > 5', () {
        expect(
          CalculatorHelper.applySpecialDiscount(1000.0, true, 6),
          700.0,
        );
      });

      test(
        'applies standard VIP discount (15%) at the loyalYears == 5 boundary '
        '(long-term threshold not yet exceeded)',
        () {
          expect(
            CalculatorHelper.applySpecialDiscount(1000.0, true, 5),
            850.0,
          );
        },
      );

      test(
        'applies standard VIP discount (15%) regardless of low loyalYears',
        () {
          expect(
            CalculatorHelper.applySpecialDiscount(1000.0, true, 0),
            850.0,
          );
        },
      );

      test(
        'VIP discount takes precedence over loyalty discount '
        '(loyalYears == 3 would qualify for loyalty discount if not VIP)',
        () {
          expect(
            CalculatorHelper.applySpecialDiscount(1000.0, true, 3),
            850.0,
          );
        },
      );
    });

    group('Non-VIP customers', () {
      test('applies loyalty discount (10%) when loyalYears > 2', () {
        expect(
          CalculatorHelper.applySpecialDiscount(1000.0, false, 3),
          900.0,
        );
      });

      test(
        'does NOT apply loyalty discount at the loyalYears == 2 boundary '
        '(threshold not yet exceeded)',
        () {
          expect(
            CalculatorHelper.applySpecialDiscount(1000.0, false, 2),
            1000.0,
          );
        },
      );

      test('returns original price unchanged when loyalYears < 2', () {
        expect(
          CalculatorHelper.applySpecialDiscount(1000.0, false, 1),
          1000.0,
        );
      });

      test('returns original price unchanged when loyalYears == 0', () {
        expect(
          CalculatorHelper.applySpecialDiscount(1000.0, false, 0),
          1000.0,
        );
      });
    });

    group('Input validation', () {
      test('throws ArgumentError when originalPrice is negative', () {
        expect(
          () => CalculatorHelper.applySpecialDiscount(-100.0, true, 6),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError when loyalYears is negative', () {
        expect(
          () => CalculatorHelper.applySpecialDiscount(1000.0, false, -1),
          throwsArgumentError,
        );
      });

      test('does not throw when originalPrice is exactly 0', () {
        expect(
          CalculatorHelper.applySpecialDiscount(0.0, true, 6),
          0.0,
        );
      });
    });
  });
}
