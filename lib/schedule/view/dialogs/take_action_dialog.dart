// lib/schedule/view/dialogs/take_action_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/schedule_cubit.dart';

void showTakeActionDialog(BuildContext parentContext, Contract contract) {
  final noteController = TextEditingController();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.handshake, color: Colors.teal),
            SizedBox(width: 8),
            Text('تسجيل إجراء إداري', style: TextStyle(color: Colors.teal)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'سيسجل النظام هذا الإجراء ويقوم بتأخير تنبيه هذا العقد ووضعه في أسفل قائمة الرادار لمدة شهر كامل.',
                  style: TextStyle(color: Colors.teal, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText:
                      'ما هو الإجراء الذي تم؟ (مثال: تم الاتصال ووعد بالدفع)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
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
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check),
            label: const Text('حفظ وإخفاء التنبيه'),
            onPressed: () async {
              if (noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('الرجاء كتابة الملاحظة!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext); // إغلاق النافذة

              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('جاري حفظ الإجراء وإعادة ترتيب الرادار... ⏳'),
                ),
              );

              await parentContext.read<ScheduleCubit>().markContractActionTaken(
                contract.id,
                noteController.text.trim(),
              );

              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الإجراء بنجاح! ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
