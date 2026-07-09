// lib/buildings/cubit/buildings_state.dart
part of 'buildings_cubit.dart';

enum BuildingsStatus { initial, loading, success, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.buildings = const [],
    this.apartments = const [],
    this.userNamesMap = const {},
    this.apartmentAttachmentsMap = const {}, // 🌟 المتغير الجديد
    this.errorMessage,
  });

  final BuildingsStatus status;
  final List<Building> buildings;
  final List<Apartment> apartments;
  final Map<String, String> userNamesMap;

  // 🌟 الخريطة الجديدة: المفتاح هو apartmentId، والقيمة هي قائمة المرفقات
  final Map<String, List<ApartmentAttachment>> apartmentAttachmentsMap;

  final String? errorMessage;

  BuildingsState copyWith({
    BuildingsStatus? status,
    List<Building>? buildings,
    List<Apartment>? apartments,
    Map<String, String>? userNamesMap,
    Map<String, List<ApartmentAttachment>>? apartmentAttachmentsMap, // 🌟
    String? errorMessage,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      buildings: buildings ?? this.buildings,
      apartments: apartments ?? this.apartments,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      apartmentAttachmentsMap:
          apartmentAttachmentsMap ?? this.apartmentAttachmentsMap, // 🌟
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    buildings,
    apartments,
    userNamesMap,
    apartmentAttachmentsMap, // 🌟
    errorMessage,
  ];
}
