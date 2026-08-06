// lib/contracts/widgets/add_contract/auto_coefficients_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class AutoCoefficientsSection extends StatelessWidget {
  const AutoCoefficientsSection({
    required this.coefficients,
    super.key,
  });

  final Map<String, double> coefficients;

  String _getLocalizedCoeffKey(BuildContext context, String key) {
    final l10n = context.l10n;
    switch (key) {
      case 'الموقع':
        return l10n.coeffLocation;
      case 'الشارع':
        return l10n.coeffStreet;
      case 'المصعد':
        return l10n.coeffElevator;
      case 'شمالي':
        return l10n.coeffNorth;
      case 'جنوبي':
        return l10n.coeffSouth;
      case 'شرقي':
        return l10n.coeffEast;
      case 'غربي':
        return l10n.coeffWest;
      case 'هامش الربح':
        return l10n.coeffProfitMargin;
      case 'معامل التميز للوجيبة':
        return l10n.coeffYardExcellence;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (coefficients.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    l10n.contractAutoCoeffsTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: coefficients.entries.map((e) {
                  final localizedKey = _getLocalizedCoeffKey(context, e.key);
                  return Chip(
                    label: Text('$localizedKey: ${e.value}%'),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.teal),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
