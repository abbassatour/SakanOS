// lib/dashboard/view/dashboard_page.dart
import 'dart:io';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../admin/view/admin_page.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';
import '../../buildings/view/buildings_page.dart';
import '../../clients/cubit/clients_cubit.dart';
import '../../clients/view/clients_page.dart';
import '../../contracts/cubit/contracts_cubit.dart';
import '../../contracts/view/contracts_page.dart';
import '../../core/constants/app_permissions.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/view/home_page.dart';
import '../../l10n/l10n.dart'; // 🌟 استدعاء مكتبة الترجمة
import '../../legal/cubit/legal_affairs_cubit.dart';
import '../../legal/view/legal_affairs_page.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../payments/view/payments_page.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import '../../schedule/view/schedule_page.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/view/settings_page.dart';
import '../cubit/dashboard_cubit.dart';

class NavTab {
  NavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final void Function(BuildContext) onSelected;
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ErpRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => HomeCubit(repo)..fetchDashboardData()),
        BlocProvider(
          create: (_) => ClientsCubit(erpRepository: repo)..fetchClients(),
        ),
        BlocProvider(create: (_) => BuildingsCubit(repo)..loadData()),
        BlocProvider(create: (_) => ContractsCubit(repo)..fetchData()),
        BlocProvider(create: (_) => PaymentsCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => ScheduleCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => SettingsCubit(repo)..fetchPrices()),
        BlocProvider(create: (_) => LegalAffairsCubit(repo)..fetchData()),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<DashboardCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final l10n = context.l10n; // 🌟 استخدام اختصار الترجمة

    final availableTabs = <NavTab>[
      // 1. الرئيسية
      NavTab(
        label: l10n.navHome,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        page: const HomePage(),
        onSelected: (ctx) => ctx.read<HomeCubit>().fetchDashboardData(),
      ),
    ];

    // 2. العملاء
    if (authState.hasPermission(AppPermissions.viewClients)) {
      availableTabs.add(
        NavTab(
          label: l10n.navClients,
          icon: Icons.people_alt_outlined,
          selectedIcon: Icons.people_alt,
          page: const ClientsPage(),
          onSelected: (ctx) => ctx.read<ClientsCubit>().fetchClients(),
        ),
      );
    }

    // 3. المشاريع
    if (authState.hasPermission(AppPermissions.manageBuildings)) {
      availableTabs.add(
        NavTab(
          label: l10n.navProjects,
          icon: Icons.domain_outlined,
          selectedIcon: Icons.domain,
          page: const BuildingsPage(),
          onSelected: (ctx) => ctx.read<BuildingsCubit>().loadData(),
        ),
      );
    }

    // 4. العقود
    if (authState.hasPermission(AppPermissions.viewContracts)) {
      availableTabs.add(
        NavTab(
          label: l10n.navContracts,
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          page: const ContractsPage(),
          onSelected: (ctx) => ctx.read<ContractsCubit>().fetchData(),
        ),
      );
    }

    // 5. الأقساط
    if (authState.hasPermission(AppPermissions.viewPayments)) {
      availableTabs.add(
        NavTab(
          label: l10n.navInstallments,
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          page: const PaymentsPage(),
          onSelected: (ctx) => ctx.read<PaymentsCubit>().fetchInitialData(),
        ),
      );
    }

    // 6. المراقبة
    if (authState.hasPermission(AppPermissions.viewPayments)) {
      availableTabs.add(
        NavTab(
          label: l10n.navMonitoring,
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          page: const SchedulePage(),
          onSelected: (ctx) => ctx.read<ScheduleCubit>().fetchInitialData(),
        ),
      );
    }

    // 7. الإعدادات
    if (authState.hasPermission(AppPermissions.viewPrices)) {
      availableTabs.add(
        NavTab(
          label: l10n.navSettings,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          page: const SettingsPage(),
          onSelected: (ctx) => ctx.read<SettingsCubit>().fetchPrices(),
        ),
      );
    }

    // 8. الشؤون القانونية
    if (authState.hasPermission(AppPermissions.viewLegalAffairs)) {
      availableTabs.add(
        NavTab(
          label: l10n.navLegal,
          icon: Icons.gavel_outlined,
          selectedIcon: Icons.gavel,
          page: const LegalAffairsPage(),
          onSelected: (ctx) => ctx.read<LegalAffairsCubit>().fetchData(),
        ),
      );
    }

    // 9. لوحة الإدارة
    if (authState.isSystemAdmin) {
      availableTabs.add(
        NavTab(
          label: l10n.navAdmin,
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings,
          page: const AdminPage(),
          onSelected: (ctx) {},
        ),
      );
    }

    var safeIndex = selectedIndex;
    if (safeIndex >= availableTabs.length) {
      safeIndex = 0;
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) {
              context.read<DashboardCubit>().changeTab(index);
              availableTabs[index].onSelected(context);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade50,
            indicatorColor: Colors.white,
            unselectedIconTheme: IconThemeData(
              color: Colors.blueGrey.shade400,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.blueGrey.shade600,
            ),
            selectedIconTheme: IconThemeData(
              color: Colors.blue.shade700,
              size: 30,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
            destinations: availableTabs
                .map(
                  (tab) => NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: Text(tab.label),
                  ),
                )
                .toList(),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authState.roleName ?? '',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _PinSessionIndicator(),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: Icon(
                          Icons.sync,
                          color: Colors.teal.shade600,
                          size: 28,
                        ),
                        tooltip: l10n.navSyncTooltip,
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.navCheckingInternet),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          var hasInternet = false;

                          try {
                            final result = await InternetAddress.lookup(
                              'google.com',
                            ).timeout(const Duration(seconds: 5));
                            if (result.isNotEmpty &&
                                result[0].rawAddress.isNotEmpty) {
                              hasInternet = true;
                            }
                          } catch (_) {
                            hasInternet = false;
                          }

                          if (!hasInternet) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.wifi_off,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(l10n.navNoInternet),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade800,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.navSyncingData),
                                duration: const Duration(seconds: 10),
                              ),
                            );
                          }

                          try {
                            final resultMessage = await context
                                .read<ErpRepository>()
                                .forceSyncWithCloud();

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(resultMessage),
                                  backgroundColor:
                                      resultMessage.contains('بنجاح')
                                      ? Colors.green
                                      : Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.read<AuthCubit>().checkSession();
                              availableTabs[safeIndex].onSelected(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.navSyncError(e.toString()),
                                  ),
                                  backgroundColor: Colors.red.shade900,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red.shade400,
                          size: 28,
                        ),
                        tooltip: l10n.navLogoutTooltip,
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                l10n.logoutDialogTitle,
                                style: const TextStyle(color: Colors.red),
                              ),
                              content: Text(l10n.logoutDialogMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(l10n.logoutCancel),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await context.read<AuthCubit>().logout();
                                  },
                                  child: Text(l10n.logoutConfirm),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.blue.shade100,
          ),
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: availableTabs.map((tab) => tab.page).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinSessionIndicator extends StatelessWidget {
  const _PinSessionIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isActive = state.isPinGracePeriodActive;

        if (!isActive) {
          return Tooltip(
            message: l10n.pinLockedTooltip,
            child: IconButton(
              icon: Icon(
                Icons.lock_outline,
                color: Colors.blueGrey.shade400,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pinLockedMessage),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        }

        final expiryTime = state.lastPinVerificationTime!.add(
          const Duration(minutes: 5),
        );
        final remainingDuration = expiryTime.difference(DateTime.now());
        final remainingSeconds = remainingDuration.inSeconds.clamp(0, 300);
        final percentage = remainingSeconds / 300.0;

        return Tooltip(
          message: l10n.pinUnlockedTooltip,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: percentage, end: 0.0),
                  duration: Duration(seconds: remainingSeconds),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      color: Colors.teal.shade500,
                      backgroundColor: Colors.transparent,
                      strokeWidth: 2.5,
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.lock_open,
                  color: Colors.teal.shade700,
                ),
                onPressed: () {
                  context.read<AuthCubit>().lockPinSession();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.pinLockedSuccess),
                      backgroundColor: Colors.blueGrey,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
