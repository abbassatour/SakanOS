// lib/payments/widgets/add_payment_sections/live_preview_section.dart

import 'package:flutter/material.dart';

import 'package:our_home_erp_app/core/utils/formatters.dart';

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
                  const Text(
                    'يعادل بالليرة السورية:',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    '${NumberFormatters.formatWithCommas(sypEquivalentAmount)} '
                    'ل.س',
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
                ? 'المبلغ النهائي (مع البونص):'
                : 'الرقم الإجمالي الذي سيُخصم من الرصيد:',
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
              'سعر المتر المعتمد لعملية التحويل:',
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
                  ? 'الأمتار المضافة لرصيد العميل:'
                  : 'الأمتار المخصومة من رصيد العميل:',
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
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يرجى التأكد من إدخال تسعيرة المواد ليتمكن '
                    'النظام من حساب الأمتار.',
                    style: TextStyle(
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
