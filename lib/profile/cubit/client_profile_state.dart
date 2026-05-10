// lib/profile/cubit/client_profile_state.dart
part of 'client_profile_cubit.dart';

// ==========================================
// 🌟 نموذج بيانات مخصص يربط العقد بإحصائياته المالية الدقيقة (مرن)
// ==========================================
class ContractProfileSummary {
  final Contract contract;
  final double totalPaid;
  final double totalDebt; // 🌟 الديون المتأخرة (تشمل الغرامة إن وجدت)
  final double penaltyApplied; // 🌟 قيمة الغرامة التي تم إضافتها للدين
  final int paidSchedulesCount; // أبقيناها كمرجع لواجهة المستخدم

  ContractProfileSummary({
    required this.contract,
    required this.totalPaid,
    required this.totalDebt,
    required this.penaltyApplied,
    required this.paidSchedulesCount,
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
  final double totalDebtAcrossAll; // 🌟 إجمالي ديون العميل (ليرة بدلاً من عدد أقساط)
  final String? errorMessage;

  const ClientProfileState({
    this.status = ClientProfileStatus.initial,
    this.client,
    this.contractsSummary = const[],
    this.grandTotalPaid = 0.0,
    this.totalDebtAcrossAll = 0.0, // 🌟
    this.errorMessage,
  });

  ClientProfileState copyWith({
    ClientProfileStatus? status,
    Client? client,
    List<ContractProfileSummary>? contractsSummary,
    double? grandTotalPaid,
    double? totalDebtAcrossAll, // 🌟
    String? errorMessage,
  }) {
    return ClientProfileState(
      status: status ?? this.status,
      client: client ?? this.client,
      contractsSummary: contractsSummary ?? this.contractsSummary,
      grandTotalPaid: grandTotalPaid ?? this.grandTotalPaid,
      totalDebtAcrossAll: totalDebtAcrossAll ?? this.totalDebtAcrossAll,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, client, contractsSummary, grandTotalPaid, totalDebtAcrossAll, errorMessage];
}