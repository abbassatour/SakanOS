// lib/payments/widgets/dialogs/verify_pin_dialog.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/env/env.dart';

Future<bool> showVerifyPinDialog({
  required BuildContext context,
  String? correctPin, // نجعله اختيارياً
  String? message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _VerifyPinDialogContent(
      correctPin: correctPin ?? Env.adminPin, // 🌟 استخدام الرمز المشفر هنا
      message: message ?? 'هذه العملية حساسة مالياً. يرجى إدخال رمز الأمان:',
    ),
  );

  return result ?? false;
}

class _VerifyPinDialogContent extends StatefulWidget {
  const _VerifyPinDialogContent({
    required this.correctPin,
    required this.message,
  });

  final String correctPin;
  final String message;

  @override
  State<_VerifyPinDialogContent> createState() =>
      _VerifyPinDialogContentState();
}

class _VerifyPinDialogContentState extends State<_VerifyPinDialogContent> {
  late final TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_pinController.text == widget.correctPin) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرمز غير صحيح! ❌'),
          backgroundColor: Colors.red,
        ),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'التحقق من الصلاحية',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 10,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 12,
            ),
            onSubmitted: (_) => _verify(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
              hintText: '****',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _verify,
          child: const Text('تأكيد'),
        ),
      ],
    );
  }
}
