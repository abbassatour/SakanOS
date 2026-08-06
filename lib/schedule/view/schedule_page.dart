// lib/schedule/view/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../cubit/schedule_cubit.dart';

import 'tabs/radar_tab.dart';
import 'tabs/traditional_schedule_tab.dart';
import 'tabs/overdue_radar_tab.dart';

// 🌟 دالة تحليل وترجمة مفاتيح أخطاء المراقبة
String _resolveScheduleErrorMessage(BuildContext context, String? errorKey) {
  final l10n = context.l10n;
  if (errorKey == null) return l10n.homeUnexpectedError;

  if (errorKey.startsWith('scheduleErrorSaveAction:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorSaveAction:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorSaveAction(err);
  }
  if (errorKey.startsWith('scheduleErrorUpdateDate:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorUpdateDate:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorUpdateDate(err);
  }
  if (errorKey.startsWith('scheduleErrorReschedule:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorReschedule:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorReschedule(err);
  }
  if (errorKey.startsWith('scheduleErrorUpdateSchedule:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorUpdateSchedule:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorUpdateSchedule(err);
  }
  if (errorKey.startsWith('scheduleErrorAddSeasonal:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorAddSeasonal:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorAddSeasonal(err);
  }
  if (errorKey.startsWith('scheduleErrorGeneral:')) {
    final err = errorKey
        .replaceFirst('scheduleErrorGeneral:', '')
        .replaceAll('Exception: ', '')
        .trim();
    return l10n.scheduleErrorGeneral(err);
  }

  return errorKey.replaceAll('Exception: ', '').trim();
}

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
    final initialIndex = context.read<ScheduleCubit>().state.activeTabIndex;
    _tabController = TabController(
      initialIndex: initialIndex,
      length: 3,
      vsync: this,
    );

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
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<ScheduleCubit, ScheduleState>(
          listenWhen: (previous, current) =>
              previous.activeTabIndex != current.activeTabIndex,
          listener: (context, state) {
            if (_tabController.index != state.activeTabIndex) {
              _tabController.animateTo(state.activeTabIndex);
            }
          },
        ),
        // 🌟 الاستماع للأخطاء وإظهارها مترجمة
        BlocListener<ScheduleCubit, ScheduleState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ScheduleStatus.failure) {
              final resolvedMsg = _resolveScheduleErrorMessage(
                context,
                state.errorMessage,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    resolvedMsg,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
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
              controller: _tabController,
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
                _buildCompactTab(
                  Icons.warning_amber_rounded,
                  l10n.scheduleTabOverdue,
                ),
                _buildCompactTab(Icons.radar, l10n.scheduleTabRadar),
                _buildCompactTab(
                  Icons.table_chart,
                  l10n.scheduleTabTraditional,
                ),
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
              return Center(
                child: Text(
                  l10n.scheduleNoData,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                OverdueRadarTab(state: state),
                RadarTab(state: state),
                TraditionalScheduleTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }

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
