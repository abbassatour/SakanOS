//lib\clients\cubit\clients_state.dart
part of 'clients_cubit.dart';

enum ClientsStatus { initial, loading, success, failure }

class ClientsState extends Equatable {
  const ClientsState({
    this.status = ClientsStatus.initial,
    this.clients = const[],
    this.deletedClients = const[],
    this.userNamesMap = const {}, // 🌟 الإضافة الجديدة: قاموس الأسماء
    this.errorMessage,
  });

  final ClientsStatus status;
  final List<Client> clients;
  final List<Client> deletedClients;
  final Map<String, String> userNamesMap; // 🌟 الإضافة الجديدة
  final String? errorMessage;

  ClientsState copyWith({
    ClientsStatus? status,
    List<Client>? clients,
    List<Client>? deletedClients,
    Map<String, String>? userNamesMap, // 🌟 الإضافة الجديدة
    String? errorMessage,
  }) {
    return ClientsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      deletedClients: deletedClients ?? this.deletedClients,
      userNamesMap: userNamesMap ?? this.userNamesMap, // 🌟 الإضافة الجديدة
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clients, deletedClients, userNamesMap, errorMessage]; // 🌟 تحديث الـ props
}