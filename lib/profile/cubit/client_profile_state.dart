// lib/profile/cubit/client_profile_state.dart
part of 'client_profile_cubit.dart';

// ==========================================
// 🌟 نموذج بيانات مخصص يربط العقد بإحصائياته المالية والقانونية
// ==========================================
class ContractProfileSummary {
  final Contract contract;
  final double totalPaid;             // ما دفعه فعلياً
  final double baseOverdueAmount;     // الديون المتأخرة الأساسية
  final double penaltyAmount;         // قيمة الغرامة المتراكمة (إن وجدت)
  final double totalOverdueWithPenalty; // إجمالي المطلوب منه حالياً
  final int paidSchedulesCount;       // عدد التسديدات (للمرجعية)
  
  // 🌟 [الإضافة الجديدة]: قائمة الإجراءات القانونية المتخذة بحق هذا العقد
  final List<LegalAction> legalActions; 

  ContractProfileSummary({
    required this.contract,
    required this.totalPaid,
    required this.baseOverdueAmount,
    required this.penaltyAmount,
    required this.totalOverdueWithPenalty,
    required this.paidSchedulesCount,
    required this.legalActions, // 🌟
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
  final double totalOverdueAcrossAll; 
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