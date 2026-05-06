// lib/payments/view/dialogs/add_payment_dialog.dart
import 'dart:convert'; // 🌟 لفك تشفير معاملات العقد
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/payments_cubit.dart';
import '../../../contracts/view/dialogs/verify_pin_dialog.dart'; 

// 🌟 استدعاء أدوات الحساب والأسعار
import '../../../settings/cubit/settings_cubit.dart';
import 'package:our_home_erp_app/core/utils/calculator_helper.dart';
import 'package:local_storage_api/local_storage_api.dart';

// ==========================================
// 🌟 أداة تنسيق الأرقام (تضع فاصلة لكل 3 أرقام أثناء الكتابة)
// ==========================================
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    
    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// دالة مساعدة سريعة لتنسيق العرض
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

void showAddPaymentDialog(BuildContext parentContext, String contractId) {
  final amountController = TextEditingController();
  final discountController = TextEditingController(text: '0'); 

  // 🌟 المتغير للتحكم بنوع الدفعة (موجب أم سالب)
  bool isDeposit = true; // True = قبض إيداع | False = استرداد / سحب

  bool isHistoricalPayment = false;
  bool isDetailedMode = false; 
  DateTime selectedHistoricalDate = DateTime.now();
  
  final meterPriceCtrl = TextEditingController(); 
  
  final histIronCtrl = TextEditingController(); 
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  // 🌟 جلب العقد الحالي وأسعار اليوم من الـ Cubits لعمل المحاكاة الحية
  final contract = parentContext.read<PaymentsCubit>().state.contracts.firstWhere((c) => c.id == contractId);
  final currentPrices = parentContext.read<SettingsCubit>().state.currentPrices;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          
          // 1. قراءة المبلغ ونسبة الخصم
          double rawAmount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
          double discountPct = double.tryParse(discountController.text) ?? 0;
          double effectiveAmount = rawAmount + (rawAmount * (discountPct / 100));
          
          // 2. 🌟 محرك الحساب اللحظي لسعر المتر والأمتار
          double calculatedMeterPrice = 0.0;

          if (isHistoricalPayment && !isDetailedMode) {
            // حالة الإدخال اليدوي المباشر لسعر المتر
            calculatedMeterPrice = double.tryParse(meterPriceCtrl.text.replaceAll(',', '')) ?? 0;
          } else {
            // حالة الحساب الآلي (سواء أسعار اليوم أو مواد تاريخية)
            MaterialPricesHistoryData? targetPrices;
            
            if (isHistoricalPayment && isDetailedMode) {
              targetPrices = MaterialPricesHistoryData(
                id: 'dummy', effectiveDate: DateTime.now(), userId: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false, isSynced: false,
                ironPrice: double.tryParse(histIronCtrl.text.replaceAll(',', '')) ?? 0,
                cementPrice: double.tryParse(histCementCtrl.text.replaceAll(',', '')) ?? 0,
                block15Price: double.tryParse(histBlockCtrl.text.replaceAll(',', '')) ?? 0,
                formworkAndPouringWages: double.tryParse(histFormworkCtrl.text.replaceAll(',', '')) ?? 0,
                aggregateMaterialsPrice: double.tryParse(histAggregatesCtrl.text.replaceAll(',', '')) ?? 0,
                ordinaryWorkerWage: double.tryParse(histWorkerCtrl.text.replaceAll(',', '')) ?? 0,
              );
            } else {
              targetPrices = currentPrices;
            }

            if (targetPrices != null) {
              try {
                // استخراج معاملات العقد للضرب
                final coeffs = jsonDecode(contract.coefficients) as Map<String, dynamic>;
                final parsedCoeffs = coeffs.map((k, v) => MapEntry(k, (v as num).toDouble()));
                
                final calculations = CalculatorHelper.calculateContractValues(
                  area: contract.totalArea > 0 ? contract.totalArea : 1.0, // حماية القسمة
                  currentPrices: targetPrices,
                  coefficients: parsedCoeffs,
                );
                calculatedMeterPrice = calculations['pricePerSqm'] ?? 0;
              } catch (_) {
                calculatedMeterPrice = 0;
              }
            }
          }

          // 3. حساب الأمتار المحولة أو المخصومة
          double previewMeters = calculatedMeterPrice > 0 ? (effectiveAmount / calculatedMeterPrice) : 0;

          // ألوان متغيرة حسب النوع
          Color mainColor = isDeposit ? Colors.deepOrange : Colors.red.shade800;
          String titleText = isDeposit ? 'إدخال دفعة (إيداع)' : 'سحب / استرداد مبلغ';

          return AlertDialog(
            title: Row(
              children:[
                Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: mainColor),
                const SizedBox(width: 8),
                Text(titleText, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 500, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    // 🌟 1. مفتاح تغيير نوع العملية (إيداع أو سحب)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300)
                      ),
                      child: Row(
                        children:[
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('إيداع (قبض)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              value: true,
                              groupValue: isDeposit,
                              activeColor: Colors.deepOrange,
                              onChanged: (val) => setState(() => isDeposit = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('استرداد (سحب)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                              value: false,
                              groupValue: isDeposit,
                              activeColor: Colors.red,
                              onChanged: (val) async {
                                bool authorized = await showVerifyPinDialog(parentContext);
                                if (authorized) {
                                  setState(() => isDeposit = val!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 2. مفتاح الدفعة القديمة
                    Container(
                      decoration: BoxDecoration(
                        color: isHistoricalPayment ? Colors.blue.shade50 : Colors.transparent,
                        border: Border.all(color: isHistoricalPayment ? Colors.blue : Colors.transparent),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: SwitchListTile(
                        title: const Text('إدخال عملية قديمة (تاريخية)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        subtitle: const Text('لتسجيل حركات سابقة وإدخال سعر المتر يدوياً.'),
                        value: isHistoricalPayment,
                        activeColor: Colors.blue,
                        onChanged: (val) async {
                          if (val) {
                            bool authorized = await showVerifyPinDialog(parentContext);
                            if (authorized) {
                              setState(() => isHistoricalPayment = true);
                              final pickedDate = await showDatePicker(
                                context: dialogContext, initialDate: selectedHistoricalDate,
                                firstDate: DateTime(2000), lastDate: DateTime.now(),
                                builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.blue)), child: child!),
                              );
                              if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                            }
                          } else {
                            setState(() { isHistoricalPayment = false; isDetailedMode = false; });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🌟 3. إعدادات التاريخ والمواد 
                    if (isHistoricalPayment) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blue.shade300, width: 2), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('📅 تاريخ العملية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade700, elevation: 0,
                                    side: BorderSide(color: Colors.blue.shade300, width: 2), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.calendar_month, size: 22),
                                  label: Text('${selectedHistoricalDate.year}/${selectedHistoricalDate.month}/${selectedHistoricalDate.day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    final pickedDate = await showDatePicker(context: dialogContext, initialDate: selectedHistoricalDate, firstDate: DateTime(2000), lastDate: DateTime.now(), builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.blue)), child: child!));
                                    if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.blue),
                            
                            Row(
                              children:[
                                Expanded(child: RadioListTile<bool>(title: const Text('إدخال مباشر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: const Text('سعر المتر فقط', style: TextStyle(fontSize: 11)), value: false, groupValue: isDetailedMode, onChanged: (val) => setState(() => isDetailedMode = val!), activeColor: Colors.blue, contentPadding: EdgeInsets.zero)),
                                Expanded(child: RadioListTile<bool>(title: const Text('إدخال تفصيلي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: const Text('مواد تُحفظ بالسجل', style: TextStyle(fontSize: 11)), value: true, groupValue: isDetailedMode, onChanged: (val) => setState(() => isDetailedMode = val!), activeColor: Colors.blue, contentPadding: EdgeInsets.zero)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            if (!isDetailedMode)
                              TextField(controller: meterPriceCtrl, inputFormatters:[ThousandsFormatter()], decoration: const InputDecoration(labelText: 'سعر المتر المربع في ذلك الوقت (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed, color: Colors.blue), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))
                            else
                              Column(
                                children: [
                                  Row(children:[Expanded(child: TextField(controller: histIronCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الحديد', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))), const SizedBox(width: 8), Expanded(child: TextField(controller: histCementCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الإسمنت', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {})))]),
                                  const SizedBox(height: 8),
                                  Row(children:[Expanded(child: TextField(controller: histBlockCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'البلوك 15', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))), const SizedBox(width: 8), Expanded(child: TextField(controller: histFormworkCtrl, inputFormatters:[ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الكوفراج', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {})))]),
                                  const SizedBox(height: 8),
                                  Row(children:[Expanded(child: TextField(controller: histAggregatesCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'المواد الحصوية', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))), const SizedBox(width: 8), Expanded(child: TextField(controller: histWorkerCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'أجرة العامل', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(() {})))]),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 🌟 4. حقول المبلغ الأساسية
                    TextField(
                      controller: amountController,
                      inputFormatters:[ThousandsFormatter()], 
                      decoration: InputDecoration(
                        labelText: isDeposit ? 'المبلغ المدفوع (ل.س)' : 'المبلغ المسترد / المسحوب (ل.س)', 
                        border: const OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money, color: mainColor),
                        filled: true, fillColor: isDeposit ? Colors.white : Colors.red.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: isDeposit ? 'نسبة الخصم / البونص المئوية' : 'نسبة البونص المُراد استرجاعها', 
                        border: const OutlineInputBorder(), suffixText: '%', prefixIcon: Icon(Icons.percent, color: mainColor),
                        filled: true, fillColor: isDeposit ? Colors.white : Colors.red.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 🌟 5. نافذة المعاينة (Live Preview) المطورة
                    // ==========================================
                    if (rawAmount > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDeposit ? Colors.green.shade50 : Colors.red.shade50, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDeposit ? Colors.green : Colors.red.shade200, width: 2)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text(isDeposit ? 'المبلغ المعتمد للتحويل:' : 'الرقم الإجمالي الذي سيُخصم من الرصيد:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                            Text(
                              '${isDeposit ? '' : '- '}${formatWithCommas(effectiveAmount)} ل.س',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDeposit ? Colors.green.shade800 : Colors.red.shade800),
                            ),
                            
                            // 🌟 عرض تفاصيل سعر المتر والأمتار المحسوبة
                            if (calculatedMeterPrice > 0) ...[
                              const Divider(height: 24),
                              Text('سعر المتر المعتمد لعملية التحويل:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                              Text('${formatWithCommas(calculatedMeterPrice)} ل.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              
                              const SizedBox(height: 8),
                              Text(isDeposit ? 'الأمتار المضافة لرصيد العميل:' : 'الأمتار المخصومة من رصيد العميل:', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                              Text(
                                '${isDeposit ? '+ ' : '- '}${previewMeters.toStringAsFixed(3)} م²',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDeposit ? Colors.blue.shade700 : Colors.red.shade800),
                              ),
                            ] else ...[
                              const Divider(height: 24),
                              const Row(
                                children:[
                                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('يرجى التأكد من إدخال تسعيرة المواد ليتمكن النظام من حساب الأمتار.', style: TextStyle(color: Colors.red, fontSize: 12))),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: mainColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: rawAmount > 0 && calculatedMeterPrice > 0 ? () {
                  
                  if (isHistoricalPayment) {
                    if (!isDetailedMode && meterPriceCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء إدخال سعر المتر!'), backgroundColor: Colors.red));
                      return;
                    }
                    if (isDetailedMode && (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty)) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء إدخال جميع أسعار المواد!'), backgroundColor: Colors.red));
                      return;
                    }
                  }

                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text(isDeposit ? 'جاري إضافة الدفعة وتحديث الأمتار...' : 'جاري خصم المبلغ والأمتار...'), duration: const Duration(seconds: 1)),
                  );

                  final double finalAmountToSave = isDeposit ? rawAmount : (rawAmount * -1);

                  parentContext.read<PaymentsCubit>().addLedgerEntry(
                    contractId: contractId,
                    amountPaid: finalAmountToSave, 
                    discountPercentage: discountPct, 
                    customDate: isHistoricalPayment ? selectedHistoricalDate : null,
                    customMeterPrice: isHistoricalPayment && !isDetailedMode ? double.parse(meterPriceCtrl.text.replaceAll(',', '')) : null,
                    
                    histIron: isHistoricalPayment && isDetailedMode ? double.parse(histIronCtrl.text.replaceAll(',', '')) : null,
                    histCement: isHistoricalPayment && isDetailedMode ? double.parse(histCementCtrl.text.replaceAll(',', '')) : null,
                    histBlock: isHistoricalPayment && isDetailedMode ? double.parse(histBlockCtrl.text.replaceAll(',', '')) : null,
                    histFormwork: isHistoricalPayment && isDetailedMode ? double.parse(histFormworkCtrl.text.replaceAll(',', '')) : null,
                    histAggregates: isHistoricalPayment && isDetailedMode ? double.parse(histAggregatesCtrl.text.replaceAll(',', '')) : null,
                    histWorker: isHistoricalPayment && isDetailedMode ? double.parse(histWorkerCtrl.text.replaceAll(',', '')) : null,
                  );
                } : null, 
                child: Text(isDeposit ? 'تأكيد وحفظ الدفعة' : 'تأكيد السحب', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}