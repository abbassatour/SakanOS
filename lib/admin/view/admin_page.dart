// lib/admin/view/admin_page.dart
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/admin/cubit/admin_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../widgets/widgets.dart';

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

  String _resolveAdminErrorMessage(BuildContext context, String? errorMsg) {
    final l10n = context.l10n;
    if (errorMsg == null) return l10n.adminUnexpectedError;
    if (errorMsg.startsWith('adminRoleDeleteHasUsersError:')) {
      final parts = errorMsg.split(':');
      if (parts.length >= 3) {
        final roleName = parts[1];
        final count = int.tryParse(parts[2]) ?? 0;
        return l10n.adminRoleDeleteHasUsersError(roleName, count);
      }
    }
    return errorMsg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state.status == AdminStatus.failure) {
              final resolvedMsg = _resolveAdminErrorMessage(
                context,
                state.errorMessage,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resolvedMsg),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blueGrey.shade800,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.adminPageTitle,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.blueGrey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: Colors.amber,
                          unselectedLabelColor: Colors.blueGrey.shade600,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.group, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.adminTabUsers,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shield, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.adminTabRoles,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      UsersTab(state: state),
                      RolesTab(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
