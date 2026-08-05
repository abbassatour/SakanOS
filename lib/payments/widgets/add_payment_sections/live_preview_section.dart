// lib/payments/widgets/add_payment_sections/live_preview_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class LivePreviewSection extends StatelessWidget {
  const LivePreviewSection({
    required this.enteredAmount,
    required this.isDeposit,
    required this.isDollarPayment,
    required this.sypEquivalentAmount,
    required this.effectiveAmount,
    required this.calculatedMeterPrice,
    required this.previewMeters,
    super.key,
  });

  final double enteredAmount;
  final bool isDeposit;
  final bool isDollarPayment;
  final double sypEquivalentAmount;
  final double effectiveAmount;
  final double calculatedMeterPrice;
  final double previewMeters;

  @override
  Widget build(BuildContext context) {
    if (enteredAmount <= 0) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDeposit ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDeposit ? Colors.blue.shade200 : Colors.red.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDollarPayment) ...[
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.paymentAddPreviewSypEq,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    '${NumberFormatters.formatWithCommas(sypEquivalentAmount)} ل.س',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            isDeposit
                ? l10n.paymentAddPreviewFinalDeposit
                : l10n.paymentAddPreviewFinalWithdraw,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            '${isDeposit ? '' : '- '}'
            '${NumberFormatters.formatWithCommas(effectiveAmount)} ل.س',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDeposit ? Colors.blue.shade800 : Colors.red.shade800,
            ),
          ),
          if (calculatedMeterPrice > 0) ...[
            const Divider(height: 24),
            Text(
              l10n.paymentAddPreviewMeterPrice,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${NumberFormatters.formatWithCommas(calculatedMeterPrice)} ل.س',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDeposit
                  ? l10n.paymentAddPreviewMetersDeposit
                  : l10n.paymentAddPreviewMetersWithdraw,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${isDeposit ? '+ ' : '- '}'
              '${previewMeters.toStringAsFixed(3)} م²',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDeposit ? Colors.green.shade700 : Colors.red.shade800,
              ),
            ),
          ] else ...[
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.paymentAddPreviewWarning,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
