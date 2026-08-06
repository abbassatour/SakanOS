// lib/schedule/cubit/schedule_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._erpRepository) : super(const ScheduleState());

  final ErpRepository _erpRepository;
  final double targetAllocationMeters = 50.0;

  void changeTab(int index) {
    emit(state.copyWith(activeTabIndex: index));
  }

  Future<void> fetchInitialData() async {
    if (state.status == ScheduleStatus.initial) {
      emit(state.copyWith(status: ScheduleStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();

      final allocationAlerts = await _generateAllocationRadar(
        contracts,
        clients,
      );

      final overdueAlerts = await _generateOverdueRadar(contracts, clients);

      if (isClosed) return;

      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          clients: clients,
          contracts: contracts,
          allocationAlerts: allocationAlerts,
          overdueAlerts: overdueAlerts,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<List<OverdueContractAlert>> _generateOverdueRadar(
    List<Contract> allContracts,
    List<Client> allClients,
  ) async {
    final allOverdueSchedules = await _erpRepository.getAllOverdueSchedules();

    final grouped = <String, List<InstallmentsScheduleData>>{};
    for (final s in allOverdueSchedules) {
      grouped.putIfAbsent(s.contractId, () => []).add(s);
    }

    final alerts = <OverdueContractAlert>[];
    final now = SecureTime.now();

    grouped.forEach((contractId, schedules) {
      final contractIdx = allContracts.indexWhere((c) => c.id == contractId);
      if (contractIdx == -1) return;
      final contract = allContracts[contractIdx];

      if (contract.isCompleted) return;

      final clientIdx = allClients.indexWhere(
        (c) => c.id == contract.clientId,
      );
      if (clientIdx == -1) return;
      final client = allClients[clientIdx];

      final oldestSchedule = schedules.first;
      final maxDaysOverdue = now.difference(oldestSchedule.dueDate).inDays;

      var severity = 'notice';
      if (maxDaysOverdue >= 60) {
        severity = 'critical';
      } else if (maxDaysOverdue >= 30) {
        severity = 'warning';
      }

      alerts.add(
        OverdueContractAlert(
          contract: contract,
          client: client,
          overdueSchedules: schedules,
          maxDaysOverdue: maxDaysOverdue,
          severity: severity,
        ),
      );
    });

    alerts.sort((a, b) => b.maxDaysOverdue.compareTo(a.maxDaysOverdue));

    return alerts;
  }

  Future<List<AllocationAlertData>> _generateAllocationRadar(
    List<Contract> allContracts,
    List<Client> allClients,
  ) async {
    final radarList = <AllocationAlertData>[];

    final unallocatedContracts = allContracts
        .where((c) => c.contractType == 'لاحق التخصص' && !c.isCompleted)
        .toList();

    for (final contract in unallocatedContracts) {
      final clientIdx = allClients.indexWhere(
        (c) => c.id == contract.clientId,
      );
      if (clientIdx == -1) continue;
      final client = allClients[clientIdx];

      final ledger = await _erpRepository.getContractLedger(contract.id);
      final accumulatedMeters = ledger.fold(
        0.0,
        (sum, item) => sum + item.convertedMeters,
      );

      final startDate = contract.contractDate;
      var monthsPassed = DateTime.now().difference(startDate).inDays ~/ 30;
      if (monthsPassed < 1) monthsPassed = 1;

      final averageMetersPerMonth = accumulatedMeters / monthsPassed;

      var estimatedMonthsLeft = 999;
      if (averageMetersPerMonth > 0) {
        var metersLeft = targetAllocationMeters - accumulatedMeters;
        if (metersLeft < 0) metersLeft = 0;
        final double calcMonths = metersLeft / averageMetersPerMonth;
        if (calcMonths.isInfinite || calcMonths.isNaN) {
          estimatedMonthsLeft = 999;
        } else {
          final int ceilMonths = calcMonths.ceil();
          estimatedMonthsLeft = ceilMonths > 999 ? 999 : ceilMonths;
        }
      }

      var hasRecentAction = false;
      if (contract.lastActionDate != null) {
        final daysSinceAction = DateTime.now()
            .difference(contract.lastActionDate!)
            .inDays;
        if (daysSinceAction < 30) {
          hasRecentAction = true;
        }
      }

      var urgency = 'low';
      if (hasRecentAction) {
        urgency = 'action_taken';
      } else if (accumulatedMeters >= targetAllocationMeters ||
          estimatedMonthsLeft <= 2) {
        urgency = 'high';
      } else if (estimatedMonthsLeft <= 6) {
        urgency = 'medium';
      }

      radarList.add(
        AllocationAlertData(
          contract: contract,
          client: client,
          accumulatedMeters: accumulatedMeters,
          averageMetersPerMonth: averageMetersPerMonth,
          estimatedMonthsLeft: estimatedMonthsLeft,
          urgencyLevel: urgency,
          lastActionDate: contract.lastActionDate,
          lastActionNote: contract.lastActionNote,
        ),
      );
    }

    radarList.sort((a, b) {
      if (a.urgencyLevel == 'action_taken' &&
          b.urgencyLevel != 'action_taken') {
        return 1;
      }
      if (b.urgencyLevel == 'action_taken' &&
          a.urgencyLevel != 'action_taken') {
        return -1;
      }
      return a.estimatedMonthsLeft.compareTo(b.estimatedMonthsLeft);
    });

    return radarList;
  }

  Future<void> markContractActionTaken(String contractId, String note) async {
    try {
      await _erpRepository.markContractActionTaken(
        contractId: contractId,
        note: note,
      );
      await fetchInitialData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorSaveAction:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId));
    try {
      final scheduleList = await _erpRepository.getContractSchedule(contractId);
      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          scheduleList: scheduleList,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsPaid(String scheduleId, String contractId) async {
    try {
      await _erpRepository.updateScheduleStatus(scheduleId, 'paid');
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateContractDateOnly({
    required String id,
    required DateTime contractDate,
  }) async {
    try {
      await _erpRepository.updateContractDateOnly(
        id: id,
        contractDate: contractDate,
      );
      await fetchInitialData();
      await selectContract(id);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorUpdateDate:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }

  Future<void> restructureSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    try {
      await _erpRepository.restructureContractSchedule(
        contractId: contractId,
        newRemainingMonths: newRemainingMonths,
        newStartDate: newStartDate,
      );

      await fetchInitialData();
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorReschedule:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }

  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required String contractId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount,
  }) async {
    try {
      await _erpRepository.updateIndividualSchedule(
        scheduleId: scheduleId,
        newDueDate: newDueDate,
        notes: notes,
        expectedAmount: expectedAmount,
      );

      await fetchInitialData();
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorUpdateSchedule:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }

  Future<void> addCustomSeasonalSchedule({
    required String contractId,
    required DateTime dueDate,
    required String notes,
    required double expectedAmount,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _erpRepository.addCustomSchedule(
        contractId: contractId,
        dueDate: dueDate,
        notes: notes,
        expectedAmount: expectedAmount,
      );

      await fetchInitialData();
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorAddSeasonal:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }

  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String scheduleId,
    required String actionType,
    required DateTime nextDueDate,
  }) async {
    try {
      await _erpRepository.handleRollingCheckpoint(
        contractId: contractId,
        scheduleId: scheduleId,
        actionType: actionType,
        nextDueDate: nextDueDate,
      );

      await fetchInitialData();
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: 'scheduleErrorGeneral:$e', // 🌟 استخدام المفتاح
        ),
      );
    }
  }
}
