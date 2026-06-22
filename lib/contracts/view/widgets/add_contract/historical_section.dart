// lib/contracts/view/widgets/add_contract/historical_section.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'إدخال عقد قديم (تاريخي)',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'يتيح لك تحديد تاريخ توقيع قديم وإدخال أسعار المواد '
                'في ذلك الوقت.',
              ),
              value: isHistorical,
              activeColor: Colors.red,
              onChanged: onToggle,
            ),
            if (isHistorical) ...[
              const Divider(color: Colors.red),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📅 تاريخ التوقيع:',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                    const Text(
                      '💰 أسعار المواد في ذلك التاريخ (ل.س)',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField('الحديد', histIronCtrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField('الإسمنت', histCementCtrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField('البلوك 15', histBlockCtrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(
                            'الكوفراج',
                            histFormworkCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            'حصويات',
                            histAggregatesCtrl,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriceField(
                            'أجرة العامل',
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