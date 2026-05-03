// lib/payments/view/dialogs/edit_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart';
import '../../cubit/payments_cubit.dart';
import 'pin_verify_dialog.dart'; 

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';

Future<void> showEditPaymentDialog(BuildContext parentContext, PaymentsLedgerData entry) async {
  
  // ==========================================
  // 🛡️ طبقة الحماية الأولى (Defense in Depth)
  // ==========================================
  final authState = parentContext.read<AuthCubit>().state;
  if (!authState.hasPermission(AppPermissions.editPayments)) {
    ScaffoldMessenger.of(parentContext).showSnackBar(
      const SnackBar(content: Text('حماية النظام: لا تملك الصلاحية لتعديل القيود المالية.'), backgroundColor: Colors.red),
    );
    return; // طرد فوري
  }

  // 1. طلب رمز الإدارة أولاً (طبقة الحماية الثانية)
  bool isAuthorized = await verifyPinCode(parentContext, '0938457732', 'تعديل القيود يتطلب صلاحيات الإدارة');
  if (!isAuthorized) return;

  final amountController = TextEditingController(text: entry.amountPaid.toString());
  final discountController = TextEditingController(text: entry.fees.toString()); 

  if (!parentContext.mounted) return;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          
          double amount = double.tryParse(amountController.text) ?? 0;
          double discountPct = double.tryParse(discountController.text) ?? 0;
          double effectiveAmount = amount + (amount * (discountPct / 100)); // نتركه هنا للعمليات الحسابية إن لزم الأمر

          return AlertDialog(
            title: const Text('تعديل الدفعة القديمة', style: TextStyle(color: Colors.orange)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange.shade50,
                    child: const Text('سيتم إعادة حساب الأمتار وتوزيع الأقساط بناءً على "سعر المتر القديم" المحفوظ في هذا الإيصال للحفاظ على الدقة.', style: TextStyle(color: Colors.deepOrange, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي (ل.س)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}), 
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: discountController,
                    decoration: const InputDecoration(labelText: 'نسبة الخصم / البونص المئوية', border: OutlineInputBorder(), suffixText: '%'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}), 
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: amount > 0 ? () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري تعديل القيد وإعادة وزن الأقساط... ⏳')));

                  parentContext.read<PaymentsCubit>().editOldLedgerEntry(
                    entryToEdit: entry,
                    newAmountPaid: amount,
                    newDiscountPercentage: discountPct,
                  );
                } : null, 
                child: const Text('اعتماد التعديل'),
              ),
            ],
          );
        },
      );
    },
  );
}