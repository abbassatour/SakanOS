// lib/payments/widgets/add_payment_sections/historical_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/thousands_formatter.dart';

class HistoricalSection extends StatelessWidget {
  const HistoricalSection({
    required this.isHistoricalPayment,
    required this.selectedHistoricalDate,
    required this.isDollarPayment,
    required this.isDetailedMode,
    required this.histDollarRateCtrl,
    required this.meterPriceCtrl,
    required this.histIronCtrl,
    required this.histCementCtrl,
    required this.histBlockCtrl,
    required this.histFormworkCtrl,
    required this.histAggregatesCtrl,
    required this.histWorkerCtrl,
    required this.onHistoricalToggle,
    required this.onDateSelected,
    required this.onDetailedModeToggle,
    required this.onInputChanged,
    super.key,
  });

  final bool isHistoricalPayment;
  final DateTime selectedHistoricalDate;
  final bool isDollarPayment;
  final bool isDetailedMode;
  final TextEditingController histDollarRateCtrl;
  final TextEditingController meterPriceCtrl;
  final TextEditingController histIronCtrl;
  final TextEditingController histCementCtrl;
  final TextEditingController histBlockCtrl;
  final TextEditingController histFormworkCtrl;
  final TextEditingController histAggregatesCtrl;
  final TextEditingController histWorkerCtrl;
  final ValueChanged<bool> onHistoricalToggle;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<bool> onDetailedModeToggle;
  final ValueChanged<String> onInputChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isHistoricalPayment
                ? Colors.blue.shade50
                : Colors.transparent,
            border: Border.all(
              color: isHistoricalPayment ? Colors.blue : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: SwitchListTile(
              title: Text(
                l10n.paymentAddHistTitle,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(l10n.paymentAddHistSubtitle),
              value: isHistoricalPayment,
              activeThumbColor: Colors.blue,
              onChanged: onHistoricalToggle,
            ),
          ),
        ),

        if (isHistoricalPayment) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.paymentAddHistDateLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                        side: BorderSide(
                          color: Colors.blue.shade300,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month, size: 22),
                      label: Text(
                        '${selectedHistoricalDate.year}/'
                        '${selectedHistoricalDate.month}/'
                        '${selectedHistoricalDate.day}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedHistoricalDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) onDateSelected(picked);
                      },
                    ),
                  ],
                ),
                if (isDollarPayment) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: histDollarRateCtrl,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.paymentAddHistDollarLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        Icons.history_edu,
                        color: Colors.green,
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onInputChanged,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: Colors.blue),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => onDetailedModeToggle(false),
                        child: Row(
                          children: [
                            Radio<bool>.adaptive(
                              value: false,
                              groupValue: isDetailedMode,
                              activeColor: Colors.blue,
                              onChanged: (v) =>
                                  onDetailedModeToggle(v ?? false),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.paymentAddHistModeDirect,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.paymentAddHistModeDirectSub,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => onDetailedModeToggle(true),
                        child: Row(
                          children: [
                            Radio<bool>.adaptive(
                              value: true,
                              groupValue: isDetailedMode,
                              activeColor: Colors.blue,
                              onChanged: (v) =>
                                  onDetailedModeToggle(v ?? false),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.paymentAddHistModeDetailed,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.paymentAddHistModeDetailedSub,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!isDetailedMode)
                  TextField(
                    controller: meterPriceCtrl,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.paymentAddHistMeterPrice,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.speed, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: onInputChanged,
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: histIronCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistIron,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: histCementCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistCement,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: histBlockCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistBlock,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: histFormworkCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistFormwork,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: histAggregatesCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistAggregates,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: histWorkerCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText: l10n.contractHistWorker,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onInputChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
