// lib/admin/widgets/role_dialog.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show AppRole;
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

// ==========================================
// 🌟 هيكلة الصلاحيات الذكية لدعم الترجمة الديناميكية
// ==========================================
class PermGroup {
  final String title;
  final IconData icon;
  final List<String> perms;

  PermGroup(this.title, this.icon, this.perms);
}

// دالة مساعدة لربط معرفات الصلاحيات بأسماء مترجمة
Map<String, String> _getLocalizedPermissionNames(AppLocalizations l10n) {
  return {
    AppPermissions.viewClients: l10n.permViewClients,
    AppPermissions.createClients: l10n.permCreateClients,
    AppPermissions.editClients: l10n.permEditClients,
    AppPermissions.deleteClients: l10n.permDeleteClients,
    AppPermissions.viewContracts: l10n.permViewContracts,
    AppPermissions.createContracts: l10n.permCreateContracts,
    AppPermissions.restructureContracts: l10n.permRestructureContracts,
    AppPermissions.viewPayments: l10n.permViewPayments,
    AppPermissions.addPayments: l10n.permAddPayments,
    AppPermissions.editPayments: l10n.permEditPayments,
    AppPermissions.deletePayments: l10n.permDeletePayments,
    AppPermissions.viewPrices: l10n.permViewPrices,
    AppPermissions.updatePrices: l10n.permUpdatePrices,
    AppPermissions.manageBuildings: l10n.permManageBuildings,
    AppPermissions.viewRecycleBin: l10n.permViewRecycleBin,
    AppPermissions.restoreItems: l10n.permRestoreItems,
    AppPermissions.hardDeleteItems: l10n.permHardDeleteItems,
    AppPermissions.viewLegalAffairs: l10n.permViewLegal,
    AppPermissions.addLegalAction: l10n.permAddLegal,
    AppPermissions.editLegalAction: l10n.permEditLegal,
    AppPermissions.deleteLegalAction: l10n.permDeleteLegal,
    AppPermissions.manageLegalAttachments: l10n.permManageLegalAttachments,
  };
}

// دالة مساعدة لتنظيم المجموعات وتمرير الترجمة
List<PermGroup> _getPermissionGroups(AppLocalizations l10n) {
  return [
    PermGroup(l10n.permGroupClients, Icons.people_alt, [
      AppPermissions.viewClients,
      AppPermissions.createClients,
      AppPermissions.editClients,
      AppPermissions.deleteClients,
    ]),
    PermGroup(l10n.permGroupContracts, Icons.domain, [
      AppPermissions.manageBuildings,
      AppPermissions.viewContracts,
      AppPermissions.createContracts,
      AppPermissions.restructureContracts,
    ]),
    PermGroup(l10n.permGroupFinance, Icons.account_balance_wallet, [
      AppPermissions.viewPayments,
      AppPermissions.addPayments,
      AppPermissions.editPayments,
      AppPermissions.deletePayments,
      AppPermissions.viewPrices,
      AppPermissions.updatePrices,
    ]),
    PermGroup(l10n.permGroupLegal, Icons.gavel, [
      AppPermissions.viewLegalAffairs,
      AppPermissions.addLegalAction,
      AppPermissions.editLegalAction,
      AppPermissions.deleteLegalAction,
      AppPermissions.manageLegalAttachments,
    ]),
    PermGroup(l10n.permGroupSystem, Icons.security, [
      AppPermissions.viewRecycleBin,
      AppPermissions.restoreItems,
      AppPermissions.hardDeleteItems,
    ]),
  ];
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
    final l10n = context.l10n;
    final isSystemRole = widget.role?.isSystemRole ?? false;
    final permGroups = _getPermissionGroups(l10n);
    final permNames = _getLocalizedPermissionNames(l10n);

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
                ? l10n.adminRoleDialogAddTitle
                : l10n.adminRoleDialogEditTitle(widget.role!.name),
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
                  labelText: l10n.adminRoleDialogNameLabel,
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
                          ? l10n.adminRoleDialogSystemWarning
                          : l10n.adminRoleDialogCustomInfo,
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
                children: permGroups.map((group) {
                  final selectedCount = group.perms
                      .where((p) => _currentPerms.contains(p))
                      .length;
                  final isAllSelected = selectedCount == group.perms.length;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        leading: Icon(group.icon, color: Colors.indigo),
                        title: Text(
                          group.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          l10n.adminRoleDialogSelectedCount(
                            selectedCount,
                            group.perms.length,
                          ),
                          style: TextStyle(
                            color: selectedCount == group.perms.length
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
                              title: Text(
                                l10n.adminRoleDialogSelectAll,
                                style: const TextStyle(
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
                                            group.perms.where(
                                              (p) => !_currentPerms.contains(p),
                                            ),
                                          );
                                        } else {
                                          _currentPerms.removeWhere(
                                            (p) => group.perms.contains(p),
                                          );
                                        }
                                      });
                                    },
                            ),
                          ),
                          const Divider(height: 1),
                          ...group.perms.map((permCode) {
                            final hasPerm = _currentPerms.contains(permCode);
                            return CheckboxListTile(
                              title: Text(permNames[permCode] ?? permCode),
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
          child: Text(
            l10n.btnCancel,
            style: const TextStyle(
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
            label: Text(
              l10n.adminRoleDialogSaveBtn,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    SnackBar(
                      content: Text(l10n.adminRoleDialogAddSuccess),
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
                  SnackBar(
                    content: Text(l10n.adminRoleDialogEditSuccess),
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
