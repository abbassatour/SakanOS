// lib/schedule/view/dialogs/take_action_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/schedule_cubit.dart';

void showTakeActionDialog(BuildContext parentContext, Contract contract) {
  final noteController = TextEditingController();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;

      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.handshake, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              l10n.scheduleActionTitle,
              style: const TextStyle(color: Colors.teal),
            ),
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
                child: Text(
                  l10n.scheduleActionDesc,
                  style: const TextStyle(color: Colors.teal, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: l10n.scheduleActionNoteLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check),
            label: Text(l10n.scheduleActionSaveBtn),
            onPressed: () async {
              if (noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(l10n.scheduleActionNoteError),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text(l10n.scheduleActionLoading),
                ),
              );

              await parentContext.read<ScheduleCubit>().markContractActionTaken(
                contract.id,
                noteController.text.trim(),
              );

              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(l10n.scheduleActionSuccess),
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
