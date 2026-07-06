//lib\admin\view\admin_page.dart
import 'dart:async';
import 'dart:convert';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show AppRole;
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<ErpRepository>())..loadAdminData(),
      child: const AdminView(),
    );
  }
}

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, String> permissionNames = {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة (المدير العام)'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: 'الموظفين (تعيين الأدوار)'),
            Tab(icon: Icon(Icons.security), text: 'قوالب الصلاحيات (الأدوار)'),
          ],
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.status == AdminStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'خطأ'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUsersTab(context, state),
              _buildRolesTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, AdminState state) {
    final myUserId = context.watch<AuthCubit>().state.userId;

    return CustomScrollView(
      slivers: [
        if (state.pendingUsers.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'طلبات انضمام بانتظار الموافقة (${state.pendingUsers.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = state.pendingUsers[index];
                return Card(
                  elevation: 0,
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.shade200),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange.shade200,
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? 'بدون اسم',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            hint: const Text('حدد الدور أولاً'),
                            value: user.roleId?.isNotEmpty == true
                                ? user.roleId
                                : null,
                            items: state.roles.map((role) {
                              return DropdownMenuItem(
                                value: role.id,
                                child: Text(role.name),
                              );
                            }).toList(),
                            onChanged: (newRoleId) {
                              context.read<AdminCubit>().updateUser(
                                user.id,
                                newRoleId,
                                false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: user.roleId == null || user.roleId!.isEmpty
                              ? null
                              : () {
                                  context.read<AdminCubit>().updateUser(
                                    user.id,
                                    user.roleId,
                                    true,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم قبول الموظف بنجاح!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.check),
                          label: const Text('قبول وتفعيل'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: state.pendingUsers.length,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'الموظفون الحاليون (${state.activeUsers.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = state.activeUsers[index];
              final isMe = user.id == myUserId;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Row(
                    children: [
                      Text(
                        user.fullName ?? user.email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'أنت',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(user.email),
                  trailing: SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: user.roleId,
                            items: state.roles.map((role) {
                              return DropdownMenuItem(
                                value: role.id,
                                child: Text(role.name),
                              );
                            }).toList(),
                            onChanged: isMe
                                ? null
                                : (newRoleId) {
                                    context.read<AdminCubit>().updateUser(
                                      user.id,
                                      newRoleId,
                                      user.isActive,
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: user.isActive,
                          activeColor: Colors.green,
                          onChanged: isMe
                              ? null
                              : (val) {
                                  context.read<AdminCubit>().updateUser(
                                    user.id,
                                    user.roleId,
                                    val,
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: state.activeUsers.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  Widget _buildRolesTab(BuildContext context, AdminState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إنشاء قالب دور جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showRoleDialog(context, null),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.roles.length,
            itemBuilder: (context, index) {
              final role = state.roles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.shield,
                    color: Colors.amber,
                    size: 36,
                  ),
                  title: Text(
                    role.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    role.isSystemRole ? 'دور أساسي في النظام' : 'دور مخصص',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_square, color: Colors.blue),
                    onPressed: () => _showRoleDialog(context, role),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRoleDialog(BuildContext parentContext, AppRole? role) {
    final nameController = TextEditingController(text: role?.name ?? '');
    var currentPerms = <String>[];

    if (role != null && role.permissionsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(role.permissionsJson) as Iterable<dynamic>;
        currentPerms = List<String>.from(decoded);
      } catch (_) {
        // إذا فشل فك التشفير، نبقي القائمة فارغة
      }
    }

    unawaited(
      showDialog<void>(
        context: parentContext,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(role == null ? 'دور جديد' : 'تعديل: ${role.name}'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == null)
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم الدور (مثال: محاسب فرع)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'الصلاحيات الممنوحة:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: AppPermissions.all.map((permCode) {
                            final hasPerm = currentPerms.contains(permCode);
                            return CheckboxListTile(
                              title: Text(
                                permissionNames[permCode] ?? permCode,
                              ),
                              value: hasPerm,
                              activeColor: Colors.blueGrey.shade900,
                              onChanged: role?.isSystemRole == true
                                  ? null
                                  : (bool? val) {
                                      setState(() {
                                        if (val == true) {
                                          currentPerms.add(permCode);
                                        } else {
                                          currentPerms.remove(permCode);
                                        }
                                      });
                                    },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade900,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (role == null) {
                        if (nameController.text.trim().isNotEmpty) {
                          parentContext.read<AdminCubit>().createNewRole(
                            nameController.text.trim(),
                            currentPerms,
                          );
                          Navigator.pop(ctx);
                        }
                      } else {
                        parentContext.read<AdminCubit>().updateRole(
                          role.id,
                          currentPerms,
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
