import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/settings_cubit.dart';
import '../settings_page.dart';

void showAddHistoricalPriceDialog(BuildContext parentContext) {
  final ironController = TextEditingController();
  final cementController = TextEditingController();
  final blockController = TextEditingController();
  final formworkController = TextEditingController();
  final aggregatesController = TextEditingController();
  final workerController = TextEditingController();

  DateTime selectedDate = DateTime.now().subtract(
    const Duration(days: 30),
  );

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.history_edu, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  l10n.addHistPriceTitle,
                  style: const TextStyle(color: Colors.indigo),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.addHistPriceDesc,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                            l10n.addHistPriceEffectiveDate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.edit_calendar,
                              color: Colors.indigo,
                            ),
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
                                lastDate: DateTime.now(),
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
                    const Divider(),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ironController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsIronLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cementController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsCementLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: blockController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsBlockLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: formworkController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsFormworkLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: aggregatesController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsAggregatesLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: workerController,
                            inputFormatters: [ThousandsFormatter()],
                            decoration: InputDecoration(
                              labelText: l10n.settingsWorkerLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.save),
                label: Text(l10n.addHistPriceSaveBtn),
                onPressed: () async {
                  if (ironController.text.isEmpty ||
                      cementController.text.isEmpty ||
                      blockController.text.isEmpty ||
                      formworkController.text.isEmpty ||
                      aggregatesController.text.isEmpty ||
                      workerController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.addHistPriceFillAllWarning),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.addHistPriceSaving),
                      ),
                    );

                    await parentContext
                        .read<SettingsCubit>()
                        .addHistoricalPrice(
                          effectiveDate: selectedDate,
                          iron: double.parse(
                            ironController.text.replaceAll(',', ''),
                          ),
                          cement: double.parse(
                            cementController.text.replaceAll(',', ''),
                          ),
                          block15: double.parse(
                            blockController.text.replaceAll(',', ''),
                          ),
                          formwork: double.parse(
                            formworkController.text.replaceAll(',', ''),
                          ),
                          aggregates: double.parse(
                            aggregatesController.text.replaceAll(',', ''),
                          ),
                          worker: double.parse(
                            workerController.text.replaceAll(',', ''),
                          ),
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(l10n.addHistPriceSuccess),
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
