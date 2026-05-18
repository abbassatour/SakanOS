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
    this.totalAreaSold = 0.0,
    this.activeContractsCount = 0,
    
    this.totalPaidMeters = 0.0,         
    this.totalOverdueDebts = 0.0,       
    
    this.totalUndeliveredMeters = 0.0,  

    this.inventoryStatus = const {},    

    this.latestPayments = const[],
    this.groupedRevenue = const {},
    
    this.dollarTrend = const {}, // 🌟 المتغير الجديد الخاص بالدولار
    
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
  
  final double totalPaidMeters;
  final double totalOverdueDebts;
  final double totalUndeliveredMeters; 
  final Map<String, int> inventoryStatus;

  final List<PaymentsLedgerData> latestPayments;
  final Map<String, double> groupedRevenue; 
  
  final Map<String, double> dollarTrend; // 🌟 
  
  final Map<String, double> costTrend; 
  final Map<String, int> contractsByType; 
  final List<ActivityItem> recentActivities; 
  final String? errorMessage;
  
  // 🌟 تم حذف averageSellPrice نهائياً
  double get remainingMetersInDebt => totalAreaSold - totalPaidMeters;

  HomeState copyWith({
    HomeStatus? status,
    TimeFilter? timeFilter,
    DateTime? referenceDate,
    double? totalRevenue,
    double? totalAreaSold,
    int? activeContractsCount,
    double? totalPaidMeters, 
    double? totalOverdueDebts, 
    double? totalUndeliveredMeters, 
    Map<String, int>? inventoryStatus, 
    List<PaymentsLedgerData>? latestPayments,
    Map<String, double>? groupedRevenue,
    Map<String, double>? dollarTrend, // 🌟
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
      totalPaidMeters: totalPaidMeters ?? this.totalPaidMeters, 
      totalOverdueDebts: totalOverdueDebts ?? this.totalOverdueDebts, 
      totalUndeliveredMeters: totalUndeliveredMeters ?? this.totalUndeliveredMeters, 
      inventoryStatus: inventoryStatus ?? this.inventoryStatus, 
      latestPayments: latestPayments ?? this.latestPayments,
      groupedRevenue: groupedRevenue ?? this.groupedRevenue,
      dollarTrend: dollarTrend ?? this.dollarTrend, // 🌟
      costTrend: costTrend ?? this.costTrend, 
      contractsByType: contractsByType ?? this.contractsByType,
      recentActivities: recentActivities ?? this.recentActivities, 
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status, timeFilter, referenceDate, totalRevenue, totalAreaSold, 
        activeContractsCount, totalPaidMeters, totalOverdueDebts, totalUndeliveredMeters, 
        inventoryStatus, latestPayments, groupedRevenue, dollarTrend, costTrend, // 🌟 تم استبدال السعر بالدولار هنا
        contractsByType, recentActivities, remainingMetersInDebt // 🌟 تم الحذف من المراقبة
      ];
}