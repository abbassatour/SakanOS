// lib/admin/widgets/roles_tab.dart
import 'package:flutter/material.dart';
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'role_dialog.dart';

class RolesTab extends StatelessWidget {
  final AdminState state;

  const RolesTab({super.key, required this.state});

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
                          ? 'دور أساسي (لا يمكن سحب الصلاحيات الأساسية منه)'
                          : 'دور مخصص قابل للتعديل',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  trailing: ElevatedButton.icon(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
