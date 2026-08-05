// lib/admin/widgets/roles_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show AppRole;
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'role_dialog.dart';

class RolesTab extends StatelessWidget {
  final AdminState state;

  const RolesTab({super.key, required this.state});

  // 🌟 نافذة تأكيد الحذف
  void _confirmDeleteRole(BuildContext context, AppRole role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف قالب الصلاحيات "${role.name}" نهائياً؟\n\n(لن يتم الحذف إذا كان هناك موظفون يستخدمون هذا الدور).',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('نعم، احذف الدور'),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().deleteRole(role.id, role.name);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text(
              'إنشاء قالب دور جديد',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => showRoleDialog(context, null),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: state.roles.length,
            itemBuilder: (context, index) {
              final role = state.roles[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: role.isSystemRole
                          ? Colors.red.shade50
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      role.isSystemRole ? Icons.shield : Icons.manage_accounts,
                      color: role.isSystemRole
                          ? Colors.red
                          : Colors.amber.shade700,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    role.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      role.isSystemRole
                          ? 'دور أساسي (لا يمكن سحب الصلاحيات الأساسية منه أو حذفه)'
                          : 'دور مخصص قابل للتعديل والحذف',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit_square, size: 18),
                        label: const Text(
                          'تعديل الصلاحيات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade50,
                          foregroundColor: Colors.blueGrey.shade900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => showRoleDialog(context, role),
                      ),
                      // 🌟 زر الحذف (يظهر فقط للأدوار غير الأساسية)
                      if (!role.isSystemRole) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'حذف الدور',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                          ),
                          onPressed: () => _confirmDeleteRole(context, role),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
