// lib/payments/widgets/dialogs/delete_payment_dialog.dart

import 'dart:async';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';

Future<void> showDeletePaymentDialog(
  BuildContext parentContext,
  PaymentsLedgerData entry,
) async {
  final isAuthorized = await showVerifyPinDialog(
    context: parentContext,
    correctPin: '0000',
    message: 'حذف الإيصال الأخير يتطلب رمز المحاسب',
  );
  if (!isAuthorized) return;

  if (!parentContext.mounted) return;

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تأكيد إلغاء الإيصال',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'إلغاء هذا الإيصال سيؤدي إلى خصم الأمتار المحولة الخاصة به '
            'وإعادة فتح الأقساط التي سُددت بسببه.\nهل أنت متأكد؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('جاري الإلغاء وإعادة ضبط الأقساط... ⏳'),
                  ),
                );
                unawaited(
                  parentContext
                      .read<PaymentsCubit>()
                      .softDeleteLastEntry(entry),
                );
              },
              child: const Text('نعم، قم بالإلغاء'),
            ),
          ],
        );
      },
    ),
  );
}