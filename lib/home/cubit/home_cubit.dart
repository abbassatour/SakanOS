// lib/home/cubit/home_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show PaymentsLedgerData;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository)
    : super(HomeState(referenceDate: DateTime.now()));

  final ErpRepository _erpRepository;

  // 🌟 دالة مساعدة لتحويل TimeFilter الخاص بالـ State إلى DashboardTimeFilter الخاص بالـ Repo
  DashboardTimeFilter _mapTimeFilter(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return DashboardTimeFilter.daily;
      case TimeFilter.weekly:
        return DashboardTimeFilter.weekly;
      case TimeFilter.monthly:
        return DashboardTimeFilter.monthly;
      case TimeFilter.yearly:
        return DashboardTimeFilter.yearly;
    }
  }

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final metrics = await _erpRepository.getDashboardMetrics(
        timeFilter: _mapTimeFilter(state.timeFilter),
        refDate: state.referenceDate,
      );

      emit(
        state.copyWith(
          status: HomeStatus.success,
          totalRevenue: metrics.totalRevenue,
          totalAreaSold: metrics.totalAreaSold,
          totalPaidMeters: metrics.totalPaidMeters,
          totalOverdueDebts: metrics.totalOverdueDebts,
          totalUndeliveredMeters: metrics.totalUndeliveredMeters,
          inventoryStatus: metrics.inventoryStatus,
          activeContractsCount: metrics.activeContractsCount,
          latestPayments: metrics.latestPayments,
          groupedRevenue: metrics.groupedRevenue,
          dollarTrend: metrics.dollarTrend,
          costTrend: metrics.costTrend,
          contractsByType: metrics.contractsByType,
          recentActivities: metrics.recentActivities,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void changeTimeFilter(TimeFilter newFilter) {
    emit(
      state.copyWith(timeFilter: newFilter, referenceDate: DateTime.now()),
    );
    fetchDashboardData(); // جلب البيانات الجديدة من المستودع
  }

  void navigatePrevious() {
    var newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        newDate = newDate.subtract(const Duration(days: 7));
        break;
      case TimeFilter.weekly:
        newDate = DateTime(newDate.year, newDate.month - 1);
        break;
      case TimeFilter.monthly:
        newDate = DateTime(newDate.year - 1, newDate.month);
        break;
      case TimeFilter.yearly:
        newDate = DateTime(newDate.year - 5, newDate.month);
        break;
    }
    emit(state.copyWith(referenceDate: newDate));
    fetchDashboardData();
  }

  void navigateNext() {
    var newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        newDate = newDate.add(const Duration(days: 7));
        break;
      case TimeFilter.weekly:
        newDate = DateTime(newDate.year, newDate.month + 1);
        break;
      case TimeFilter.monthly:
        newDate = DateTime(newDate.year + 1, newDate.month);
        break;
      case TimeFilter.yearly:
        newDate = DateTime(newDate.year + 5, newDate.month);
        break;
    }
    if (newDate.isAfter(DateTime.now())) newDate = DateTime.now();

    emit(state.copyWith(referenceDate: newDate));
    fetchDashboardData();
  }
}
