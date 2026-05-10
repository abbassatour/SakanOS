// lib/home/cubit/materials_trend/materials_trend_state.dart
part of 'materials_trend_cubit.dart';

enum MaterialsTrendStatus { initial, loading, success, failure }

class MaterialsTrendState extends Equatable {
  const MaterialsTrendState({
    this.status = MaterialsTrendStatus.initial,
    this.timeFilter = TimeFilter.monthly, // 🌟 استوردنا الفلتر من الداشبورد
    required this.referenceDate,
    
    this.ironTrend = const {},
    this.cementTrend = const {},
    this.blockTrend = const {},
    this.formworkTrend = const {},
    this.aggregatesTrend = const {},
    this.workerTrend = const {},
    
    this.errorMessage,
  });

  final MaterialsTrendStatus status;
  final TimeFilter timeFilter;
  final DateTime referenceDate;

  final Map<String, double> ironTrend;
  final Map<String, double> cementTrend;
  final Map<String, double> blockTrend;
  final Map<String, double> formworkTrend;
  final Map<String, double> aggregatesTrend;
  final Map<String, double> workerTrend;
  
  final String? errorMessage;

  MaterialsTrendState copyWith({
    MaterialsTrendStatus? status,
    TimeFilter? timeFilter,
    DateTime? referenceDate,
    Map<String, double>? ironTrend,
    Map<String, double>? cementTrend,
    Map<String, double>? blockTrend,
    Map<String, double>? formworkTrend,
    Map<String, double>? aggregatesTrend,
    Map<String, double>? workerTrend,
    String? errorMessage,
  }) {
    return MaterialsTrendState(
      status: status ?? this.status,
      timeFilter: timeFilter ?? this.timeFilter,
      referenceDate: referenceDate ?? this.referenceDate,
      ironTrend: ironTrend ?? this.ironTrend,
      cementTrend: cementTrend ?? this.cementTrend,
      blockTrend: blockTrend ?? this.blockTrend,
      formworkTrend: formworkTrend ?? this.formworkTrend,
      aggregatesTrend: aggregatesTrend ?? this.aggregatesTrend,
      workerTrend: workerTrend ?? this.workerTrend,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status, timeFilter, referenceDate,
        ironTrend, cementTrend, blockTrend,
        formworkTrend, aggregatesTrend, workerTrend,
        errorMessage,
      ];
}