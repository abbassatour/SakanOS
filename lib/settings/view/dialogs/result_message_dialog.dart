import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

void showResultMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final l10n = context.l10n;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.btnOk),
        ),
      ],
    ),
  );
}
