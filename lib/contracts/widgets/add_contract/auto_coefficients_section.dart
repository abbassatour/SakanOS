// lib/contracts/widgets/add_contract/auto_coefficients_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class AutoCoefficientsSection extends StatelessWidget {
  const AutoCoefficientsSection({
    required this.coefficients,
    super.key,
  });

  final Map<String, double> coefficients;

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
                  return Chip(
                    label: Text('${e.key}: ${e.value}%'),
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
