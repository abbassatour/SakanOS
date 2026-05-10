// lib/profile/cubit/client_profile_state.dart
part of 'client_profile_cubit.dart';

// ==========================================
// 🌟 نموذج بيانات مخصص يربط العقد بإحصائياته المالية (مُحدّث للمرونة)
// ==========================================
class ContractProfileSummary {
  final Contract contract;
  final double totalPaid;
  final double overdueDebt; // 🌟 أصبحت ديوناً مالية بدلاً من عدد أقساط
  final double penaltyApplied; // 🌟 قيمة الغرامة التي تم تطبيقها على هذا العقد
  final int paymentTransactionsCount; // 🌟 عدد حركات الدفع الفعلية

  ContractProfileSummary({
    required this.contract,
    required this.totalPaid,
    required this.overdueDebt,
    required this.penaltyApplied,
    required this.paymentTransactionsCount,
  });
}

// ==========================================
// 🌟 الحالة (State)
// ==========================================
enum ClientProfileStatus { initial, loading, success, failure }

class ClientProfileState extends Equatable {
  final ClientProfileStatus status;
  final Client? client;
  final List<ContractProfileSummary> contractsSummary;
  final double grandTotalPaid;
  final double totalOverdueAcrossAll; // 🌟 أصبحت ديوناً مالية إجمالية
  final String? errorMessage;

  const ClientProfileState({
    this.status = ClientProfileStatus.initial,
    this.client,
    this.contractsSummary = const[],
    this.grandTotalPaid = 0.0,
    this.totalOverdueAcrossAll = 0.0,
    this.errorMessage,
  });

  ClientProfileState copyWith({
    ClientProfileStatus? status,
    Client? client,
    List<ContractProfileSummary>? contractsSummary,
    double? grandTotalPaid,
    double? totalOverdueAcrossAll,
    String? errorMessage,
  }) {
    return ClientProfileState(
      status: status ?? this.status,
      client: client ?? this.client,
      contractsSummary: contractsSummary ?? this.contractsSummary,
      grandTotalPaid: grandTotalPaid ?? this.grandTotalPaid,
      totalOverdueAcrossAll: totalOverdueAcrossAll ?? this.totalOverdueAcrossAll,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, client, contractsSummary, grandTotalPaid, totalOverdueAcrossAll, errorMessage];
}