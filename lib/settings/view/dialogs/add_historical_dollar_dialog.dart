// lib/settings/view/dialogs/add_historical_dollar_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/settings_cubit.dart';

// ==========================================
// 🌟 أداة تنسيق الأرقام محلياً (لتجنب مشاكل الاستيراد)
// ==========================================
class _DialogThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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

// ==========================================
// 🌟 دالة استدعاء الديالوج مع تمرير الـ Cubit
// ==========================================
Future<void> showAddHistoricalDollarDialog(BuildContext parentContext) async {
  final cubit = parentContext.read<SettingsCubit>();
  return showDialog(
    context: parentContext,
    barrierDismissible:
        false, // منع الإغلاق عند النقر خارج المربع لتجنب فقدان البيانات
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: const AddHistoricalDollarDialog(),
    ),
  );
}

// ==========================================
// 🌟 واجهة الديالوج
// ==========================================
class AddHistoricalDollarDialog extends StatefulWidget {
  const AddHistoricalDollarDialog({super.key});

  @override
  State<AddHistoricalDollarDialog> createState() =>
      _AddHistoricalDollarDialogState();
}

class _AddHistoricalDollarDialogState extends State<AddHistoricalDollarDialog> {
  final rateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    rateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // 1. اختيار التاريخ
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // السماح بتواريخ قديمة
      lastDate: DateTime.now(), // عدم السماح بتواريخ في المستقبل
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
            ), // ثيم أخضر
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    // 2. اختيار الوقت المرجعي في ذلك اليوم
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.green.shade700),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    // 3. دمج التاريخ والوقت
    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    final rateStr = rateController.text.replaceAll(',', '');
    final rate = double.tryParse(rateStr) ?? 0;

    if (rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سعر صرف صحيح (أكبر من الصفر)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إرسال الطلب للـ Cubit
    context.read<SettingsCubit>().addHistoricalDollarPrice(
      effectiveDate: selectedDate,
      exchangeRate: rate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت الإضافة بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}";

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.history_toggle_off,
            color: Colors.green.shade700,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text(
            'إضافة سعر دولار قديم',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400, // عرض الديالوج
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'سيتم حفظ هذا السعر في السجل بتاريخ قديم (بأثر رجعي) ليتم استخدامه في إحصائيات وتقييمات تلك الفترة.',
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 🕒 اختيار التاريخ والوقت
              // ==========================================
              const Text(
                'تاريخ سريان التسعيرة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$formattedDate   -   $formattedTime',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.green.shade700, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 💵 حقل السعر
              // ==========================================
              const Text(
                'سعر الصرف (مبيع):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rateController,
                inputFormatters: [_DialogThousandsFormatter()],
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'مثال: 15,000',
                  suffixText: 'ل.س',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.green.shade600,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.green.shade500,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text(
            'حفظ التسعيرة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
