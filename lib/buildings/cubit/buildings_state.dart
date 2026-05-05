//lib\buildings\cubit\buildings_state.dart
part of 'buildings_cubit.dart';

enum BuildingsStatus { initial, loading, success, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.buildings = const [],
    this.apartments = const[],
    this.userNamesMap = const {}, // 🌟 الإضافة الجديدة: قاموس الأسماء
    this.errorMessage,
  });

  final BuildingsStatus status;
  final List<Building> buildings;
  final List<Apartment> apartments;
  final Map<String, String> userNamesMap; // 🌟 الإضافة الجديدة
  final String? errorMessage;

  BuildingsState copyWith({
    BuildingsStatus? status,
    List<Building>? buildings,
    List<Apartment>? apartments,
    Map<String, String>? userNamesMap, // 🌟 الإضافة الجديدة
    String? errorMessage,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      buildings: buildings ?? this.buildings,
      apartments: apartments ?? this.apartments,
      userNamesMap: userNamesMap ?? this.userNamesMap, // 🌟 الإضافة الجديدة
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  // 🌟 تحديث الـ props
  List<Object?> get props =>[status, buildings, apartments, userNamesMap, errorMessage];
}