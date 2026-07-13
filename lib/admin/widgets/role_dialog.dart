// lib/admin/widgets/role_dialog.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show AppRole;
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';

// ==========================================
// 🌟 القواميس والإعدادات الخاصة بالصلاحيات
// ==========================================
final Map<String, String> _permissionNames = {
  AppPermissions.viewClients: 'عرض العملاء',
  AppPermissions.createClients: 'إضافة عميل',
  AppPermissions.editClients: 'تعديل عميل',
  AppPermissions.deleteClients: 'حذف عميل',
  AppPermissions.viewContracts: 'عرض العقود',
  AppPermissions.createContracts: 'إنشاء عقد جديد',
  AppPermissions.restructureContracts: 'إعادة جدولة الأقساط',
  AppPermissions.viewPayments: 'عرض الأقساط والمدفوعات',
  AppPermissions.addPayments: 'قبض دفعة جديدة',
  AppPermissions.editPayments: 'تعديل مبلغ الدفعة',
  AppPermissions.deletePayments: 'حذف دفعة',
  AppPermissions.viewPrices: 'رؤية أسعار المواد',
  AppPermissions.updatePrices: 'تعديل أسعار المواد',
  AppPermissions.manageBuildings: 'إدارة المحاضر والشقق',
  AppPermissions.viewRecycleBin: 'رؤية سلة المحذوفات',
  AppPermissions.restoreItems: 'استعادة المحذوفات',
  AppPermissions.hardDeleteItems: 'الحذف النهائي المدمر',
  AppPermissions.viewLegalAffairs: 'عرض الأرشيف القانوني',
  AppPermissions.addLegalAction: 'إضافة إجراء قانوني جديد',
  AppPermissions.editLegalAction: 'تعديل إجراء قانوني',
  AppPermissions.deleteLegalAction: 'حذف إجراء قانوني',
  AppPermissions.manageLegalAttachments: 'إدارة المرفقات القانونية (رفع/حذف)',
};

final Map<String, List<String>> _permissionGroups = {
  'إدارة العملاء': [
    AppPermissions.viewClients,
    AppPermissions.createClients,
    AppPermissions.editClients,
    AppPermissions.deleteClients,
  ],
  'العقود والمشاريع': [
    AppPermissions.manageBuildings,
    AppPermissions.viewContracts,
    AppPermissions.createContracts,
    AppPermissions.restructureContracts,
  ],
  'الإدارة المالية والأسعار': [
    AppPermissions.viewPayments,
    AppPermissions.addPayments,
    AppPermissions.editPayments,
    AppPermissions.deletePayments,
    AppPermissions.viewPrices,
    AppPermissions.updatePrices,
  ],
  'الشؤون القانونية': [
    AppPermissions.viewLegalAffairs,
    AppPermissions.addLegalAction,
    AppPermissions.editLegalAction,
    AppPermissions.deleteLegalAction,
    AppPermissions.manageLegalAttachments,
  ],
  'إدارة النظام والأمان': [
    AppPermissions.viewRecycleBin,
    AppPermissions.restoreItems,
    AppPermissions.hardDeleteItems,
  ],
};

IconData _getGroupIcon(String groupName) {
  switch (groupName) {
    case 'إدارة العملاء':
      return Icons.people_alt;
    case 'العقود والمشاريع':
      return Icons.domain;
    case 'الإدارة المالية والأسعار':
      return Icons.account_balance_wallet;
    case 'الشؤون القانونية':
      return Icons.gavel;
    case 'إدارة النظام والأمان':
      return Icons.security;
    default:
      return Icons.list;
  }
}

// ==========================================
// 🌟 استدعاء النافذة
// ==========================================
void showRoleDialog(BuildContext parentContext, AppRole? role) {
  final adminCubit = parentContext.read<AdminCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: adminCubit,
        child: _RoleDialogContent(role: role, parentContext: parentContext),
      ),
    ),
  );
}

// ==========================================
// 🌟 محتوى النافذة (Stateful Widget)
// ==========================================
class _RoleDialogContent extends StatefulWidget {
  const _RoleDialogContent({this.role, required this.parentContext});

  final AppRole? role;
  final BuildContext parentContext;

  @override
  State<_RoleDialogContent> createState() => _RoleDialogContentState();
}

class _RoleDialogContentState extends State<_RoleDialogContent> {
  late TextEditingController _nameController;
  List<String> _currentPerms = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');

    if (widget.role != null && widget.role!.permissionsJson.isNotEmpty) {
      try {
        final decoded =
            jsonDecode(widget.role!.permissionsJson) as Iterable<dynamic>;
        _currentPerms = List<String>.from(decoded);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSystemRole = widget.role?.isSystemRole ?? false;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      title: Row(
        children: [
          Icon(
            isSystemRole ? Icons.shield : Icons.edit_note,
            color: Colors.blueGrey.shade800,
          ),
          const SizedBox(width: 12),
          Text(
            widget.role == null
                ? 'بناء دور وظيفي جديد'
                : 'تعديل صلاحيات: ${widget.role!.name}',
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.role == null) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الدور (مثال: محاسب، محامي، مدير فرع)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSystemRole
                          ? 'هذا الدور أساسي في النظام ولا يمكن تعديل صلاحياته لتجنب الأخطاء الإدارية.'
                          : 'قم باختيار الصلاحيات المناسبة لهذا الدور. أي موظف يتم تعيينه بهذا الدور سيكتسب هذه الصلاحيات فوراً.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _permissionGroups.entries.map((entry) {
                  final groupName = entry.key;
                  final groupPerms = entry.value;

                  final selectedCount = groupPerms
                      .where((p) => _currentPerms.contains(p))
                      .length;
                  final isAllSelected = selectedCount == groupPerms.length;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(
                          _getGroupIcon(groupName),
                          color: Colors.indigo,
                        ),
                        title: Text(
                          groupName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$selectedCount من ${groupPerms.length} محددة',
                          style: TextStyle(
                            color: selectedCount == groupPerms.length
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        children: [
                          Material(
                            color: Colors.grey.shade50,
                            child: CheckboxListTile(
                              title: const Text(
                                'تحديد كافة صلاحيات هذا القسم',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              value: isAllSelected,
                              activeColor: Colors.indigo,
                              onChanged: isSystemRole
                                  ? null
                                  : (val) {
                                      setState(() {
                                        if (val == true) {
                                          _currentPerms.addAll(
                                            groupPerms.where(
                                              (p) => !_currentPerms.contains(p),
                                            ),
                                          );
                                        } else {
                                          _currentPerms.removeWhere(
                                            (p) => groupPerms.contains(p),
                                          );
                                        }
                                      });
                                    },
                            ),
                          ),
                          const Divider(height: 1),
                          ...groupPerms.map((permCode) {
                            final hasPerm = _currentPerms.contains(permCode);
                            return CheckboxListTile(
                              title: Text(
                                _permissionNames[permCode] ?? permCode,
                              ),
                              value: hasPerm,
                              activeColor: Colors.blueGrey.shade800,
                              onChanged: isSystemRole
                                  ? null
                                  : (bool? val) {
                                      setState(() {
                                        if (val == true) {
                                          _currentPerms.add(permCode);
                                        } else {
                                          _currentPerms.remove(permCode);
                                        }
                                      });
                                    },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (!isSystemRole)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.save),
            label: const Text(
              'حفظ الصلاحيات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () {
              if (widget.role == null) {
                if (_nameController.text.trim().isNotEmpty) {
                  context.read<AdminCubit>().createNewRole(
                    _nameController.text.trim(),
                    _currentPerms,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('تم إنشاء الدور بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                context.read<AdminCubit>().updateRole(
                  widget.role!.id,
                  _currentPerms,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الصلاحيات بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
