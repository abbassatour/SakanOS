// مسار الملف: lib/contracts/widgets/dialogs/edit_contract_sections/penalty_settings_section.dart

import 'package:flutter/material.dart';

class PenaltySettingsSection extends StatelessWidget {
  const PenaltySettingsSection({
    super.key,
    required this.canEdit,
    required this.isPenaltyActive,
    required this.penaltyPctCtrl,
    required this.penaltyIntervalCtrl,
    required this.onPenaltyToggle,
  });

  final bool canEdit;
  final bool isPenaltyActive;
  final TextEditingController penaltyPctCtrl;
  final TextEditingController penaltyIntervalCtrl;
  final ValueChanged<bool> onPenaltyToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        border: Border.all(color: Colors.deepOrange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'تفعيل غرامة التأخير',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'تطبق آلياً بعد التسليم إذا تراكمت الديون',
                style: TextStyle(fontSize: 11),
              ),
              value: isPenaltyActive,
              activeThumbColor: Colors.deepOrange,
              onChanged: canEdit ? onPenaltyToggle : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (isPenaltyActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: penaltyPctCtrl,
                      enabled: canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'النسبة',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: penaltyIntervalCtrl,
                      enabled: canEdit,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'تطبق كل',
                        suffixText: 'أشهر',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
