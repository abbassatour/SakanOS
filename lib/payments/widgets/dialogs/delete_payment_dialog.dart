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
    message: 'إلغاء الإيصالات المالية يتطلب مصادقة الإدارة',
  );
  if (!isAuthorized) return;
  if (!parentContext.mounted) return;

  // 🌟 حساب الوقت لمعرفة تصميم النافذة المطلوبة
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
                    ? 'إبطال الإيصال (إلغاء فوري)'
                    : 'تسوية محاسبية (قيد عكسي)',
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
                  const Text(
                    '⚠️ أنت ضمن فترة السماح للمطور (5 دقائق).',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سيتم مسح هذا الإيصال بالكامل من كشف حساب العميل لتجنب التشويه، وسيتم إعادة فتح القسط المرتبط به.',
                    style: TextStyle(fontSize: 13),
                  ),
                ] else ...[
                  Text(
                    '🔒 انتهت فترة السماح للمطور (مر ${minutesPassed ~/ 60} ساعة و ${minutesPassed % 60} دقيقة).',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'لا يمكن مسح الإيصال من الدفاتر المحاسبية لضمان سلامة التدقيق. بدلاً من ذلك، سيقوم النظام آلياً بإنشاء "سند استرداد بقيمة سالبة" لمعاكسة هذا الإيصال، وسيتم إعادة فتح القسط للعميل.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'تراجع',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                          ? 'جاري الإبطال الفوري وإعادة فتح القسط...'
                          : 'جاري إنشاء القيد العكسي...',
                    ),
                    backgroundColor: isGracePeriod
                        ? Colors.red
                        : Colors.orange.shade800,
                  ),
                );

                // 🌟 استدعاء الدالة الجديدة المدمجة
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
                isGracePeriod ? 'إبطال نهائي' : 'اعتماد وإنشاء قيد عكسي',
              ),
            ),
          ],
        );
      },
    ),
  );
}
