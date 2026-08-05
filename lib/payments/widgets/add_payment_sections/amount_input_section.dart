// lib/payments/widgets/add_payment_sections/amount_input_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/thousands_formatter.dart';

class AmountInputSection extends StatelessWidget {
  const AmountInputSection({
    required this.isDollarPayment,
    required this.isDeposit,
    required this.mainColor,
    required this.amountController,
    required this.discountController,
    required this.onInputChanged,
    super.key,
  });

  final bool isDollarPayment;
  final bool isDeposit;
  final Color mainColor;
  final TextEditingController amountController;
  final TextEditingController discountController;
  final ValueChanged<String> onInputChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        TextField(
          controller: amountController,
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(
            labelText: isDollarPayment
                ? (isDeposit
                      ? l10n.paymentAddAmountUsdDeposit
                      : l10n.paymentAddAmountUsdWithdraw)
                : (isDeposit
                      ? l10n.paymentAddAmountSypDeposit
                      : l10n.paymentAddAmountSypWithdraw),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(
              isDollarPayment ? Icons.monetization_on : Icons.payments,
              color: isDollarPayment ? Colors.green : mainColor,
            ),
            filled: true,
            fillColor: isDollarPayment
                ? Colors.green.shade50
                : (isDeposit ? Colors.white : Colors.red.shade50),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDollarPayment ? Colors.green : mainColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDollarPayment ? Colors.green.shade900 : Colors.black87,
          ),
          keyboardType: TextInputType.number,
          onChanged: onInputChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: discountController,
          decoration: InputDecoration(
            labelText: isDeposit
                ? l10n.paymentAddDiscountDeposit
                : l10n.paymentAddDiscountWithdraw,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixText: '%',
            prefixIcon: Icon(Icons.percent, color: mainColor),
            filled: true,
            fillColor: isDeposit ? Colors.white : Colors.red.shade50,
          ),
          keyboardType: TextInputType.number,
          onChanged: onInputChanged,
        ),
      ],
    );
  }
}
