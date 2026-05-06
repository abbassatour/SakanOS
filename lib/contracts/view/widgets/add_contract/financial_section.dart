// lib/contracts/view/widgets/add_contract/financial_section.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart'; 

class FinancialSection extends StatelessWidget {
  final bool isAllocated;
  final bool isHistoricalContract;
  final TextEditingController areaController;
  final TextEditingController monthsController;
  final TextEditingController durationCoefficientCtrl;
  final TextEditingController priceController;
  final TextEditingController monthlyAmountCtrl; 
  final TextEditingController downPaymentCtrl; // 🌟 1. تم تعريف المتحكم الجديد
  final VoidCallback onCalculate;

  const FinancialSection({
    super.key,
    required this.isAllocated,
    required this.isHistoricalContract,
    required this.areaController,
    required this.monthsController,
    required this.durationCoefficientCtrl,
    required this.priceController,
    required this.monthlyAmountCtrl, 
    required this.downPaymentCtrl, // 🌟 2. إضافته في الدالة البانية
    required this.onCalculate,
  });fv Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
            
            // ==========================================
            // 🌟 1. حقول الأساس المالي (الدفعة الأولى + القسط الشهري)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  const Text('الأساس المالي للعقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children:[
                      // 🌟 حقل الدفعة الأولى
                      Expanded(
                        child: TextField(
                          controller: downPaymentCtrl,
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'الدفعة الأولى (مقدم العقد)', 
                            hintText: 'مثال: 5000000',
                            border: OutlineInputBorder(), 
                            filled: true, 
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.price_check, color: Colors.green) // أيقونة خضراء للدفعة
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // حقل القسط الشهري
                      Expanded(
                        child: TextField(
                          controller: monthlyAmountCtrl,
                          inputFormatters:[ThousandsFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'القسط الشهري المتفق عليه', 
                            hintText: 'مثال: 150000',
                            border: OutlineInputBorder(), 
                            filled: true, 
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.payments_outlined, color: Colors.orange)
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🌟 2. إخفاء المساحة والمدة بالكامل إذا كان العقد (لاحق التخصص)
            if (isAllocated) ...[
              Row(
                children:[
                  Expanded(flex: 2, child: TextField(
                    controller: areaController, 
                    decoration: const InputDecoration(labelText: 'المساحة الكلية (مجلوبة آلياً)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
                    readOnly: true,
                  )),
                  const SizedBox(width: 12),
                  // حقل المدة أصبح شكلياً، لذلك سنضيف عليه تلميح
                  Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة  (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة التقسيط %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              // تلميح صغير للموظف لعقود لاحق التخصص
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text('💡 محفظة استثمارية: لا يتطلب هذا العقد تحديد مساحة أو مدة حالياً. اضغط "حساب" لمعرفة تسعيرة المتر المرجعية فقط.', style: TextStyle(color: Colors.blueGrey, fontSize: 12), textAlign: TextAlign.center),
              ),
            ],

            // 🌟 3. زر الحساب وحقل السعر المرجعي
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate),
                label: Text(isHistoricalContract ? 'حساب سعر المتر (تاريخي)' : 'حساب سعر المتر المرجعي (أسعار اليوم)', style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: isHistoricalContract ? Colors.red.shade700 : Colors.teal.shade700, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              readOnly: !isHistoricalContract, 
              inputFormatters:[ThousandsFormatter()], 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: isHistoricalContract ? 'سعر المتر المربع (يمكنك تعديله يدوياً)' : 'سعر المتر المربع النهائي (يُحسب آلياً)', 
                border: const OutlineInputBorder(), 
                filled: true, 
                fillColor: isHistoricalContract ? Colors.white : Colors.teal.shade50,
                prefixIcon: isHistoricalContract ? const Icon(Icons.edit, color: Colors.red) : const Icon(Icons.lock, color: Colors.teal),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}