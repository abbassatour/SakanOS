// lib/legal/cubit/legal_affairs_state.dart
part of 'legal_affairs_cubit.dart';

enum LegalAffairsStatus { initial, loading, success, failure }

class LegalAffairsState extends Equatable {
  const LegalAffairsState({
    this.status = LegalAffairsStatus.initial,
    this.pendingLegalTransfer = const [],
    this.financialArchive = const [],
    this.ultimateArchive = const[],
    this.clients = const [],
    this.apartments = const [],
    this.buildings = const[],
    this.errorMessage,
  });

  final LegalAffairsStatus status;
  
  // 🌟 القوائم الثلاثة المفصلة
  final List<Contract> pendingLegalTransfer;
  final List<Contract> financialArchive;
  final List<Contract> ultimateArchive;
  
  // 🌟 الجداول المساعدة لجلب الأسماء
  final List<Client> clients;
  final List<Apartment> apartments;
  final List<Building> buildings;
  
  final String? errorMessage;

  LegalAffairsState copyWith({
    LegalAffairsStatus? status,
    List<Contract>? pendingLegalTransfer,
    List<Contract>? financialArchive,
    List<Contract>? ultimateArchive,
    List<Client>? clients,
    List<Apartment>? apartments,
    List<Building>? buildings,
    String? errorMessage,
  }) {
    return LegalAffairsState(
      status: status ?? this.status,
      pendingLegalTransfer: pendingLegalTransfer ?? this.pendingLegalTransfer,
      financialArchive: financialArchive ?? this.financialArchive,
      ultimateArchive: ultimateArchive ?? this.ultimateArchive,
      clients: clients ?? this.clients,
      apartments: apartments ?? this.apartments,
      buildings: buildings ?? this.buildings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status,
        pendingLegalTransfer,
        financialArchive,
        ultimateArchive,
        clients,
        apartments,
        buildings,
        errorMessage,
      ];
}