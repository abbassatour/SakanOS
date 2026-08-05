import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

Future<bool> showConfirmRestoreDialog(BuildContext context) async {
  final l10n = context.l10n;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(l10n.confirmRestoreTitle),
        ],
      ),
      content: Text(l10n.confirmRestoreMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.btnCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.confirmRestoreConfirmBtn),
        ),
      ],
    ),
  );

  return confirm ?? false;
}
