// lib/payments/widgets/add_payment_sections/amount_input_section.dart

import 'package:flutter/material.dart';

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
    return Column(
      children: [
        TextField(
          controller: amountController,
          inputFormatters: [ThousandsFormatter()],
          decoration: InputDecoration(
            labelText: isDollarPayment
                ? 'المبلغ ${isDeposit ? "المدفوع" : "المسترد"} بالدولار (USD)'
                : 'المبلغ ${isDeposit ? "المدفوع" : "المسترد"} (ل.س)',
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
                ? 'نسبة الخصم / البونص المئوية'
                : 'نسبة البونص المُراد استرجاعها',
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
