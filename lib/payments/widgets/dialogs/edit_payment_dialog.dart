// lib/payments/widgets/dialogs/edit_payment_dialog.dart

import 'dart:async';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';

Future<void> showEditPaymentDialog(
  BuildContext parentContext,
  PaymentsLedgerData entry,
) async {
  final l10n = parentContext.l10n;
  final authState = parentContext.read<AuthCubit>().state;
  if (!authState.hasPermission(AppPermissions.editPayments)) {
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(l10n.paymentEditNoPermission),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final isAuthorized = await showVerifyPinDialog(
    context: parentContext,
  );
  if (!isAuthorized) return;

  if (!parentContext.mounted) return;

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return _EditPaymentContent(
          entry: entry,
          parentContext: parentContext,
        );
      },
    ),
  );
}

class _EditPaymentContent extends StatefulWidget {
  const _EditPaymentContent({
    required this.entry,
    required this.parentContext,
  });

  final PaymentsLedgerData entry;
  final BuildContext parentContext;

  @override
  State<_EditPaymentContent> createState() => _EditPaymentContentState();
}

class _EditPaymentContentState extends State<_EditPaymentContent> {
  late final TextEditingController amountController;
  late final TextEditingController discountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.entry.amountPaid.toString(),
    );
    discountController = TextEditingController(
      text: widget.entry.fees.toString(),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final amount = double.tryParse(amountController.text) ?? 0;
    final discountPct = double.tryParse(discountController.text) ?? 0;

    return AlertDialog(
      title: Text(
        l10n.paymentEditTitle,
        style: const TextStyle(color: Colors.orange),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade50,
              child: Text(
                l10n.paymentEditWarning,
                style: const TextStyle(color: Colors.deepOrange, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: l10n.paymentEditAmountLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountController,
              decoration: InputDecoration(
                labelText: l10n.paymentEditDiscountLabel,
                border: const OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: amount != 0
              ? () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                    SnackBar(
                      content: Text(l10n.paymentEditLoading),
                    ),
                  );

                  unawaited(
                    widget.parentContext
                        .read<PaymentsCubit>()
                        .editOldLedgerEntry(
                          entryToEdit: widget.entry,
                          newAmountPaid: amount,
                          newDiscountPercentage: discountPct,
                        ),
                  );
                }
              : null,
          child: Text(l10n.paymentEditBtn),
        ),
      ],
    );
  }
}
