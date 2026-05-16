// lib\core\utils\calculator_helper.dart
import 'package:erp_repository/erp_repository.dart';

class CalculatorHelper {
  // 🛡️ مساعد التقريب المالي (لأقرب 10 ليرات)
  static double _roundTo10(double val) => (val / 10).round() * 10.0;

  /// محرك حساب تكلفة المتر الأساسي مطابق تماماً لمعادلات الإكسل
  /// 🌟 مع تطبيق التحصين المالي (التقريب لأقرب 10 ليرات)
  static Map<String, double> calculateContractValues({
    required double area,
    required MaterialPricesHistoryData currentPrices,
    int months = 48,
    Map<String, double> coefficients = const {}, 
  }) {
    // -----------------------------------------------------
    // 1. حساب تكلفة المتر المربع الواحد (التكلفة الخام)
    // -----------------------------------------------------
    // نترك الحسابات الوسيطة بـ double دقيق لضمان عدم تراكم أخطاء التقريب
    double baseCostPerSqm = 
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
    double priceAfterLocation = baseCostPerSqm + (baseCostPerSqm * locationCoefficient);

    // -----------------------------------------------------
    // 3. تجميع وتطبيق باقي المعاملات على (السعر بعد الموقع)
    // -----------------------------------------------------
    double otherExtraPercentage = 0.0;
    coefficients.forEach((key, value) {
      if (key != 'الموقع') {
        otherExtraPercentage += value;
      }
    });

    double finalPricePerSqmRaw = priceAfterLocation + (priceAfterLocation * otherExtraPercentage);
    
    // 🛡️ [التحصين الأول]: تقريب سعر المتر النهائي لأقرب 10 ليرات
    double finalPricePerSqm = _roundTo10(finalPricePerSqmRaw);

    // -----------------------------------------------------
    // 4. الحسابات النهائية للعقد (الإجمالي والقسط)
    // -----------------------------------------------------
    
    // الإجمالي = السعر (المقرب لـ 10) × المساحة (الدقيقة)
    double totalValueRaw = finalPricePerSqm * area;
    
    // 🛡️ [التحصين الثاني]: تقريب إجمالي قيمة العقد لأقرب 10 ليرات
    double totalValue = _roundTo10(totalValueRaw);

    // 🛡️ [التحصين الثالث]: تقريب القسط الشهري لأقرب 10 ليرات
    double monthlyInstallment = _roundTo10(totalValue / months);

    return {
      'baseCostPerSqm': _roundTo10(baseCostPerSqm),     // حتى القيم الوسيطة نعرضها نظيفة
      'priceAfterLocation': _roundTo10(priceAfterLocation),
      'pricePerSqm': finalPricePerSqm, 
      'totalValue': totalValue,
      'monthlyInstallment': monthlyInstallment,
    };
  }
}