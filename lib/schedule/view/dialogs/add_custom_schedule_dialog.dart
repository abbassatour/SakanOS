// lib/schedule/view/dialogs/add_custom_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/schedule_cubit.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

void showAddCustomScheduleDialog(
  BuildContext parentContext,
  String contractId,
) {
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = SecureTime.now();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;

      return StatefulBuilder(
        builder: (context, setState) {
          final double amount =
              double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
          final bool isValid =
              amount > 0 && notesController.text.trim().isNotEmpty;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  l10n.scheduleCustomAddTitle,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.scheduleCustomAddDesc,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.scheduleCustomAddDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade50,
                          foregroundColor: Colors.indigo,
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: Text(
                          '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    inputFormatters: [ThousandsFormatter()],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.scheduleCustomAddAmount,
                      prefixIcon: const Icon(
                        Icons.payments,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l10n.scheduleCustomAddNote,
                      prefixIcon: const Icon(
                        Icons.edit_note,
                        color: Colors.indigo,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.btnCancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: isValid
                    ? () {
                        parentContext
                            .read<ScheduleCubit>()
                            .addCustomSeasonalSchedule(
                              contractId: contractId,
                              dueDate: selectedDate,
                              notes: notesController.text.trim(),
                              expectedAmount: amount,
                            );
                        Navigator.pop(dialogContext);
                      }
                    : null,
                child: Text(
                  l10n.scheduleCustomAddBtn,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
