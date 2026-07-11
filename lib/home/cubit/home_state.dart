// lib/home/cubit/home_state.dart
part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

enum TimeFilter { daily, weekly, monthly, yearly }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.timeFilter = TimeFilter.monthly,
    required this.referenceDate,

    this.totalRevenue = 0.0,
    this.totalRefundedAmount = 0.0, // 🌟 1. تم تعيين القيمة الافتراضية هنا
    this.totalAreaSold = 0.0,
    this.activeContractsCount = 0,

    this.totalPaidMeters = 0.0,
    this.totalOverdueDebts = 0.0,
    this.totalUndeliveredMeters = 0.0,

    this.allocatedSoldMeters = 0.0,
    this.allocatedPaidMeters = 0.0,
    this.allocatedUndeliveredMeters = 0.0,

    this.unallocatedPaidMeters = 0.0,

    this.overduePreHandover = 0.0,
    this.overduePostHandover = 0.0,
    this.totalAvailableArea = 0.0,

    this.inventoryStatus = const {},

    this.latestPayments = const [],
    this.groupedRevenue = const {},

    this.dollarTrend = const {},
    this.costTrend = const {},
    this.contractsByType = const {},
    this.recentActivities = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final TimeFilter timeFilter;
  final DateTime referenceDate;

  final double totalRevenue;
  final double totalRefundedAmount; // 🌟 2. تم تعريف الحقل الفعلي هنا
  final double totalAreaSold;
  final int activeContractsCount;

  final double totalPaidMeters;
  final double totalOverdueDebts;
  final double totalUndeliveredMeters;

  final double allocatedSoldMeters;
  final double allocatedPaidMeters;
  final double allocatedUndeliveredMeters;

  final double unallocatedPaidMeters;

  final double overduePreHandover;
  final double overduePostHandover;
  final double totalAvailableArea;

  final Map<String, int> inventoryStatus;
  final List<PaymentsLedgerData> latestPayments;
  final Map<String, double> groupedRevenue;
  final Map<String, double> dollarTrend;
  final Map<String, double> costTrend;
  final Map<String, int> contractsByType;
  final List<ActivityItem> recentActivities;
  final String? errorMessage;

  double get allocatedDebtMeters => allocatedSoldMeters - allocatedPaidMeters;

  double get remainingMetersInDebt => totalAreaSold - totalPaidMeters;

  HomeState copyWith({
    HomeStatus? status,
    TimeFilter? timeFilter,
    DateTime? referenceDate,
    double? totalRevenue,
    double? totalRefundedAmount, // 🌟 3. تم إضافته لبارامترات copyWith
    double? totalAreaSold,
    int? activeContractsCount,
    double? totalPaidMeters,
    double? totalOverdueDebts,
    double? totalUndeliveredMeters,
    double? allocatedSoldMeters,
    double? allocatedPaidMeters,
    double? allocatedUndeliveredMeters,
    double? unallocatedPaidMeters,
    double? overduePreHandover,
    double? overduePostHandover,
    double? totalAvailableArea, // 🌟 إضافة المتغير الجديد لـ copyWith
    Map<String, int>? inventoryStatus,
    List<PaymentsLedgerData>? latestPayments,
    Map<String, double>? groupedRevenue,
    Map<String, double>? dollarTrend,
    Map<String, double>? costTrend,
    Map<String, int>? contractsByType,
    List<ActivityItem>? recentActivities,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      timeFilter: timeFilter ?? this.timeFilter,
      referenceDate: referenceDate ?? this.referenceDate,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalRefundedAmount:
          totalRefundedAmount ??
          this.totalRefundedAmount, // 🌟 4. تم إسناده هنا
      totalAreaSold: totalAreaSold ?? this.totalAreaSold,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      totalPaidMeters: totalPaidMeters ?? this.totalPaidMeters,
      totalOverdueDebts: totalOverdueDebts ?? this.totalOverdueDebts,
      totalUndeliveredMeters:
          totalUndeliveredMeters ?? this.totalUndeliveredMeters,
      allocatedSoldMeters: allocatedSoldMeters ?? this.allocatedSoldMeters,
      allocatedPaidMeters: allocatedPaidMeters ?? this.allocatedPaidMeters,
      allocatedUndeliveredMeters:
          allocatedUndeliveredMeters ?? this.allocatedUndeliveredMeters,
      unallocatedPaidMeters:
          unallocatedPaidMeters ?? this.unallocatedPaidMeters,
      overduePreHandover: overduePreHandover ?? this.overduePreHandover,
      overduePostHandover: overduePostHandover ?? this.overduePostHandover,
      totalAvailableArea:
          totalAvailableArea ??
          this.totalAvailableArea, // 🌟 التعيين للمتغير الجديد هنا
      inventoryStatus: inventoryStatus ?? this.inventoryStatus,
      latestPayments: latestPayments ?? this.latestPayments,
      groupedRevenue: groupedRevenue ?? this.groupedRevenue,
      dollarTrend: dollarTrend ?? this.dollarTrend,
      costTrend: costTrend ?? this.costTrend,
      contractsByType: contractsByType ?? this.contractsByType,
      recentActivities: recentActivities ?? this.recentActivities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    timeFilter,
    referenceDate,
    totalRevenue,
    totalRefundedAmount, // 🌟 5. تم إضافته لبارامترات المقارنة
    totalAreaSold,
    activeContractsCount,
    totalPaidMeters,
    totalOverdueDebts,
    totalUndeliveredMeters,
    allocatedSoldMeters,
    allocatedPaidMeters,
    allocatedUndeliveredMeters,
    unallocatedPaidMeters,
    overduePreHandover,
    overduePostHandover,
    totalAvailableArea, // 🌟 تمت إضافته لمصفوفة المقارنة (Props)
    inventoryStatus,
    latestPayments,
    groupedRevenue,
    dollarTrend,
    costTrend,
    contractsByType,
    recentActivities,
    errorMessage,
  ];
}
