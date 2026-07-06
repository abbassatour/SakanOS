// lib/home/cubit/materials_trend/materials_trend_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show MaterialPricesHistoryData;
import '../home_cubit.dart'; // 🌟 لاستدعاء TimeFilter

part 'materials_trend_state.dart';

class MaterialsTrendCubit extends Cubit<MaterialsTrendState> {
  MaterialsTrendCubit(this._erpRepository)
    : super(MaterialsTrendState(referenceDate: DateTime.now()));

  final ErpRepository _erpRepository;
  List<MaterialPricesHistoryData> _cachedPrices = [];

  Future<void> fetchData() async {
    emit(state.copyWith(status: MaterialsTrendStatus.loading));
    try {
      final data = await _erpRepository.getAllMaterialPricesHistory();
      _cachedPrices = data.where((p) => p.isDeleted == false).toList();
      _processAndEmitData();
    } catch (e) {
      emit(
        state.copyWith(
          status: MaterialsTrendStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void changeTimeFilter(TimeFilter newFilter) {
    emit(state.copyWith(timeFilter: newFilter, referenceDate: DateTime.now()));
    _processAndEmitData();
  }

  void navigatePrevious() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        newDate = newDate.subtract(const Duration(days: 7));
        break;
      case TimeFilter.weekly:
        newDate = DateTime(newDate.year, newDate.month - 1, 1);
        break;
      case TimeFilter.monthly:
        newDate = DateTime(newDate.year - 1, newDate.month, 1);
        break;
      case TimeFilter.yearly:
        newDate = DateTime(newDate.year - 5, newDate.month, 1);
        break;
    }
    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData();
  }

  void navigateNext() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        newDate = newDate.add(const Duration(days: 7));
        break;
      case TimeFilter.weekly:
        newDate = DateTime(newDate.year, newDate.month + 1, 1);
        break;
      case TimeFilter.monthly:
        newDate = DateTime(newDate.year + 1, newDate.month, 1);
        break;
      case TimeFilter.yearly:
        newDate = DateTime(newDate.year + 5, newDate.month, 1);
        break;
    }
    if (newDate.isAfter(DateTime.now())) newDate = DateTime.now();

    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData();
  }

  void _processAndEmitData() {
    final refDate = state.referenceDate;

    // 1. تجهيز الخرائط المؤقتة (Buckets)
    Map<String, List<double>> tempIron = {};
    Map<String, List<double>> tempCement = {};
    Map<String, List<double>> tempBlock = {};
    Map<String, List<double>> tempFormwork = {};
    Map<String, List<double>> tempAgg = {};
    Map<String, List<double>> tempWorker = {};

    void initBucket(String key) {
      tempIron[key] = [];
      tempCement[key] = [];
      tempBlock[key] = [];
      tempFormwork[key] = [];
      tempAgg[key] = [];
      tempWorker[key] = [];
    }

    if (state.timeFilter == TimeFilter.daily) {
      for (int i = 6; i >= 0; i--) {
        initBucket(
          DateFormat('MM-dd').format(refDate.subtract(Duration(days: i))),
        );
      }
    } else if (state.timeFilter == TimeFilter.weekly) {
      for (int i = 1; i <= 4; i++) {
        initBucket('الأسبوع $i');
      }
    } else if (state.timeFilter == TimeFilter.monthly) {
      for (int i = 1; i <= 12; i++) {
        initBucket('${refDate.year}-${i.toString().padLeft(2, '0')}');
      }
    } else if (state.timeFilter == TimeFilter.yearly) {
      for (int i = 4; i >= 0; i--) {
        initBucket('${refDate.year - i}');
      }
    }

    // 2. تعبئة الخرائط بالأسعار
    for (var p in _cachedPrices) {
      String? key;
      if (state.timeFilter == TimeFilter.daily) {
        key = DateFormat('MM-dd').format(p.effectiveDate);
      } else if (state.timeFilter == TimeFilter.weekly &&
          p.effectiveDate.year == refDate.year &&
          p.effectiveDate.month == refDate.month) {
        int weekNum = ((p.effectiveDate.day - 1) / 7).floor() + 1;
        key = 'الأسبوع ${weekNum > 4 ? 4 : weekNum}';
      } else if (state.timeFilter == TimeFilter.monthly &&
          p.effectiveDate.year == refDate.year) {
        key =
            '${p.effectiveDate.year}-${p.effectiveDate.month.toString().padLeft(2, '0')}';
      } else if (state.timeFilter == TimeFilter.yearly) {
        key = '${p.effectiveDate.year}';
      }

      if (key != null && tempIron.containsKey(key)) {
        tempIron[key]!.add(p.ironPrice);
        tempCement[key]!.add(p.cementPrice);
        tempBlock[key]!.add(p.block15Price);
        tempFormwork[key]!.add(p.formworkAndPouringWages);
        tempAgg[key]!.add(p.aggregateMaterialsPrice);
        tempWorker[key]!.add(p.ordinaryWorkerWage);
      }
    }

    // 3. حساب المتوسطات وملء الفراغات (Forward Fill)
    Map<String, double> processMap(Map<String, List<double>> tempMap) {
      Map<String, double> finalMap = {};
      tempMap.forEach(
        (k, v) => finalMap[k] = v.isEmpty
            ? 0.0
            : v.fold(0.0, (a, b) => a + b) / v.length,
      );

      double lastKnown = 0.0;
      for (var val in finalMap.values) {
        if (val > 0) {
          lastKnown = val;
          break;
        }
      }
      for (var k in finalMap.keys) {
        if (finalMap[k] == 0.0)
          finalMap[k] = lastKnown;
        else
          lastKnown = finalMap[k]!;
      }
      return finalMap;
    }

    emit(
      state.copyWith(
        status: MaterialsTrendStatus.success,
        ironTrend: processMap(tempIron),
        cementTrend: processMap(tempCement),
        blockTrend: processMap(tempBlock),
        formworkTrend: processMap(tempFormwork),
        aggregatesTrend: processMap(tempAgg),
        workerTrend: processMap(tempWorker),
      ),
    );
  }
}
