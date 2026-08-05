// lib/payments/widgets/add_payment_sections/payment_type_section.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class PaymentTypeSection extends StatelessWidget {
  const PaymentTypeSection({
    required this.isDeposit,
    required this.onDepositTapped,
    required this.onWithdrawTapped,
    super.key,
  });

  final bool isDeposit;
  final VoidCallback onDepositTapped;
  final VoidCallback onWithdrawTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onDepositTapped,
              child: Row(
                children: [
                  Radio<bool>.adaptive(
                    value: true,
                    groupValue: isDeposit,
                    activeColor: Colors.deepOrange,
                    onChanged: (_) => onDepositTapped(),
                  ),
                  Text(
                    l10n.paymentAddTypeDeposit,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onWithdrawTapped,
              child: Row(
                children: [
                  Radio<bool>.adaptive(
                    value: false,
                    groupValue: isDeposit,
                    activeColor: Colors.red,
                    onChanged: (_) => onWithdrawTapped(),
                  ),
                  Text(
                    l10n.paymentAddTypeWithdraw,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
