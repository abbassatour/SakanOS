// lib/settings/view/dialogs/add_historical_price_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/settings_cubit.dart';
import '../settings_page.dart'; // 🌟 لاستيراد ThousandsFormatter منها

void showAddHistoricalPriceDialog(BuildContext parentContext) {
  final ironController = TextEditingController();
  final cementController = TextEditingController();
  final blockController = TextEditingController();
  final formworkController = TextEditingController();
  final aggregatesController = TextEditingController();
  final workerController = TextEditingController();

  DateTime selectedDate = DateTime.now().subtract(
    const Duration(days: 30),
  ); // افتراضياً قبل شهر

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.history_edu, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'إضافة تسعيرة قديمة (تاريخية)',
                  style: TextStyle(color: Colors.indigo),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ستُحفظ هذه التسعيرة في السجل لغايات إحصائية ومحاسبية تفيد في تسعير العقود والدفعات القديمة.',
                        style: TextStyle(color: Colors.indigo, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📅 اختيار التاريخ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.indigo.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '📅 تاريخ سريان التسعيرة:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.edit_calendar,
                              color: Colors.indigo,
                            ),
                            label: Text(
                              '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() => selectedDate = pickedDate);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // 💰 حقول الإدخال
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ironController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'الحديد (كغ)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cementController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'الإسمنت (كيس)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: blockController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'بلوك 15',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: formworkController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'كوفراج (م³)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: aggregatesController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'مواد حصوية (م³)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: workerController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'أجرة العامل',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text('حفظ التسعيرة التاريخية'),
                onPressed: () async {
                  if (ironController.text.isEmpty ||
                      cementController.text.isEmpty ||
                      blockController.text.isEmpty ||
                      formworkController.text.isEmpty ||
                      aggregatesController.text.isEmpty ||
                      workerController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء تعبئة جميع أسعار المواد!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('جاري إضافة التسعيرة للسجل... ⏳'),
                      ),
                    );

                    // 🌟 مسح الفواصل قبل التحويل والحفظ
                    await parentContext
                        .read<SettingsCubit>()
                        .addHistoricalPrice(
                          effectiveDate: selectedDate,
                          iron: double.parse(
                            ironController.text.replaceAll(',', ''),
                          ),
                          cement: double.parse(
                            cementController.text.replaceAll(',', ''),
                          ),
                          block15: double.parse(
                            blockController.text.replaceAll(',', ''),
                          ),
                          formwork: double.parse(
                            formworkController.text.replaceAll(',', ''),
                          ),
                          aggregates: double.parse(
                            aggregatesController.text.replaceAll(',', ''),
                          ),
                          worker: double.parse(
                            workerController.text.replaceAll(',', ''),
                          ),
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('تمت الإضافة للسجل بنجاح! ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
