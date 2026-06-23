// contracts/widgets/add_contract/financial_section.dart

import 'package:flutter/material.dart';

import 'package:our_home_erp_app/core/utils/formatters.dart';

class FinancialSection extends StatelessWidget {
  const FinancialSection({
    required this.isAllocated,
    required this.isHistoricalContract,
    required this.isDollarContract,
    required this.onDollarToggle,
    required this.histDollarRateCtrl,
    required this.currentDollarRate,
    required this.onInputChanged,
    required this.areaController,
    required this.monthsController,
    required this.durationCoefficientCtrl,
    required this.priceController,
    required this.monthlyAmountCtrl,
    required this.downPaymentCtrl,
    required this.onCalculate,
    super.key,
  });

  final bool isAllocated;
  final bool isHistoricalContract;
  final bool isDollarContract;
  final ValueChanged<bool>? onDollarToggle;
  final TextEditingController histDollarRateCtrl;
  final double? currentDollarRate;
  final ValueChanged<String>? onInputChanged;
  final TextEditingController areaController;
  final TextEditingController monthsController;
  final TextEditingController durationCoefficientCtrl;
  final TextEditingController priceController;
  final TextEditingController monthlyAmountCtrl;
  final TextEditingController downPaymentCtrl;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    var exchangeRate = 1.0;
    if (isDollarContract) {
      if (isHistoricalContract) {
        exchangeRate = double.tryParse(
              histDollarRateCtrl.text.replaceAll(',', ''),
            ) ??
            0.0;
      } else if (currentDollarRate != null) {
        exchangeRate = currentDollarRate!;
      }
    }

    final downPaymentVal = double.tryParse(
          downPaymentCtrl.text.replaceAll(',', ''),
        ) ??
        0.0;
    final monthlyVal = double.tryParse(
          monthlyAmountCtrl.text.replaceAll(',', ''),
        ) ??
        0.0;

    final sypDownPayment = downPaymentVal * exchangeRate;
    final sypMonthly = monthlyVal * exchangeRate;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDollarContract ? Colors.green.shade50 : Colors.white,
                border: Border.all(
                  color: isDollarContract ? Colors.green : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'إدخال المقدم والقسط بالدولار الأمريكي (USD)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDollarContract
                            ? Colors.green.shade700
                            : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: isHistoricalContract
                        ? const Text(
                            'سعر الصرف القديم يجب إدخاله أدناه',
                            style: TextStyle(color: Colors.green),
                          )
                        : (currentDollarRate != null
                            ? Text(
                                'سعر الصرف الحالي: '
                                '${NumberFormatters.formatWithCommas(
                                  currentDollarRate!,
                                )} ل.س',
                                style: TextStyle(
                                  color: isDollarContract
                                      ? Colors.green.shade900
                                      : Colors.grey,
                                ),
                              )
                            : const Text(
                                '⚠️ جاري تحميل التسعيرة أو لم يتم تعيينها',
                                style: TextStyle(color: Colors.red),
                              )),
                    value: isDollarContract,
                    activeColor: Colors.green,
                    onChanged:
                        (isHistoricalContract || currentDollarRate != null)
                            ? onDollarToggle
                            : null,
                  ),
                  if (isDollarContract && isHistoricalContract)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: TextField(
                        controller: histDollarRateCtrl,
                        inputFormatters: [ThousandsFormatter()],
                        decoration: InputDecoration(
                          labelText: 'سعر صرف 1 دولار وقت العقد (ل.س)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(
                            Icons.history_edu,
                            color: Colors.green,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: onInputChanged,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأساس المالي للعقد',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: downPaymentCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: isDollarContract
                                    ? 'المقدم (دولار)'
                                    : 'الدفعة الأولى (مقدم)',
                                hintText: isDollarContract
                                    ? 'مثال: 5000'
                                    : 'مثال: 5000000',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  isDollarContract
                                      ? Icons.monetization_on
                                      : Icons.price_check,
                                  color: Colors.green,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                            if (isDollarContract && downPaymentVal > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  right: 4,
                                ),
                                child: Text(
                                  '≈ ${NumberFormatters.formatWithCommas(
                                    sypDownPayment,
                                  )} ل.س',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: monthlyAmountCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: isDollarContract
                                    ? 'القسط (دولار)'
                                    : 'القسط الشهري المتفق عليه',
                                hintText: isDollarContract
                                    ? 'مثال: 200'
                                    : 'مثال: 150000',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  isDollarContract
                                      ? Icons.monetization_on_outlined
                                      : Icons.payments_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                            if (isDollarContract && monthlyVal > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  right: 4,
                                ),
                                child: Text(
                                  '≈ ${NumberFormatters.formatWithCommas(
                                    sypMonthly,
                                  )} ل.س',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isAllocated) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: areaController,
                      decoration: const InputDecoration(
                        labelText: 'المساحة الكلية',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: monthsController,
                      decoration: const InputDecoration(
                        labelText: 'المدة (أشهر)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: durationCoefficientCtrl,
                      decoration: const InputDecoration(
                        labelText: 'نسبة التقسيط %',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.orangeAccent,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 محفظة استثمارية: لا يتطلب هذا العقد تحديد مساحة أو '
                  'مدة حالياً. اضغط "حساب" لمعرفة تسعيرة المتر المرجعية فقط.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate),
                label: Text(
                  isHistoricalContract
                      ? 'حساب سعر المتر (تاريخي)'
                      : 'حساب سعر المتر المرجعي (أسعار اليوم)',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHistoricalContract
                      ? Colors.red.shade700
                      : Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              readOnly: !isHistoricalContract,
              inputFormatters: [ThousandsFormatter()],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: isHistoricalContract
                    ? 'سعر المتر المربع (يمكنك تعديله يدوياً)'
                    : 'سعر المتر المربع النهائي (يُحسب آلياً)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isHistoricalContract
                    ? Colors.white
                    : Colors.teal.shade50,
                prefixIcon: isHistoricalContract
                    ? const Icon(Icons.edit, color: Colors.red)
                    : const Icon(Icons.lock, color: Colors.teal),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
