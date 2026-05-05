//lib\settings\cubit\settings_state.dart
part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currentPrices,
    this.priceHistory = const[], 
    this.userNamesMap = const {}, // 🌟 الإضافة الجديدة: قاموس الأسماء
    this.errorMessage,
  });

  final SettingsStatus status;
  final MaterialPricesHistoryData? currentPrices;
  final List<MaterialPricesHistoryData> priceHistory; 
  final Map<String, String> userNamesMap; // 🌟 الإضافة الجديدة
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    MaterialPricesHistoryData? currentPrices,
    List<MaterialPricesHistoryData>? priceHistory, 
    Map<String, String>? userNamesMap, // 🌟 الإضافة الجديدة
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentPrices: currentPrices ?? this.currentPrices,
      priceHistory: priceHistory ?? this.priceHistory, 
      userNamesMap: userNamesMap ?? this.userNamesMap, // 🌟 الإضافة الجديدة
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  // 🌟 تحديث الـ props
  List<Object?> get props => [status, currentPrices, priceHistory, userNamesMap, errorMessage]; 
}