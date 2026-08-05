// lib/schedule/view/dialogs/reschedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/schedule_cubit.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';

void showRescheduleDialog(BuildContext parentContext, Contract contract) {
  final monthsController = TextEditingController();
  final pinController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.autorenew, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.scheduleRescheduleTitle,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.scheduleRescheduleDesc,
                            style: const TextStyle(
                              color: Colors.brown,
                              fontSize: 13,
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
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.scheduleRescheduleDateLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.edit_calendar,
                            color: Colors.blue,
                          ),
                          label: Text(
                            '${selectedStartDate.year}/${selectedStartDate.month}/${selectedStartDate.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedStartDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() => selectedStartDate = pickedDate);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: monthsController,
                    decoration: InputDecoration(
                      labelText: l10n.scheduleRescheduleMonthsLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.timelapse),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      letterSpacing: 8,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.scheduleReschedulePinLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.red),
                    ),
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
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.scheduleRescheduleSaveBtn),
                onPressed: () async {
                  if (pinController.text !=
                      context.read<AuthCubit>().state.securityPin) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scheduleEditDatePinError),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final int? newMonths = int.tryParse(monthsController.text);
                  if (newMonths == null || newMonths <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scheduleRescheduleMonthsError),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.scheduleRescheduleLoading),
                        backgroundColor: Colors.blue,
                      ),
                    );

                    await parentContext
                        .read<ScheduleCubit>()
                        .restructureSchedule(
                          contractId: contract.id,
                          newRemainingMonths: newMonths,
                          newStartDate: selectedStartDate,
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(l10n.scheduleRescheduleSuccess),
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
