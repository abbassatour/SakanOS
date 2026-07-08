// lib/admin/widgets/users_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';

class UsersTab extends StatelessWidget {
  final AdminState state;

  const UsersTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final myUserId = context.watch<AuthCubit>().state.userId;

    return CustomScrollView(
      slivers: [
        // 🌟 1. قسم المستخدمين المعلقين
        if (state.pendingUsers.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
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
                    horizontal: 24,
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
                          width: 200,
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
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

        // 🌟 2. قسم المستخدمين النشطين
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: user.roleId,
                              items: state.roles.map((role) {
                                return DropdownMenuItem(
                                  value: role.id,
                                  child: Text(
                                    role.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
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
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: user.isActive
                              ? 'تعطيل حساب الموظف'
                              : 'تفعيل الحساب',
                          child: Switch(
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
}
