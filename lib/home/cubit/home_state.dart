// lib/home/cubit/home_state.dart
part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }
enum TimeFilter { daily, weekly, monthly, yearly }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.timeFilter = TimeFilter.monthly,
    required this.referenceDate, 
    
    // 🌟 الأرقام المالية والعقارية
    this.totalRevenue = 0.0,
    this.totalAreaSold = 0.0,
    this.activeContractsCount = 0,
    
    // 🌟[الإضافات الجديدة العميقة]
    this.totalPaidMeters = 0.0,         // الأمتار التي قبضنا ثمنها
    this.totalOverdueDebts = 0.0,       // الديون المتأخرة المستعجلة
    this.inventoryStatus = const {},    // حالة الشقق (متاحة، مباعة، مسلمة)

    this.latestPayments = const[],
    this.groupedRevenue = const {},
    this.priceTrend = const {},
    this.costTrend = const {}, 
    this.contractsByType = const {},
    this.recentActivities = const[], 
    this.errorMessage,
  });

  final HomeStatus status;
  final TimeFilter timeFilter;
  final DateTime referenceDate; 
  
  final double totalRevenue;
  final double totalAreaSold;
  final int activeContractsCount;
  
  // 🌟 [الإضافات الجديدة]
  final double totalPaidMeters;
  final double totalOverdueDebts;
  final Map<String, int> inventoryStatus;

  final List<PaymentsLedgerData> latestPayments;
  final Map<String, double> groupedRevenue; 
  final Map<String, double> priceTrend; 
  final Map<String, double> costTrend; 
  final Map<String, int> contractsByType; 
  final List<ActivityItem> recentActivities; 
  final String? errorMessage;
  
  double get averageSellPrice => totalAreaSold == 0 ? 0.0 : totalRevenue / totalAreaSold;
  // 🌟 معادلة سريعة لمعرفة الأمتار المطلوبة من الشركة والتي لم تقبض ثمنها
  double get remainingMetersInDebt => totalAreaSold - totalPaidMeters;

  HomeState copyWith({
    HomeStatus? status,
    TimeFilter? timeFilter,
    DateTime? referenceDate,
    double? totalRevenue,
    double? totalAreaSold,
    int? activeContractsCount,
    double? totalPaidMeters, // 🌟
    double? totalOverdueDebts, // 🌟
    Map<String, int>? inventoryStatus, // 🌟
    List<PaymentsLedgerData>? latestPayments,
    Map<String, double>? groupedRevenue,
    Map<String, double>? priceTrend,
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
      totalAreaSold: totalAreaSold ?? this.totalAreaSold,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      totalPaidMeters: totalPaidMeters ?? this.totalPaidMeters, // 🌟
      totalOverdueDebts: totalOverdueDebts ?? this.totalOverdueDebts, // 🌟
      inventoryStatus: inventoryStatus ?? this.inventoryStatus, // 🌟
      latestPayments: latestPayments ?? this.latestPayments,
      groupedRevenue: groupedRevenue ?? this.groupedRevenue,
      priceTrend: priceTrend ?? this.priceTrend,
      costTrend: costTrend ?? this.costTrend, 
      contractsByType: contractsByType ?? this.contractsByType,
      recentActivities: recentActivities ?? this.recentActivities, 
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status, timeFilter, referenceDate, totalRevenue, totalAreaSold, 
        activeContractsCount, totalPaidMeters, totalOverdueDebts, inventoryStatus, // 🌟
        latestPayments, groupedRevenue, priceTrend, costTrend, 
        contractsByType, recentActivities, averageSellPrice, remainingMetersInDebt // 🌟
      ];
}