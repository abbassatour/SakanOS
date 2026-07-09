// lib/buildings/cubit/buildings_state.dart
part of 'buildings_cubit.dart';

enum BuildingsStatus { initial, loading, success, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.buildings = const [],
    this.apartments = const [],
    this.userNamesMap = const {},
    this.attachmentsMap = const {}, // 🌟 مرفقات المحاضر (Buildings)
    this.apartmentAttachmentsMap = const {}, // 🌟 مرفقات الشقق (Apartments)
    this.errorMessage,
  });

  final BuildingsStatus status;
  final List<Building> buildings;
  final List<Apartment> apartments;
  final Map<String, String> userNamesMap;

  // 🌟 الخريطة للمحاضر: المفتاح هو buildingId
  final Map<String, List<BuildingAttachment>> attachmentsMap;

  // 🌟 الخريطة للشقق: المفتاح هو apartmentId
  final Map<String, List<ApartmentAttachment>> apartmentAttachmentsMap;

  final String? errorMessage;

  BuildingsState copyWith({
    BuildingsStatus? status,
    List<Building>? buildings,
    List<Apartment>? apartments,
    Map<String, String>? userNamesMap,
    Map<String, List<BuildingAttachment>>? attachmentsMap, // 🌟
    Map<String, List<ApartmentAttachment>>? apartmentAttachmentsMap, // 🌟
    String? errorMessage,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      buildings: buildings ?? this.buildings,
      apartments: apartments ?? this.apartments,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      attachmentsMap: attachmentsMap ?? this.attachmentsMap, // 🌟
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
    attachmentsMap, // 🌟
    apartmentAttachmentsMap, // 🌟
    errorMessage,
  ];
}
