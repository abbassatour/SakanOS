// lib/contracts/widgets/dialogs/edit_contract_sections/penalty_settings_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

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
    final l10n = context.l10n;

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
              title: Text(
                l10n.contractPenaltyToggleTitle,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                l10n.contractPenaltyToggleSubtitle,
                style: const TextStyle(fontSize: 11),
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
                      decoration: InputDecoration(
                        labelText: l10n.contractPenaltyPctLabel,
                        border: const OutlineInputBorder(),
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
                      decoration: InputDecoration(
                        labelText: l10n.contractPenaltyIntervalLabel,
                        border: const OutlineInputBorder(),
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
