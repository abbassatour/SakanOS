// lib/settings/cubit/settings_state.dart
part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currentPrices,
    this.priceHistory = const [],
    this.currentDollarPrice,
    this.dollarPriceHistory = const [],
    this.userNamesMap = const {},
    this.subscriptionExpiryDate, // 🌟 الإضافة الجديدة
    this.errorMessage,
  });

  final SettingsStatus status;
  final MaterialPricesHistoryData? currentPrices;
  final List<MaterialPricesHistoryData> priceHistory;
  final DollarPricesHistoryData? currentDollarPrice;
  final List<DollarPricesHistoryData> dollarPriceHistory;
  final Map<String, String> userNamesMap;

  final DateTime? subscriptionExpiryDate; // 🌟 الإضافة الجديدة

  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    MaterialPricesHistoryData? currentPrices,
    List<MaterialPricesHistoryData>? priceHistory,
    DollarPricesHistoryData? currentDollarPrice,
    List<DollarPricesHistoryData>? dollarPriceHistory,
    Map<String, String>? userNamesMap,
    DateTime? subscriptionExpiryDate, // 🌟
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentPrices: currentPrices ?? this.currentPrices,
      priceHistory: priceHistory ?? this.priceHistory,
      currentDollarPrice: currentDollarPrice ?? this.currentDollarPrice,
      dollarPriceHistory: dollarPriceHistory ?? this.dollarPriceHistory,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate, // 🌟
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPrices,
    priceHistory,
    currentDollarPrice,
    dollarPriceHistory,
    userNamesMap,
    subscriptionExpiryDate, // 🌟
    errorMessage,
  ];
}
