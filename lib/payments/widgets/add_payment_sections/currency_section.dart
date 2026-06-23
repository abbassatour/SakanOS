// lib/payments/widgets/add_payment_sections/currency_section.dart

import 'package:flutter/material.dart';

import 'package:our_home_erp_app/core/utils/formatters.dart';

class CurrencySection extends StatelessWidget {
  const CurrencySection({
    required this.isDollarPayment,
    required this.isHistoricalPayment,
    required this.currentDollarRate,
    required this.onToggle,
    super.key,
  });

  final bool isDollarPayment;
  final bool isHistoricalPayment;
  final double? currentDollarRate;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDollarPayment ? Colors.green.shade50 : Colors.white,
        border: Border.all(
          color: isDollarPayment ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(
          'إدخال المبلغ بالدولار الأمريكي (USD)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDollarPayment ? Colors.green.shade700 : Colors.black87,
            fontSize: 14,
          ),
        ),
        subtitle: isHistoricalPayment
            ? const Text(
                'أدخل سعر صرف الدولار القديم في الأسفل',
                style: TextStyle(color: Colors.green),
              )
            : (currentDollarRate != null
                ? Text(
                    'سعر الصرف: '
                    '${NumberFormatters.formatWithCommas(currentDollarRate!)} '
                    'ل.س',
                    style: TextStyle(
                      color: isDollarPayment
                          ? Colors.green.shade900
                          : Colors.grey,
                    ),
                  )
                : const Text(
                    '⚠️ جاري تحميل التسعيرة أو لم يتم تعيينها',
                    style: TextStyle(color: Colors.red),
                  )),
        value: isDollarPayment,
        activeThumbColor: Colors.green,
        onChanged: (isHistoricalPayment || currentDollarRate != null)
            ? onToggle
            : null,
      ),
    );
  }
}
