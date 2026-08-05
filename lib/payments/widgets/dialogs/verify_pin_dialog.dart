// lib/payments/widgets/dialogs/verify_pin_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

Future<bool> showVerifyPinDialog({
  required BuildContext context,
  String? correctPin,
  String? message,
}) async {
  final authCubit = context.read<AuthCubit>();
  final l10n = context.l10n;

  if (authCubit.state.isPinGracePeriodActive) {
    return true;
  }

  final pinToUse = correctPin ?? authCubit.state.securityPin;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _VerifyPinDialogContent(
      correctPin: pinToUse,
      message: message ?? l10n.pinDialogSubtitle,
    ),
  );

  if (result == true) {
    authCubit.markPinVerified();
  }

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
    final l10n = context.l10n;
    if (_pinController.text == widget.correctPin) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pinErrorInvalid),
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
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            l10n.pinDialogTitle,
            style: const TextStyle(
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
            style: const TextStyle(fontSize: 24, letterSpacing: 12),
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
          child: Text(
            l10n.btnCancel,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _verify,
          child: Text(l10n.btnConfirmPin),
        ),
      ],
    );
  }
}
