// lib/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerData, Contract, MaterialPricesHistoryData; 

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(HomeState(referenceDate: DateTime.now()));

  final ErpRepository _erpRepository;

  List<Contract> _cachedContracts =[];
  List<PaymentsLedgerData> _cachedPayments =[];
  List<MaterialPricesHistoryData> _cachedPrices =[]; 
  List<ActivityItem> _cachedActivities =[]; // 🌟 ذاكرة الأنشطة الحديثة

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading)); 
    try {
      _cachedContracts = await _erpRepository.getAllContracts();
      _cachedPayments = await _erpRepository.getAllPayments(); 
      _cachedPrices = await _erpRepository.getAllMaterialPricesHistory(); 
      
      // 🌟 السحر هنا: جلب أحدث 20 حركة في النظام بالكامل لغرفة العمليات
      _cachedActivities = await _erpRepository.getRecentActivities(limitPerType: 10, finalLimit: 20); 

      _processAndEmitData();
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  void changeTimeFilter(TimeFilter newFilter) {
    emit(state.copyWith(timeFilter: newFilter, referenceDate: DateTime.now()));
    _processAndEmitData(); 
  }

  void navigatePrevious() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.subtract(const Duration(days: 7)); break;
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month - 1, 1); break;
      case TimeFilter.monthly: newDate = DateTime(newDate.year - 1, newDate.month, 1); break;
      case TimeFilter.yearly: newDate = DateTime(newDate.year - 5, newDate.month, 1); break;
    }
    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData(); 
  }

  void navigateNext() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.add(const Duration(days: 7)); break;
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month + 1, 1); break;
      case TimeFilter.monthly: newDate = DateTime(newDate.year + 1, newDate.month, 1); break;
      case TimeFilter.yearly: newDate = DateTime(newDate.year + 5, newDate.month, 1); break;
    }
    if (newDate.isAfter(DateTime.now())) newDate = DateTime.now();
    
    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData(); 
  }

  void _processAndEmitData() {
    double totalRevenue = 0.0;
    double totalAreaSold = 0.0;
    
    Map<String, double> tempGroupedRev = {};
    Map<String, List<double>> tempPriceTrend = {}; 
    Map<String, List<double>> tempCostTrend = {}; 

    final refDate = state.referenceDate;
    
    if (state.timeFilter == TimeFilter.daily) {
      for (int i = 6; i >= 0; i--) {
        String key = DateFormat('MM-dd').format(refDate.subtract(Duration(days: i)));
        tempGroupedRev[key] = 0.0; tempPriceTrend[key] =[]; tempCostTrend[key] =[];
      }
    } else if (state.timeFilter == TimeFilter.weekly) {
      for (int i = 1; i <= 4; i++) {
        tempGroupedRev['الأسبوع $i'] = 0.0; tempPriceTrend['الأسبوع $i'] =[]; tempCostTrend['الأسبوع $i'] =[];
      }
    } else if (state.timeFilter == TimeFilter.monthly) {
      for (int i = 1; i <= 12; i++) {
        String key = '${refDate.year}-${i.toString().padLeft(2, '0')}';
        tempGroupedRev[key] = 0.0; tempPriceTrend[key] =[]; tempCostTrend[key] =[];
      }
    } else if (state.timeFilter == TimeFilter.yearly) {
      for (int i = 4; i >= 0; i--) {
        String key = '${refDate.year - i}';
        tempGroupedRev[key] = 0.0; tempPriceTrend[key] =[]; tempCostTrend[key] =[];
      }
    }

    for (var p in _cachedPayments) {
      totalRevenue += p.amountPaid; 
      
      if (state.timeFilter == TimeFilter.daily) {
        String key = DateFormat('MM-dd').format(p.paymentDate);
        if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
      } else if (state.timeFilter == TimeFilter.weekly && p.paymentDate.year == refDate.year && p.paymentDate.month == refDate.month) {
        int weekNum = ((p.paymentDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempGroupedRev['الأسبوع $weekNum'] = tempGroupedRev['الأسبوع $weekNum']! + p.amountPaid;
      } else if (state.timeFilter == TimeFilter.monthly && p.paymentDate.year == refDate.year) {
        String key = '${p.paymentDate.year}-${p.paymentDate.month.toString().padLeft(2, '0')}';
        if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
      } else if (state.timeFilter == TimeFilter.yearly) {
        String key = '${p.paymentDate.year}';
        if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
      }
    }

    Map<String, int> byType = {};
    for (var c in _cachedContracts) {
      totalAreaSold += c.totalArea;
      byType[c.contractType] = (byType[c.contractType] ?? 0) + 1;
      
      if (state.timeFilter == TimeFilter.daily) {
        String key = DateFormat('MM-dd').format(c.contractDate);
        if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
      } else if (state.timeFilter == TimeFilter.weekly && c.contractDate.year == refDate.year && c.contractDate.month == refDate.month) {
        int weekNum = ((c.contractDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempPriceTrend['الأسبوع $weekNum']!.add(c.baseMeterPriceAtSigning);
      } else if (state.timeFilter == TimeFilter.monthly && c.contractDate.year == refDate.year) {
        String key = '${c.contractDate.year}-${c.contractDate.month.toString().padLeft(2, '0')}';
        if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
      } else if (state.timeFilter == TimeFilter.yearly) {
        String key = '${c.contractDate.year}';
        if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
      }
    }

    // 🌟 4. حساب "التكلفة الخام" للمواد من الذاكرة المخبأة
    for (var price in _cachedPrices) {
      double baseCost = (price.ironPrice * 30.0) + (price.cementPrice * 4.0) + (price.block15Price * 50.0) + 
                        (price.formworkAndPouringWages * 1.0) + (price.aggregateMaterialsPrice * 2.0) + (price.ordinaryWorkerWage * 1.0);
                        
      if (state.timeFilter == TimeFilter.daily) {
        String key = DateFormat('MM-dd').format(price.effectiveDate);
        if (tempCostTrend.containsKey(key)) tempCostTrend[key]!.add(baseCost);
      } else if (state.timeFilter == TimeFilter.weekly && price.effectiveDate.year == refDate.year && price.effectiveDate.month == refDate.month) {
        int weekNum = ((price.effectiveDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempCostTrend['الأسبوع $weekNum']!.add(baseCost);
      } else if (state.timeFilter == TimeFilter.monthly && price.effectiveDate.year == refDate.year) {
        String key = '${price.effectiveDate.year}-${price.effectiveDate.month.toString().padLeft(2, '0')}';
        if (tempCostTrend.containsKey(key)) tempCostTrend[key]!.add(baseCost);
      } else if (state.timeFilter == TimeFilter.yearly) {
        String key = '${price.effectiveDate.year}';
        if (tempCostTrend.containsKey(key)) tempCostTrend[key]!.add(baseCost);
      }
    }
    
    Map<String, double> finalPriceTrend = {};
    tempPriceTrend.forEach((key, prices) {
      finalPriceTrend[key] = prices.isEmpty ? 0.0 : prices.fold(0.0, (a, b) => a + b) / prices.length;
    });

    Map<String, double> finalCostTrend = {};
    tempCostTrend.forEach((key, costs) {
      finalCostTrend[key] = costs.isEmpty ? 0.0 : costs.fold(0.0, (a, b) => a + b) / costs.length;
    });

    void applyForwardFill(Map<String, double> trendData) {
      double lastKnownValue = 0.0;
      
      for (var value in trendData.values) {
        if (value > 0) {
          lastKnownValue = value;
          break;
        }
      }

      for (var key in trendData.keys) {
        if (trendData[key] == 0.0) {
          trendData[key] = lastKnownValue; 
        } else {
          lastKnownValue = trendData[key]!; 
        }
      }
    }

    applyForwardFill(finalPriceTrend);
    applyForwardFill(finalCostTrend);

    var sortedPayments = List<PaymentsLedgerData>.from(_cachedPayments);
    sortedPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    final latestFive = sortedPayments.take(5).toList();

    emit(state.copyWith(
      status: HomeStatus.success,
      totalRevenue: totalRevenue,
      totalAreaSold: totalAreaSold,
      activeContractsCount: _cachedContracts.length,
      latestPayments: latestFive,
      groupedRevenue: tempGroupedRev, 
      priceTrend: finalPriceTrend,
      costTrend: finalCostTrend, 
      contractsByType: byType,
      recentActivities: _cachedActivities, // 🌟 تمرير الأنشطة للواجهة
    ));
  }
}