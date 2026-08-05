import 'dart:async';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';

Future<void> showDeletePaymentDialog(
  BuildContext parentContext,
  PaymentsLedgerData entry,
) async {
  final isAuthorized = await showVerifyPinDialog(
    context: parentContext,
  );
  if (!isAuthorized) return;
  if (!parentContext.mounted) return;

  final l10n = parentContext.l10n;
  final minutesPassed = DateTime.now()
      .toUtc()
      .difference(entry.createdAt)
      .inMinutes;
  final isGracePeriod = minutesPassed <= 5;

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isGracePeriod ? Icons.delete_sweep : Icons.autorenew,
                color: isGracePeriod ? Colors.red : Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              Text(
                isGracePeriod
                    ? l10n.paymentDeleteTitleGrace
                    : l10n.paymentDeleteTitleReverse,
                style: TextStyle(
                  color: isGracePeriod ? Colors.red : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGracePeriod ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isGracePeriod
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isGracePeriod) ...[
                  Text(
                    l10n.paymentDeleteWarningGrace,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.paymentDeleteDescGrace,
                    style: const TextStyle(fontSize: 13),
                  ),
                ] else ...[
                  Text(
                    l10n.paymentDeleteWarningReverse(
                      minutesPassed ~/ 60,
                      minutesPassed % 60,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.paymentDeleteDescReverse,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.btnCancel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isGracePeriod
                    ? Colors.red
                    : Colors.orange.shade800,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      isGracePeriod
                          ? l10n.paymentDeleteLoadingGrace
                          : l10n.paymentDeleteLoadingReverse,
                    ),
                    backgroundColor: isGracePeriod
                        ? Colors.red
                        : Colors.orange.shade800,
                  ),
                );

                unawaited(
                  parentContext.read<PaymentsCubit>().cancelPaymentSmartly(
                    entry,
                  ),
                );
              },
              icon: Icon(
                isGracePeriod ? Icons.delete_forever : Icons.receipt_long,
              ),
              label: Text(
                isGracePeriod
                    ? l10n.paymentDeleteBtnGrace
                    : l10n.paymentDeleteBtnReverse,
              ),
            ),
          ],
        );
      },
    ),
  );
}
