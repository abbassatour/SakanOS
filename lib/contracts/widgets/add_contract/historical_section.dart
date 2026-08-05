// lib/contracts/widgets/add_contract/historical_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class HistoricalSection extends StatelessWidget {
  const HistoricalSection({
    required this.isHistorical,
    required this.selectedDate,
    required this.onToggle,
    required this.onDateTap,
    required this.histIronCtrl,
    required this.histCementCtrl,
    required this.histBlockCtrl,
    required this.histFormworkCtrl,
    required this.histAggregatesCtrl,
    required this.histWorkerCtrl,
    super.key,
  });

  final bool isHistorical;
  final DateTime selectedDate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDateTap;
  final TextEditingController histIronCtrl;
  final TextEditingController histCementCtrl;
  final TextEditingController histBlockCtrl;
  final TextEditingController histFormworkCtrl;
  final TextEditingController histAggregatesCtrl;
  final TextEditingController histWorkerCtrl;

  Widget _buildPriceField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      inputFormatters: [ThousandsFormatter()],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        fillColor: Colors.white,
        filled: true,
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                l10n.contractHistToggleTitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(l10n.contractHistToggleSubtitle),
              value: isHistorical,
              activeThumbColor: Colors.red,
              onChanged: onToggle,
            ),
            if (isHistorical) ...[
              const Divider(color: Colors.red),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.contractHistSignDateLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_month, color: Colors.red),
                    label: Text(
                      '${selectedDate.year}/${selectedDate.month}/'
                      '${selectedDate.day}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: onDateTap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.contractHistMaterialsTitle,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistIron,
                            histIronCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistCement,
                            histCementCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistBlock,
                            histBlockCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistFormwork,
                            histFormworkCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistAggregates,
                            histAggregatesCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            l10n.contractHistWorker,
                            histWorkerCtrl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
