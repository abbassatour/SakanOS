// contracts/cubit/contracts_state.dart

part of 'contracts_cubit.dart';

enum ContractsStatus { initial, loading, success, failure }

class ContractsState extends Equatable {
  const ContractsState({
    this.status = ContractsStatus.initial,
    this.contracts = const [],
    this.deletedContracts = const [],
    this.clients = const [],
    this.userNamesMap = const {},
    this.errorMessage,
  });

  final ContractsStatus status;
  final List<Contract> contracts;
  final List<Contract> deletedContracts;
  final List<Client> clients;
  final Map<String, String> userNamesMap;
  final String? errorMessage;

  ContractsState copyWith({
    ContractsStatus? status,
    List<Contract>? contracts,
    List<Contract>? deletedContracts,
    List<Client>? clients,
    Map<String, String>? userNamesMap,
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      deletedContracts: deletedContracts ?? this.deletedContracts,
      clients: clients ?? this.clients,
      userNamesMap: userNamesMap ?? this.userNamesMap,
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
        errorMessage,
      ];
}