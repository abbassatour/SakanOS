// lib/schedule/cubit/schedule_state.dart
part of 'schedule_cubit.dart';

enum ScheduleStatus { initial, loading, success, failure }

// نموذج رادار التخصص
class AllocationAlertData {
  final Contract contract;
  final Client client;
  final double accumulatedMeters;
  final double averageMetersPerMonth;
  final int estimatedMonthsLeft;
  final String urgencyLevel;

  // 🌟 الحقول الجديدة الخاصة بالذاكرة
  final DateTime? lastActionDate;
  final String? lastActionNote;

  AllocationAlertData({
    required this.contract,
    required this.client,
    required this.accumulatedMeters,
    required this.averageMetersPerMonth,
    required this.estimatedMonthsLeft,
    required this.urgencyLevel,
    this.lastActionDate,
    this.lastActionNote, // 🌟
  });
}

// نموذج رادار المتعثرين
class OverdueContractAlert {
  final Contract contract;
  final Client client;
  final List<InstallmentsScheduleData> overdueSchedules;
  final int maxDaysOverdue;
  final String severity;

  OverdueContractAlert({
    required this.contract,
    required this.client,
    required this.overdueSchedules,
    required this.maxDaysOverdue,
    required this.severity,
  });
}

class ScheduleState extends Equatable {
  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.clients = const [],
    this.contracts = const [],
    this.scheduleList = const [],
    this.allocationAlerts = const [],
    this.overdueAlerts = const [],
    this.selectedContractId,
    this.activeTabIndex =
        0, // 🌟 تمت الإضافة: التبويب الافتراضي هو 0 (المتعثرين)
    this.errorMessage,
  });

  final ScheduleStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<InstallmentsScheduleData> scheduleList;
  final List<AllocationAlertData> allocationAlerts;
  final List<OverdueContractAlert> overdueAlerts;
  final String? selectedContractId;
  final int activeTabIndex; // 🌟 تمت الإضافة
  final String? errorMessage;

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<InstallmentsScheduleData>? scheduleList,
    List<AllocationAlertData>? allocationAlerts,
    List<OverdueContractAlert>? overdueAlerts,
    String? selectedContractId,
    int? activeTabIndex, // 🌟 تمت الإضافة
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      scheduleList: scheduleList ?? this.scheduleList,
      allocationAlerts: allocationAlerts ?? this.allocationAlerts,
      overdueAlerts: overdueAlerts ?? this.overdueAlerts,
      selectedContractId: selectedContractId ?? this.selectedContractId,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex, // 🌟 تمت الإضافة
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  // 🌟 تمت الإضافة في الـ props لكي يتم تحديث الشاشة عند تغيير الرقم
  List<Object?> get props => [
    status,
    clients,
    contracts,
    scheduleList,
    allocationAlerts,
    overdueAlerts,
    selectedContractId,
    activeTabIndex,
    errorMessage,
  ];
}
