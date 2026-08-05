// lib/contracts/cubit/contracts_state.dart

part of 'contracts_cubit.dart';

enum ContractsStatus { initial, loading, success, failure }

class ContractsState extends Equatable {
  const ContractsState({
    this.status = ContractsStatus.initial,
    this.contracts = const [],
    this.deletedContracts = const [],
    this.clients = const [],
    this.userNamesMap = const {},
    this.attachmentsMap = const {}, // 🌟 المتغير الجديد
    this.errorMessage,
  });

  final ContractsStatus status;
  final List<Contract> contracts;
  final List<Contract> deletedContracts;
  final List<Client> clients;
  final Map<String, String> userNamesMap;

  // 🌟 الخريطة الجديدة: المفتاح هو contractId، والقيمة هي قائمة مرفقات هذا العقد
  final Map<String, List<ContractAttachment>> attachmentsMap;

  final String? errorMessage;

  ContractsState copyWith({
    ContractsStatus? status,
    List<Contract>? contracts,
    List<Contract>? deletedContracts,
    List<Client>? clients,
    Map<String, String>? userNamesMap,
    Map<String, List<ContractAttachment>>? attachmentsMap, // 🌟
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      deletedContracts: deletedContracts ?? this.deletedContracts,
      clients: clients ?? this.clients,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      attachmentsMap: attachmentsMap ?? this.attachmentsMap, // 🌟
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    contracts,
    deletedContracts,
    clients,
    userNamesMap,
    attachmentsMap, // 🌟
    errorMessage,
  ];
}
