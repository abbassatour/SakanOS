// lib/schedule/view/dialogs/edit_single_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show InstallmentsScheduleData;
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/schedule_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';

void showEditSingleScheduleDialog(
  BuildContext parentContext,
  InstallmentsScheduleData schedule,
) {
  final notesController = TextEditingController(text: schedule.notes ?? '');
  DateTime selectedDate = schedule.dueDate.toLocal();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit_calendar, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  l10n.scheduleEditSingleTitle(schedule.installmentNumber),
                  style: const TextStyle(color: Colors.indigo, fontSize: 18),
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
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.scheduleEditSingleDesc,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.indigo.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.scheduleEditSingleDateLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          label: Text(
                            '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() => selectedDate = pickedDate);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l10n.scheduleEditSingleNoteLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 2,
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
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save),
                label: Text(l10n.scheduleEditSingleSave),
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  bool isAuthorized = await showVerifyPinDialog(
                    context: parentContext,
                  );

                  if (isAuthorized && parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scheduleEditSingleLoading),
                      ),
                    );

                    await parentContext
                        .read<ScheduleCubit>()
                        .updateIndividualSchedule(
                          scheduleId: schedule.id,
                          contractId: schedule.contractId,
                          newDueDate: selectedDate,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(l10n.scheduleEditSingleSuccess),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
