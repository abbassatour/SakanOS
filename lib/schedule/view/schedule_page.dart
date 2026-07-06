// lib/schedule/view/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/schedule_cubit.dart';

import 'tabs/radar_tab.dart';
import 'tabs/traditional_schedule_tab.dart';
import 'tabs/overdue_radar_tab.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 🌟 1. إنشاء المتحكم وقراءة الرقم الحالي من الكيوبت (في حال تم فتحه من شاشة أخرى)
    final initialIndex = context.read<ScheduleCubit>().state.activeTabIndex;
    _tabController = TabController(
      initialIndex: initialIndex,
      length: 3,
      vsync: this,
    );

    // 🌟 2. إذا قام المستخدم بتغيير التبويب بيده (سحب الشاشة)، نخبر الكيوبت
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final cubit = context.read<ScheduleCubit>();
        if (cubit.state.activeTabIndex != _tabController.index) {
          cubit.changeTab(_tabController.index);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 3. السحر هنا: نستمع للكيوبت بشكل دائم، وإذا أرسل أمر انتقال، نحرك الشاشة آلياً!
    return BlocListener<ScheduleCubit, ScheduleState>(
      listenWhen: (previous, current) =>
          previous.activeTabIndex != current.activeTabIndex,
      listener: (context, state) {
        if (_tabController.index != state.activeTabIndex) {
          _tabController.animateTo(state.activeTabIndex);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          elevation: 0,
          toolbarHeight: 70,
          title: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController, // 🌟 ربط المتحكم الذكي
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelPadding: EdgeInsets.zero,
              tabs: [
                _buildCompactTab(Icons.warning_amber_rounded, 'المتعثرين'),
                _buildCompactTab(Icons.radar, 'الرادار'),
                _buildCompactTab(Icons.table_chart, 'الجدول'),
              ],
            ),
          ),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state.status == ScheduleStatus.loading &&
                state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.clients.isEmpty || state.contracts.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد بيانات كافية.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return TabBarView(
              controller: _tabController, // 🌟 ربط المتحكم بالشاشات الداخلية
              children: [
                OverdueRadarTab(state: state), // Index 0
                RadarTab(state: state), // Index 1
                TraditionalScheduleTab(state: state), // Index 2
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 دالة مساعدة لإنشاء التبويبات
  Widget _buildCompactTab(IconData icon, String title) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
