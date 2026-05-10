// lib/profile/cubit/client_profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client, Contract;

part 'client_profile_state.dart';

class ClientProfileCubit extends Cubit<ClientProfileState> {
  ClientProfileCubit(this._erpRepository) : super(const ClientProfileState());

  final ErpRepository _erpRepository;

  // 🌟 دالة مساعدة لحساب الأشهر المنقضية بدقة
  int _monthsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    int months = to.month - from.month;
    int totalMonths = years * 12 + months;
    if (to.day < from.day) totalMonths--; // لم يكتمل الشهر تماماً
    return totalMonths > 0 ? totalMonths : 0;
  }

  Future<void> fetchClientData(Client client) async {
    emit(state.copyWith(status: ClientProfileStatus.loading, client: client));
    
    try {
      // 1. جلب كل البيانات المطلوبة دفعة واحدة لتحسين الأداء
      final clientContracts = await _erpRepository.getContractsForClient(client.id);
      final allPayments = await _erpRepository.getAllPayments(); // جلب كل الدفعات مرة واحدة

      List<ContractProfileSummary> summaries =[];
      double grandTotalPaid = 0.0;
      double globalOverdue = 0.0;

      final now = DateTime.now().toUtc();

      // 2. الدخول في حلقة لجلب الإحصائيات الدقيقة لكل عقد
      for (var contract in clientContracts) {
        // أ. فلترة المدفوعات الخاصة بهذا العقد وجمعها
        final contractPayments = allPayments.where((p) => p.contractId == contract.id && !p.isDeleted).toList();
        final totalPaidForContract = contractPayments.fold(0.0, (sum, entry) => sum + entry.amountPaid);
        grandTotalPaid += totalPaidForContract;

        // ب. جلب جدول الأقساط فقط لحساب عدد التسديدات (للعرض)
        final schedules = await _erpRepository.getContractSchedule(contract.id);
        final paidCount = schedules.where((s) => s.status == 'paid').length;

        // ==========================================
        // 🌟 الخوارزمية المرنة لحساب الديون المتأخرة + الغرامات
        // ==========================================
        double baseOverdueAmount = 0.0;
        double penaltyAmount = 0.0;
        
        if (!contract.isCompleted && contract.agreedMonthlyAmount > 0) {
            int monthsPassed = _monthsBetween(contract.contractDate, now);
            if (monthsPassed > contract.installmentsCount) monthsPassed = contract.installmentsCount;

            double expectedPayment = contract.downPayment + (monthsPassed * contract.agreedMonthlyAmount);
            double overdue = expectedPayment - totalPaidForContract;

            if (overdue > 0) {
                baseOverdueAmount = overdue;

                // تطبيق غرامة ما بعد الاستلام
                if (contract.isHandedOver && contract.isPenaltyActive && contract.actualHandoverDate != null) {
                    int handoverMonthsPassed = _monthsBetween(contract.actualHandoverDate!, now);
                    if (handoverMonthsPassed > 0 && (contract.penaltyIntervalMonths ?? 1) > 0) {
                        int penaltyApplications = (handoverMonthsPassed / (contract.penaltyIntervalMonths ?? 1)).floor();
                        if (penaltyApplications > 0) {
                            penaltyAmount = baseOverdueAmount * ((contract.penaltyPercentage ?? 0) / 100) * penaltyApplications;
                        }
                    }
                }
            }
        }
        // ==========================================
        
        final totalOverdueWithPenalty = baseOverdueAmount + penaltyAmount;
        globalOverdue += totalOverdueWithPenalty;

        summaries.add(ContractProfileSummary(
          contract: contract,
          totalPaid: totalPaidForContract,
          baseOverdueAmount: baseOverdueAmount,
          penaltyAmount: penaltyAmount,
          totalOverdueWithPenalty: totalOverdueWithPenalty,
          paidSchedulesCount: paidCount,
        ));
      }

      // 3. ترتيب العقود (الأحدث أولاً بناءً على تاريخ التوقيع)
      summaries.sort((a, b) => b.contract.contractDate.compareTo(a.contract.contractDate));

      emit(state.copyWith(
        status: ClientProfileStatus.success,
        contractsSummary: summaries,
        grandTotalPaid: grandTotalPaid,
        totalOverdueAcrossAll: globalOverdue,
      ));

    } catch (e) {
      emit(state.copyWith(status: ClientProfileStatus.failure, errorMessage: 'فشل تحميل الملف التعريفي: $e'));
    }
  }
}