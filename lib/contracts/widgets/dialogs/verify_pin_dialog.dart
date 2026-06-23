// contracts/widgets/dialogs/verify_pin_dialog.dart

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
  State<_VerifyPinDialogContent> createState() =>
      _VerifyPinDialogContentState();
}

class _VerifyPinDialogContentState extends State<_VerifyPinDialogContent> {
  late final TextEditingController _pinController;
  static const String _correctPin = '0000';

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
    if (_pinController.text == _correctPin) {
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
            'تأكيد الصلاحية',
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
          const Text('هذه العملية حساسة مالياً. يرجى إدخال رمز الأمان:'),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 4,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 12,
            ),
            onSubmitted: (_) => _verify(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
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
