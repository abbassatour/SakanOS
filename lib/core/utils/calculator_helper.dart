// lib\core\utils\calculator_helper.dart
import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  // 🛡️ مساعد التقريب المالي (لأقرب 10 ليرات)
  static double _roundTo10(double val) => (val / 10).round() * 10.0;

  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices,
    int months = 48,
    Map<String, double> coefficients = const {},
  }) {
    // -----------------------------------------------------
    // 1. حساب تكلفة المتر المربع الواحد (التكلفة الخام)
    // -----------------------------------------------------
    double baseCostPerSqmRaw =
        (currentPrices.ironPrice * 30.0) +
        (currentPrices.cementPrice * 4.0) +
        (currentPrices.block15Price * 50.0) +
        (currentPrices.formworkAndPouringWages * 1.0) +
        (currentPrices.aggregateMaterialsPrice * 2.0) +
        (currentPrices.ordinaryWorkerWage * 1.0);

    // -----------------------------------------------------
    // 2. تطبيق معامل "الموقع" أولاً
    // -----------------------------------------------------
    double locationCoefficient = coefficients['الموقع'] ?? 0.0;
    double priceAfterLocationRaw =
        baseCostPerSqmRaw + (baseCostPerSqmRaw * locationCoefficient);

    // -----------------------------------------------------
    // 3. تجميع وتطبيق باقي المعاملات
    // -----------------------------------------------------
    double otherExtraPercentage = 0.0;
    coefficients.forEach((key, value) {
      if (key != 'الموقع') {
        otherExtraPercentage += value;
      }
    });

    // السعر النهائي للمتر (بدون أي تقريب لاستخدامه في حساب الإجمالي)
    double finalPricePerSqmRaw =
        priceAfterLocationRaw + (priceAfterLocationRaw * otherExtraPercentage);

    // -----------------------------------------------------
    // 4. الحسابات النهائية للعقد (الآن نستخدم القيم الخام)
    // -----------------------------------------------------

    // ✅ الإجمالي = السعر الخام الدقيق × المساحة الدقيقة
    double totalValueRaw = finalPricePerSqmRaw * area;

    // 🛡️ هنا فقط نقوم بالتقريب النهائي للإجمالي
    double finalTotalValue = _roundTo10(totalValueRaw);

    // -----------------------------------------------------
    // 5. معالجة الأقساط باحترافية لتجنب (فجوة الأقساط)
    // -----------------------------------------------------
    double monthlyInstallment = 0.0;
    double lastInstallment = 0.0; // القسط الأخير المعدل

    if (months > 0) {
      // نحسب القسط بناءً على الإجمالي المقرب
      monthlyInstallment = _roundTo10(finalTotalValue / months);

      // ✅ السر المحاسبي: القسط الأخير يمتص أي فجوة ناتجة عن التقريب
      // نضرب القسط في (عدد الأشهر - 1) ونطرحه من الإجمالي لمعرفة القسط الأخير الفعلي
      lastInstallment = finalTotalValue - (monthlyInstallment * (months - 1));
    }

    // -----------------------------------------------------
    // 6. إرجاع النتيجة (نقرب القيم فقط بهدف العرض للمستخدم)
    // -----------------------------------------------------
    return {
      'baseCostPerSqm': _roundTo10(baseCostPerSqmRaw),
      'priceAfterLocation': _roundTo10(priceAfterLocationRaw),
      'pricePerSqm': _roundTo10(
        finalPricePerSqmRaw,
      ), // نقرب سعر المتر للعرض فقط
      'pricePerSqmRaw': finalPricePerSqmRaw,
      'totalValue': finalTotalValue,
      'monthlyInstallment': monthlyInstallment,
      'lastInstallment':
          lastInstallment, // يفضل إرسال القسط الأخير للواجهة وعرضه إذا كان يختلف عن باقي الأقساط
    };
  }

  static double applySpecialDiscount(double originalPrice, bool isVip, int loyalYears) {
    if (isVip && loyalYears > 5) {
      return originalPrice * 0.70; 
    } else if (isVip) {
      return originalPrice * 0.85;
    } else if (loyalYears > 2) {
      return originalPrice * 0.90;
    }
    return originalPrice;
  }
}
