// lib/contracts/widgets/add_contract/shared_coefficients_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class SharedCoefficientsSection extends StatelessWidget {
  const SharedCoefficientsSection({
    required this.blockCoeffCtrl,
    required this.coloredPlasterCoeffCtrl,
    required this.marbleStairsCoeffCtrl,
    required this.marbleFinsCoeffCtrl,
    required this.plumbingCoeffCtrl,
    required this.chimneysCoeffCtrl,
    super.key,
  });

  final TextEditingController blockCoeffCtrl;
  final TextEditingController coloredPlasterCoeffCtrl;
  final TextEditingController marbleStairsCoeffCtrl;
  final TextEditingController marbleFinsCoeffCtrl;
  final TextEditingController plumbingCoeffCtrl;
  final TextEditingController chimneysCoeffCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.contractSharedCoeffsTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: blockCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedBlock,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: coloredPlasterCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedPlaster,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: marbleStairsCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedStairs,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
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
                      controller: marbleFinsCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedFins,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: plumbingCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedPlumbing,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: chimneysCoeffCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.contractSharedChimneys,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
