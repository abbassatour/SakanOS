// lib/profile/cubit/client_profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Client, Contract, LegalAction, SecureTime;

part 'client_profile_state.dart';

class ClientProfileCubit extends Cubit<ClientProfileState> {
  ClientProfileCubit(this._erpRepository) : super(const ClientProfileState());

  final ErpRepository _erpRepository;

  double _roundTo10(double val) => (val / 10).round() * 10.0;

  int _monthsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    int months = to.month - from.month;
    int totalMonths = years * 12 + months;
    if (to.day < from.day) totalMonths--;
    return totalMonths > 0 ? totalMonths : 0;
  }

  Future<void> fetchClientData(Client client) async {
    emit(state.copyWith(status: ClientProfileStatus.loading, client: client));

    try {
      final clientContracts = await _erpRepository.getContractsForClient(
        client.id,
      );
      final allPayments = await _erpRepository.getAllPayments();
      final allLegalActions = await _erpRepository.getAllLegalActions();

      List<ContractProfileSummary> summaries = [];
      double grandTotalPaid = 0.0;
      double globalOverdue = 0.0;

      final now = SecureTime.now();

      for (final contract in clientContracts) {
        final contractPayments = allPayments
            .where((p) => p.contractId == contract.id && !p.isDeleted)
            .toList();
        final totalPaidRaw = contractPayments.fold(
          0.0,
          (sum, entry) => sum + entry.amountPaid,
        );
        final totalPaidForContract = _roundTo10(totalPaidRaw);

        grandTotalPaid += totalPaidForContract;

        final schedules = await _erpRepository.getContractSchedule(contract.id);
        final paidCount = schedules.where((s) => s.status == 'paid').length;

        double baseOverdueAmount = 0.0;
        double penaltyAmount = 0.0;

        if (!contract.isCompleted) {
          int monthsPassed = _monthsBetween(contract.contractDate, now);
          if (monthsPassed > contract.installmentsCount) {
            monthsPassed = contract.installmentsCount;
          }

          double expectedPayment = contract.downPayment;
          if (contract.agreedMonthlyAmount > 0) {
            expectedPayment += (monthsPassed * contract.agreedMonthlyAmount);
          }

          for (final s in schedules) {
            if (s.expectedAmount != null && s.dueDate.isBefore(now)) {
              expectedPayment += s.expectedAmount!;
            }
          }

          double overdue = expectedPayment - totalPaidForContract;

          if (overdue > 0) {
            baseOverdueAmount = _roundTo10(overdue);

            if (contract.isHandedOver &&
                contract.isPenaltyActive &&
                contract.actualHandoverDate != null) {
              int handoverMonthsPassed = _monthsBetween(
                contract.actualHandoverDate!,
                now,
              );
              int interval = contract.penaltyIntervalMonths ?? 1;

              if (handoverMonthsPassed > 0 && interval > 0) {
                int penaltyApplications = (handoverMonthsPassed / interval)
                    .floor();
                if (penaltyApplications > 0) {
                  double rawPenalty =
                      baseOverdueAmount *
                      ((contract.penaltyPercentage ?? 0) / 100) *
                      penaltyApplications;
                  penaltyAmount = _roundTo10(rawPenalty);
                }
              }
            }
          }
        }

        final totalOverdueWithPenalty = _roundTo10(
          baseOverdueAmount + penaltyAmount,
        );
        globalOverdue += totalOverdueWithPenalty;

        final contractLegalActions = allLegalActions
            .where((a) => a.contractId == contract.id)
            .toList();
        contractLegalActions.sort(
          (a, b) => b.actionDate.compareTo(a.actionDate),
        );

        summaries.add(
          ContractProfileSummary(
            contract: contract,
            totalPaid: totalPaidForContract,
            baseOverdueAmount: baseOverdueAmount,
            penaltyAmount: penaltyAmount,
            totalOverdueWithPenalty: totalOverdueWithPenalty,
            paidSchedulesCount: paidCount,
            legalActions: contractLegalActions,
          ),
        );
      }

      summaries.sort(
        (a, b) => b.contract.contractDate.compareTo(a.contract.contractDate),
      );

      emit(
        state.copyWith(
          status: ClientProfileStatus.success,
          contractsSummary: summaries,
          grandTotalPaid: _roundTo10(grandTotalPaid),
          totalOverdueAcrossAll: _roundTo10(globalOverdue),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientProfileStatus.failure,
          errorMessage: 'clientProfileErrorFetch:$e',
        ),
      );
    }
  }
}
