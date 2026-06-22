// lib/contracts/view/widgets/add_contract/shared_coefficients_section.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';

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
              const Text(
                '🛠️ معاملات التجهيزات المشتركة (%)',
                style: TextStyle(
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
                      decoration: const InputDecoration(
                        labelText: 'بلوك %',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'كلسة ملونة %',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'درج رخام %',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'سلاحات رخام %',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'نوازل صحية %',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'صواعد مداخن %',
                        border: OutlineInputBorder(),
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