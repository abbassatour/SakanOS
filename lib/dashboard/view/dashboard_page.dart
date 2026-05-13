// lib/dashboard/view/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';

// استدعاء AuthCubit والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

// استدعاء الشاشات
import '../../home/view/home_page.dart';
import '../../clients/view/clients_page.dart';
import '../../buildings/view/buildings_page.dart';
import '../../contracts/view/contracts_page.dart';
import '../../payments/view/payments_page.dart';
import '../../schedule/view/schedule_page.dart';
import '../../settings/view/settings_page.dart';
import '../../admin/view/admin_page.dart';
// 🌟 استدعاء شاشة الشؤون القانونية والأرشيف
import '../../legal/view/legal_affairs_page.dart';

// استدعاء المتحكمات
import '../../clients/cubit/clients_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';
import '../../contracts/cubit/contracts_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../home/cubit/home_cubit.dart';
import '../cubit/dashboard_cubit.dart';
// 🌟 استدعاء كيوبت الشؤون القانونية
import '../../legal/cubit/legal_affairs_cubit.dart';

// ==========================================
// 🧩 كلاس مساعد لتعريف التبويبات بمرونة
// ==========================================
class NavTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final void Function(BuildContext) onSelected; // ماذا يفعل عند الضغط عليه

  NavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    required this.onSelected,
  });
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ErpRepository>();
    
    return MultiBlocProvider(
      providers:[
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => HomeCubit(repo)..fetchDashboardData()),
        BlocProvider(create: (_) => ClientsCubit(repo)..fetchClients()),
        BlocProvider(create: (_) => BuildingsCubit(repo)..loadData()),
        BlocProvider(create: (_) => ContractsCubit(repo)..fetchData()),
        BlocProvider(create: (_) => PaymentsCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => ScheduleCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => SettingsCubit(repo)..fetchPrices()),
        // 🌟 حقن الـ Cubit الخاص بالشؤون القانونية والأرشيف
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

    // ==========================================
    // 🌟 بناء قائمة التبويبات بناءً على الصلاحيات الحقيقية
    // ==========================================
    List<NavTab> availableTabs =[
      // 1. الرئيسية (الكل يراها)
      NavTab(
        label: 'الرئيسية',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        page: const HomePage(),
        onSelected: (ctx) => ctx.read<HomeCubit>().fetchDashboardData(),
      ),
    ];

    // 2. العملاء
    if (authState.hasPermission(AppPermissions.viewClients)) {
      availableTabs.add(NavTab(
        label: 'العملاء',
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt,
        page: const ClientsPage(),
        onSelected: (ctx) => ctx.read<ClientsCubit>().fetchClients(),
      ));
    }

    // 3. المشاريع
    if (authState.hasPermission(AppPermissions.manageBuildings)) {
      availableTabs.add(NavTab(
        label: 'المشاريع',
        icon: Icons.domain_outlined,
        selectedIcon: Icons.domain,
        page: const BuildingsPage(),
        onSelected: (ctx) => ctx.read<BuildingsCubit>().loadData(),
      ));
    }

    // 4. العقود
    if (authState.hasPermission(AppPermissions.viewContracts)) {
      availableTabs.add(NavTab(
        label: 'العقود',
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        page: const ContractsPage(),
        onSelected: (ctx) => ctx.read<ContractsCubit>().fetchData(),
      ));
    }

    // ==========================================
    // 🌟 5. [التبويب الجديد]: الشؤون القانونية والأرشيف
    // ==========================================
    if (authState.hasPermission(AppPermissions.viewLegalAffairs)) {
      availableTabs.add(NavTab(
        label: 'القانونية',
        icon: Icons.gavel_outlined,
        selectedIcon: Icons.gavel,
        page: const LegalAffairsPage(),
        onSelected: (ctx) => ctx.read<LegalAffairsCubit>().fetchData(),
      ));
    }

    // 6. الأقساط والدفعات
    if (authState.hasPermission(AppPermissions.viewPayments)) {
      availableTabs.add(NavTab(
        label: 'الأقساط',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        page: const PaymentsPage(),
        onSelected: (ctx) => ctx.read<PaymentsCubit>().fetchInitialData(),
      ));
    }

    // 7. المراقبة
    if (authState.hasPermission(AppPermissions.viewPayments)) {
      availableTabs.add(NavTab(
        label: 'المراقبة',
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        page: const SchedulePage(),
        onSelected: (ctx) => ctx.read<ScheduleCubit>().fetchInitialData(),
      ));
    }

    // 8. الإعدادات
    if (authState.hasPermission(AppPermissions.viewPrices)) {
      availableTabs.add(NavTab(
        label: 'الإعدادات',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        page: const SettingsPage(),
        onSelected: (ctx) => ctx.read<SettingsCubit>().fetchPrices(),
      ));
    }

    // 9. لوحة تحكم الإدارة (خاصة بالـ Super Admin فقط)
    if (authState.isSystemAdmin) {
      availableTabs.add(NavTab(
        label: 'الإدارة',
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
        page: const AdminPage(),
        onSelected: (ctx) {
          // لا يوجد Cubit نحتاج لاستدعائه هنا لأن AdminPage تبني الـ Cubit الخاص بها
        },
      ));
    }

    // حماية إضافية: إذا كان الـ index المحفوظ أكبر من عدد التبويبات المتاحة
    int safeIndex = selectedIndex;
    if (safeIndex >= availableTabs.length) {
      safeIndex = 0; 
    }

    return Scaffold(
      body: Row(
        children:[
          NavigationRail(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) {
              context.read<DashboardCubit>().changeTab(index);
              availableTabs[index].onSelected(context);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade900,
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            
            destinations: availableTabs.map((tab) => NavigationRailDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: Text(tab.label),
            )).toList(),
            
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      Text(
                        authState.roleName ?? '',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      IconButton(
                        icon: const Icon(Icons.sync, color: Colors.greenAccent, size: 28),
                        tooltip: 'مزامنة يدوية مع السحابة (Pull & Push)',
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('جاري المزامنة مع السحابة... ☁️🔄')),
                          );
                          
                          final resultMessage = await context.read<ErpRepository>().forceSyncWithCloud();
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultMessage), 
                                backgroundColor: resultMessage.contains('بنجاح') ? Colors.green : Colors.red,
                              ),
                            );
                            context.read<AuthCubit>().checkSession();
                            availableTabs[safeIndex].onSelected(context);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
                        tooltip: 'تسجيل الخروج (وإقفال النظام)',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                              content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟ سيتم إقفال ومسح البيانات المؤقتة من هذا الجهاز لحمايتها.'),
                              actions:[
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await context.read<AuthCubit>().logout();
                                  },
                                  child: const Text('تأكيد الخروج'),
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
          
          const VerticalDivider(thickness: 1, width: 1),
          
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