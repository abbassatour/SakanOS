// test/calculator_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_api/local_storage_api.dart'; // لجلب MaterialPricesHistoryData
import 'package:our_home_erp_app/core/utils/calculator_helper.dart';

void main() {
  group('CalculatorHelper - Pure Logic', () {
    group('calculateContractValues (Financial Engine)', () {
      // 🌟 تجهيز بيانات وهمية لأسعار المواد (Dummy Data)
      late MaterialPricesHistoryData dummyPrices;

      setUp(() {
        dummyPrices = MaterialPricesHistoryData(
          id: 'dummy_id',
          ironPrice: 15000.0, // 15,000 * 30 = 450,000
          cementPrice: 50000.0, // 50,000 * 4 = 200,000
          block15Price: 5000.0, // 5,000 * 50 = 250,000
          formworkAndPouringWages: 100000.0, // 100,000 * 1 = 100,000
          aggregateMaterialsPrice: 20000.0, // 20,000 * 2 = 40,000
          ordinaryWorkerWage: 50000.0, // 50,000 * 1 = 50,000
          // الإجمالي الخام المتوقع = 1,090,000 ل.س
          effectiveDate: DateTime.now(),
          userId: 'admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          isSynced: false,
        );
      });

      test(
        'returns correct calculated base values without any coefficients',
        () {
          // Arrange
          const double area = 100.0;
          const int months = 10;
          // Expected Total = 1,090,000 * 100 = 109,000,000
          // Expected Monthly = 10,900,000

          // Act
          final result = CalculatorHelper.calculateContractValues(
            area: area,
            currentPrices: dummyPrices,
            months: months,
          );

          // Assert
          expect(result['baseCostPerSqm'], 1090000.0);
          expect(result['priceAfterLocation'], 1090000.0);
          expect(result['pricePerSqm'], 1090000.0);
          expect(result['totalValue'], 109000000.0);
          expect(result['monthlyInstallment'], 10900000.0);
          expect(result['lastInstallment'], 10900000.0); // لا توجد فجوة تقريب
        },
      );

      test(
        'applies "الموقع" coefficient first then other coefficients correctly',
        () {
          // Arrange
          const double area = 100.0;
          const int months = 10;
          final coefficients = {
            'الموقع': 0.10, // زيادة 10%
            'واجهة': 0.05, // زيادة 5%
          };
          // Base = 1,090,000
          // After Location = 1,090,000 * 1.10 = 1,199,000
          // Final Price Per Sqm = 1,199,000 * 1.05 = 1,258,950
          // Total = 1,258,950 * 100 = 125,895,000

          // Act
          final result = CalculatorHelper.calculateContractValues(
            area: area,
            currentPrices: dummyPrices,
            months: months,
            coefficients: coefficients,
          );

          // Assert
          expect(result['priceAfterLocation'], 1199000.0);
          expect(result['pricePerSqm'], 1258950.0);
          expect(result['totalValue'], 125895000.0);
        },
      );

      test(
        'absorbs the financial gap in the last installment due to rounding to 10',
        () {
          // Arrange
          // Total = 109,000,000. Months = 12.
          // 109,000,000 / 12 = 9,083,333.333...
          // Round to nearest 10 -> 9,083,330
          // Monthly = 9,083,330.
          // 11 months * 9,083,330 = 99,916,630
          // Last Installment = 109,000,000 - 99,916,630 = 9,083,370
          const double area = 100.0;
          const int months = 12;

          // Act
          final result = CalculatorHelper.calculateContractValues(
            area: area,
            currentPrices: dummyPrices,
            months: months,
          );

          // Assert
          expect(result['totalValue'], 109000000.0);
          expect(result['monthlyInstallment'], 9083330.0);
          expect(
            result['lastInstallment'],
            9083370.0,
          ); // 🌟 الدفعة الأخيرة أخذت الفجوة (40 ليرة)
        },
      );

      test('handles extreme cases gracefully (zero months and zero area)', () {
        // Arrange
        const double area = 0.0;
        const int months = 0;

        // Act
        final result = CalculatorHelper.calculateContractValues(
          area: area,
          currentPrices: dummyPrices,
          months: months,
        );

        // Assert
        expect(result['totalValue'], 0.0);
        expect(result['monthlyInstallment'], 0.0);
        expect(result['lastInstallment'], 0.0);
        expect(
          result['baseCostPerSqm'],
          1090000.0,
        ); // التكلفة الأساسية لا تتأثر بالمساحة
      });
    });

    // =========================================================
    // اختبارات الخصم القديمة (التي كانت موجودة مسبقاً)
    // =========================================================
    group('applySpecialDiscount', () {
      test('applies long-term VIP discount (30%) when loyalYears > 5', () {
        expect(CalculatorHelper.applySpecialDiscount(1000.0, true, 6), 700.0);
      });

      test('applies standard VIP discount (15%) when loyalYears <= 5', () {
        expect(CalculatorHelper.applySpecialDiscount(1000.0, true, 5), 850.0);
      });

      test(
        'applies loyalty discount (10%) when loyalYears > 2 and non-VIP',
        () {
          expect(
            CalculatorHelper.applySpecialDiscount(1000.0, false, 3),
            900.0,
          );
        },
      );

      test('throws ArgumentError when originalPrice is negative', () {
        expect(
          () => CalculatorHelper.applySpecialDiscount(-100.0, true, 6),
          throwsArgumentError,
        );
      });
    });
  });
}
