// lib/payments/widgets/add_payment_sections/currency_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

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
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDollarPayment ? Colors.green.shade50 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDollarPayment ? Colors.green : Colors.grey.shade300,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile(
          title: Text(
            l10n.paymentAddCurrencyTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDollarPayment ? Colors.green.shade700 : Colors.black87,
              fontSize: 14,
            ),
          ),
          subtitle: isHistoricalPayment
              ? Text(
                  l10n.paymentAddCurrencyHistSub,
                  style: const TextStyle(color: Colors.green),
                )
              : (currentDollarRate != null
                    ? Text(
                        l10n.paymentAddCurrencyCurrentSub(
                          NumberFormatters.formatWithCommas(currentDollarRate!),
                        ),
                        style: TextStyle(
                          color: isDollarPayment
                              ? Colors.green.shade900
                              : Colors.grey,
                        ),
                      )
                    : Text(
                        l10n.paymentAddCurrencyMissing,
                        style: const TextStyle(color: Colors.red),
                      )),
          value: isDollarPayment,
          activeThumbColor: Colors.green,
          onChanged: (isHistoricalPayment || currentDollarRate != null)
              ? onToggle
              : null,
        ),
      ),
    );
  }
}
