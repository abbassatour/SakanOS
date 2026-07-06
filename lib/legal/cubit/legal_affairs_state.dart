// lib/legal/cubit/legal_affairs_state.dart
part of 'legal_affairs_cubit.dart';

enum LegalAffairsStatus { initial, loading, success, failure }

class LegalAffairsState extends Equatable {
  const LegalAffairsState({
    this.status = LegalAffairsStatus.initial,
    this.actions = const [],
    this.attachmentsMap = const {},
    this.contracts = const [],
    this.clients = const [],
    this.userNamesMap = const {},
    this.errorMessage,
  });

  final LegalAffairsStatus status;

  // 🌟 القوائم الرئيسية
  final List<LegalAction> actions;
  final Map<String, List<LegalActionAttachment>>
  attachmentsMap; // مفتاح الخريطة هو actionId

  // 🌟 قوائم مساعدة للربط وعرض الأسماء بدلاً من الـ IDs
  final List<Contract> contracts;
  final List<Client> clients;
  final Map<String, String> userNamesMap;

  final String? errorMessage;

  LegalAffairsState copyWith({
    LegalAffairsStatus? status,
    List<LegalAction>? actions,
    Map<String, List<LegalActionAttachment>>? attachmentsMap,
    List<Contract>? contracts,
    List<Client>? clients,
    Map<String, String>? userNamesMap,
    String? errorMessage,
  }) {
    return LegalAffairsState(
      status: status ?? this.status,
      actions: actions ?? this.actions,
      attachmentsMap: attachmentsMap ?? this.attachmentsMap,
      contracts: contracts ?? this.contracts,
      clients: clients ?? this.clients,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actions,
    attachmentsMap,
    contracts,
    clients,
    userNamesMap,
    errorMessage,
  ];
}
