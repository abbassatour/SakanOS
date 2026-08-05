// lib/clients/widgets/verify_pin_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

Future<bool> showVerifyPinDialog(BuildContext context) async {
  final authCubit = context.read<AuthCubit>();

  if (authCubit.state.isPinGracePeriodActive) {
    return true;
  }

  final correctPin = authCubit.state.securityPin;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _VerifyPinDialogContent(correctPin: correctPin),
  );

  if (result == true) {
    authCubit.markPinVerified();
  }

  return result ?? false;
}

class _VerifyPinDialogContent extends StatefulWidget {
  const _VerifyPinDialogContent({required this.correctPin});
  final String correctPin;

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

  void _verifyPin() {
    final l10n = context.l10n;
    if (_pinController.text == widget.correctPin) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pinErrorInvalid,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          Text(
            l10n.pinDialogTitle,
            style: const TextStyle(
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
            Text(
              l10n.pinDialogSubtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 10,
              autofocus: true,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 24,
                fontWeight: FontWeight.bold,
              ),
              onSubmitted: (_) => _verifyPin(),
              decoration: InputDecoration(
                hintText: '****',
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
          child: Text(
            l10n.btnCancel,
            style: const TextStyle(
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
          label: Text(
            l10n.btnConfirmPin,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
