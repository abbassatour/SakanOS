//lib\settings\cubit\settings_state.dart
part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,

    // 🧱 أسعار المواد
    this.currentPrices,
    this.priceHistory = const [],

    // 💵 أسعار الدولار (🌟 جديد)
    this.currentDollarPrice,
    this.dollarPriceHistory = const [],

    this.userNamesMap = const {},
    this.errorMessage,
  });

  final SettingsStatus status;

  final MaterialPricesHistoryData? currentPrices;
  final List<MaterialPricesHistoryData> priceHistory;

  // 🌟 المتغيرات الجديدة الخاصة بالدولار
  final DollarPricesHistoryData? currentDollarPrice;
  final List<DollarPricesHistoryData> dollarPriceHistory;

  final Map<String, String> userNamesMap;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    MaterialPricesHistoryData? currentPrices,
    List<MaterialPricesHistoryData>? priceHistory,
    DollarPricesHistoryData? currentDollarPrice, // 🌟
    List<DollarPricesHistoryData>? dollarPriceHistory, // 🌟
    Map<String, String>? userNamesMap,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentPrices: currentPrices ?? this.currentPrices,
      priceHistory: priceHistory ?? this.priceHistory,
      currentDollarPrice: currentDollarPrice ?? this.currentDollarPrice, // 🌟
      dollarPriceHistory: dollarPriceHistory ?? this.dollarPriceHistory, // 🌟
      userNamesMap: userNamesMap ?? this.userNamesMap,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPrices,
    priceHistory,
    currentDollarPrice, // 🌟
    dollarPriceHistory, // 🌟
    userNamesMap,
    errorMessage,
  ];
}
