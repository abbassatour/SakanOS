// lib/admin/view/admin_page.dart
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

  // ترجمة أسماء الصلاحيات
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

  // 🌟 [التحسين الأول]: تجميع الصلاحيات حسب الأقسام
  final Map<String, List<String>> permissionGroups = {
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

  // 🌟 أيقونات لكل قسم لجمالية الواجهة
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
            Tab(icon: Icon(Icons.shield), text: 'قوالب الصلاحيات (الأدوار)'),
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

  // ==========================================
  // تبويب المستخدمين (بقي كما هو)
  // ==========================================
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

  // ==========================================
  // تبويب القوالب والأدوار (بقي كما هو خارج الديالوج)
  // ==========================================
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  leading: Icon(
                    role.isSystemRole ? Icons.shield : Icons.manage_accounts,
                    color: role.isSystemRole
                        ? Colors.red
                        : Colors.amber.shade700,
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
                    role.isSystemRole
                        ? 'دور أساسي (غير قابل للتعديل الكامل)'
                        : 'دور مخصص',
                  ),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_square, size: 18),
                    label: const Text('تعديل الصلاحيات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade50,
                      foregroundColor: Colors.blueGrey.shade900,
                      elevation: 0,
                    ),
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

  // ==========================================
  // 🌟 [التحسين الجديد]: نافذة تعيين الصلاحيات
  // ==========================================
  void _showRoleDialog(BuildContext parentContext, AppRole? role) {
    final nameController = TextEditingController(text: role?.name ?? '');
    var currentPerms = <String>[];

    if (role != null && role.permissionsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(role.permissionsJson) as Iterable<dynamic>;
        currentPerms = List<String>.from(decoded);
      } catch (_) {
        // تجاهل في حال الفشل
      }
    }

    unawaited(
      showDialog<void>(
        context: parentContext,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              final isSystemRole = role?.isSystemRole ?? false;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      isSystemRole ? Icons.shield : Icons.edit_note,
                      color: Colors.blueGrey.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      role == null
                          ? 'بناء دور وظيفي جديد'
                          : 'تعديل صلاحيات: ${role.name}',
                      style: TextStyle(
                        color: Colors.blueGrey.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 700, // توسيع النافذة قليلاً لتناسب التصميم
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (role == null) ...[
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText:
                                'اسم الدور (مثال: محاسب، محامي، مدير فرع)',
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
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSystemRole
                                    ? 'هذا الدور أساسي في النظام ولا يمكن تعديل صلاحياته لتجنب الأخطاء.'
                                    : 'قم باختيار الصلاحيات المناسبة لهذا الدور. أي موظف يتم تعيينه بهذا الدور سيكتسب هذه الصلاحيات فوراً.',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🌟 بناء الأقسام (Modules) باستخدام ExpansionTile
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: permissionGroups.entries.map((entry) {
                            final groupName = entry.key;
                            final groupPerms = entry.value;

                            // حساب عدد الصلاحيات المحددة في هذا القسم
                            final selectedCount = groupPerms
                                .where((p) => currentPerms.contains(p))
                                .length;
                            final isAllSelected =
                                selectedCount == groupPerms.length;

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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$selectedCount من ${groupPerms.length} محددة',
                                    style: TextStyle(
                                      color: selectedCount == groupPerms.length
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  children: [
                                    // 🌟 زر تحديد الكل
                                    Container(
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
                                                    // إضافة الصلاحيات غير الموجودة
                                                    currentPerms.addAll(
                                                      groupPerms.where(
                                                        (p) => !currentPerms
                                                            .contains(p),
                                                      ),
                                                    );
                                                  } else {
                                                    // إزالة كل صلاحيات هذا القسم
                                                    currentPerms.removeWhere(
                                                      (p) => groupPerms
                                                          .contains(p),
                                                    );
                                                  }
                                                });
                                              },
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    // 🌟 الصلاحيات الفردية
                                    ...groupPerms.map((permCode) {
                                      final hasPerm = currentPerms.contains(
                                        permCode,
                                      );
                                      return CheckboxListTile(
                                        title: Text(
                                          permissionNames[permCode] ?? permCode,
                                        ),
                                        value: hasPerm,
                                        activeColor: Colors.blueGrey.shade800,
                                        onChanged: isSystemRole
                                            ? null
                                            : (bool? val) {
                                                setState(() {
                                                  if (val == true) {
                                                    currentPerms.add(permCode);
                                                  } else {
                                                    currentPerms.remove(
                                                      permCode,
                                                    );
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
                actionsPadding: const EdgeInsets.all(16),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isSystemRole)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'حفظ الصلاحيات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (role == null) {
                          if (nameController.text.trim().isNotEmpty) {
                            parentContext.read<AdminCubit>().createNewRole(
                              nameController.text.trim(),
                              currentPerms,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('تم إنشاء الدور بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          parentContext.read<AdminCubit>().updateRole(
                            role.id,
                            currentPerms,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(parentContext).showSnackBar(
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
            },
          );
        },
      ),
    );
  }
}
