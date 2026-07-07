// lib/schedule/view/dialogs/reschedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/schedule_cubit.dart';
import 'package:our_home_erp_app/env/env.dart';

void showRescheduleDialog(BuildContext parentContext, Contract contract) {
  final monthsController = TextEditingController();
  final pinController = TextEditingController(); // 🌟 حقل الرمز السري
  DateTime selectedStartDate = DateTime.now();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.autorenew, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'إعادة جدولة الأقساط المتبقية',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'هذه العملية ستقوم بحذف جميع الأقساط المعلقة واستبدالها بأقساط جديدة. الأقساط القديمة (المدفوعة) لن تتأثر إطلاقاً للحفاظ على السجل المالي.',
                            style: TextStyle(color: Colors.brown, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📅 تاريخ أول قسط جديد:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.edit_calendar,
                            color: Colors.blue,
                          ),
                          label: Text(
                            '${selectedStartDate.year}/${selectedStartDate.month}/${selectedStartDate.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedStartDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null)
                              setState(() => selectedStartDate = pickedDate);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: monthsController,
                    decoration: const InputDecoration(
                      labelText: 'على كم شهر تريد تقسيط الأمتار المتبقية؟',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timelapse),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // 🌟 إجبار إدخال الرمز السري الصارم
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      letterSpacing: 8,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'رمز الإدارة السري للتأكيد',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text('اعتماد الجدولة الجديدة'),
                onPressed: () async {
                  if (pinController.text != Env.adminPin) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('رمز الإدارة غير صحيح! ❌'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final int? newMonths = int.tryParse(monthsController.text);
                  if (newMonths == null || newMonths <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء إدخال عدد أشهر صحيح!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'جاري إعادة هيكلة الأقساط وتسوية السجلات... ⏳',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );

                    await parentContext
                        .read<ScheduleCubit>()
                        .restructureSchedule(
                          contractId: contract.id,
                          newRemainingMonths: newMonths,
                          newStartDate: selectedStartDate,
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text('تمت الجدولة بنجاح! ✅'),
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
