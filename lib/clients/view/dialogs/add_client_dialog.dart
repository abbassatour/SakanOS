// lib/clients/view/dialogs/add_client_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/clients_cubit.dart';

void showAddClientDialog(BuildContext parentContext) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();

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
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
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
              child: Icon(Icons.person_add_alt_1, color: Colors.blueAccent.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            const Text('إضافة عميل جديد', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        content: SizedBox(
          width: 600, // 🌟 عرض احترافي 600 بكسل لراحة العين
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text('يرجى إدخال بيانات العميل (الفريق الثاني) بدقة للتواصل وإعداد العقود.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                
                buildField(
                  controller: nameController,
                  label: 'الاسم الثلاثي',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                
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
            onPressed: () {
              // استخدمت trim() لتجاهل المسافات الفارغة الخاطئة
              if (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty) {
                parentContext.read<ClientsCubit>().addClient(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  nationalId: nationalIdController.text.trim().isEmpty ? null : nationalIdController.text.trim(),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تمت إضافة العميل بنجاح ✅'), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('⚠️ يرجى إدخال الاسم ورقم الهاتف على الأقل!'), backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('حفظ العميل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}