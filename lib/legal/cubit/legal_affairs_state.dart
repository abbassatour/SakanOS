// lib/legal/cubit/legal_affairs_state.dart

part of 'legal_affairs_cubit.dart';

enum LegalAffairsStatus { initial, loading, success, failure }

class LegalAffairsState extends Equatable {
  const LegalAffairsState({
    this.status = LegalAffairsStatus.initial,
    this.contract,
    this.client,
    this.legalActions = const [],
    // 💡 الخريطة الذكية: نستخدمها لربط كل إجراء بقائمة مرفقاته بكفاءة عالية
    this.attachments = const {},
    this.errorMessage,
  });

  final LegalAffairsStatus status;
  final Contract? contract;
  final Client? client;
  final List<LegalAction> legalActions;
  final Map<String, List<LegalActionAttachment>> attachments;
  final String? errorMessage;

  LegalAffairsState copyWith({
    LegalAffairsStatus? status,
    Contract? contract,
    Client? client,
    List<LegalAction>? legalActions,
    Map<String, List<LegalActionAttachment>>? attachments,
    String? errorMessage,
  }) {
    return LegalAffairsState(
      status: status ?? this.status,
      contract: contract ?? this.contract,
      client: client ?? this.client,
      legalActions: legalActions ?? this.legalActions,
      attachments: attachments ?? this.attachments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contract,
        client,
        legalActions,
        attachments,
        errorMessage,
      ];
}