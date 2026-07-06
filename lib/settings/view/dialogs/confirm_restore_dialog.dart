// lib/settings/view/dialogs/confirm_restore_dialog.dart
import 'package:flutter/material.dart';

Future<bool> showConfirmRestoreDialog(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('تحذير خطير'),
        ],
      ),
      content: const Text(
        'استعادة قاعدة بيانات سيؤدي إلى استبدال البيانات الحالية بالكامل وإغلاق النظام.\n\nهل أنت متأكد أنك تريد المتابعة؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('نعم، قم بالاستعادة'),
        ),
      ],
    ),
  );

  return confirm ?? false;
}
