// lib/clients/view/dialogs/edit_client_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client; // استيراد نوع العميل بآمان
import '../../cubit/clients_cubit.dart';
import 'verify_pin_dialog.dart';

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';

void showEditClientDialog(BuildContext parentContext, Client client) {
  final nameController = TextEditingController(text: client.name);
  final phoneController = TextEditingController(text: client.phone);
  final nationalIdController = TextEditingController(text: client.nationalId ?? '');

  // 🌟 جلب الصلاحيات لمعرفة ما إذا كان يملك صلاحية (حذف العملاء) أم لا
  final authState = parentContext.read<AuthCubit>().state;
  final bool canDelete = authState.hasPermission(AppPermissions.deleteClients);

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      
      // 🌟 دالة مساعدة لتوحيد تصميم حقول الإدخال باحترافية
      Widget buildField({
        required TextEditingController controller, 
        required String label, 
        required IconData icon, 
        TextInputType keyboardType = TextInputType.text,
      }) {
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 22, color: Colors.blueAccent.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2)),
          ),
        );
      }

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children:[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.manage_accounts, color: Colors.blueAccent.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            const Text('تعديل بيانات العميل', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        content: SizedBox(
          width: 600, // 🌟 عرض احترافي 600 بكسل
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 رسالة توضيحية للأمان
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200, width: 1.5),
                  ),
                  child: Row(
                    children:[
                      Icon(Icons.security, color: Colors.amber.shade800, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تنبيه أمني: إجراءات التعديل أو الحذف للعملاء المسجلين تتطلب إدخال رمز الأمان (PIN) الخاص بالإدارة للحفاظ على موثوقية العقود.', 
                          style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // 🌟 حقل الاسم
                buildField(
                  controller: nameController,
                  label: 'الاسم الرباعي',
                  icon: Icons.person,
                ),
                
                const SizedBox(height: 16),
                
                // 🌟 حقلي الهاتف والرقم الوطني بجانب بعضهما
                Row(
                  children:[
                    Expanded(
                      child: buildField(
                        controller: phoneController,
                        label: 'رقم الهاتف (للواتساب)',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildField(
                        controller: nationalIdController,
                        label: 'الرقم الوطني (اختياري)',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions:[
          // فصلنا الأزرار لتكون مرتبة (زر الحذف يساراً، أزرار الحفظ يميناً)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              // ==========================================
              // 👻 الإخفاء التام لزر الحذف
              // ==========================================
              if (canDelete)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('حذف ونقل للسلة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    Navigator.pop(dialogContext); // إغلاق النافذة
                    bool isAuthorized = await showVerifyPinDialog(parentContext); 
                    if (isAuthorized && parentContext.mounted) {
                      parentContext.read<ClientsCubit>().deleteClient(client.id);
                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم نقل العميل لسلة المحذوفات'), backgroundColor: Colors.green));
                    }
                  },
                )
              else
                const SizedBox.shrink(), // مساحة فارغة بدلاً من الزر ليحافظ على التصميم
              
              // ✏️ أزرار الحفظ والإلغاء
              Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext), 
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty) {
                        Navigator.pop(dialogContext);
                        bool isAuthorized = await showVerifyPinDialog(parentContext);
                        if (isAuthorized && parentContext.mounted) {
                          parentContext.read<ClientsCubit>().updateClient(
                            id: client.id, 
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            nationalId: nationalIdController.text.trim().isEmpty ? null : nationalIdController.text.trim(),
                          );
                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم تحديث بيانات العميل بنجاح ✅'), backgroundColor: Colors.green));
                        }
                      } else {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('⚠️ يرجى إدخال الاسم ورقم الهاتف على الأقل!'), backgroundColor: Colors.red));
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          )
        ],
      );
    },
  );
}