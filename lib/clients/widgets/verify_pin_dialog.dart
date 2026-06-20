// مسار الملف: lib/clients/widgets/verify_pin_dialog.dart
// المسؤولية: عرض نافذة لإدخال رمز الأمان والتحقق منه قبل تنفيذ العمليات الحساسة (تعديل/حذف).

import 'package:flutter/material.dart';

Future<bool> showVerifyPinDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _VerifyPinDialogContent(),
  );
  return result ?? false;
}

class _VerifyPinDialogContent extends StatefulWidget {
  const _VerifyPinDialogContent();

  @override
  State<_VerifyPinDialogContent> createState() => _VerifyPinDialogContentState();
}

class _VerifyPinDialogContentState extends State<_VerifyPinDialogContent> {
  late final TextEditingController _pinController;
  static const String _correctPin = '0000'; // الرمز الافتراضي للإدارة

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose(); // تنظيف الذاكرة بشكل آمن
    super.dispose();
  }

  void _verifyPin() {
    if (_pinController.text == _correctPin) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرمز غير صحيح! ❌',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.security, color: Colors.red.shade700, size: 28),
          ),
          const SizedBox(width: 16),
          const Text(
            'تأكيد الصلاحية',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هذه العملية حساسة ومراقبة. يرجى إدخال رمز الأمان (PIN) الخاص بالإدارة للمتابعة.',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              autofocus: true,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 24,
                fontWeight: FontWeight.bold,
              ),
              onSubmitted: (_) => _verifyPin(), // دعم زر الإدخال في الكيبورد
              decoration: InputDecoration(
                hintText: '----',
                hintStyle: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 32,
                  letterSpacing: 24,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _verifyPin,
          icon: const Icon(Icons.check_circle),
          label: const Text(
            'تأكيد الصلاحية',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}