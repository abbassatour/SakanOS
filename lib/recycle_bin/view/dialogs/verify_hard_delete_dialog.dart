import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

void showVerifyHardDeleteDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
}) {
  final authCubit = context.read<AuthCubit>();
  final l10n = context.l10n;

  if (authCubit.state.isPinGracePeriodActive) {
    onConfirm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.verifyHardDeleteSuccess),
        backgroundColor: Colors.green,
      ),
    );
    return;
  }

  final pinController = TextEditingController();
  final String correctPin = authCubit.state.securityPin;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            l10n.verifyHardDeleteTitle,
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
          Text(
            l10n.verifyHardDeleteMessage(itemName),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, letterSpacing: 4),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.verifyHardDeletePinHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
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
          onPressed: () {
            if (pinController.text == correctPin) {
              authCubit.markPinVerified();
              Navigator.pop(ctx);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.verifyHardDeleteSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(l10n.pinErrorInvalid),
                  backgroundColor: Colors.red,
                ),
              );
              pinController.clear();
            }
          },
          child: Text(l10n.verifyHardDeleteConfirmBtn),
        ),
      ],
    ),
  );
}
