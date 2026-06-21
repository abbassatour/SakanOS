// lib/buildings/cubit/buildings_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building;

part 'buildings_state.dart';

class BuildingsCubit extends Cubit<BuildingsState> {
  // 🌟 تم الحفاظ على نوع المعامل الموضعي (Positional) لضمان التوافقية
  BuildingsCubit(this._erpRepository) : super(const BuildingsState());

  final ErpRepository _erpRepository;

  Future<void> loadData() async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final buildings = await _erpRepository.getBuildings();
      final apartments = await _erpRepository.getAllApartments();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers)
          user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          status: BuildingsStatus.success,
          buildings: buildings,
          apartments: apartments,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) async {
    try {
      await _erpRepository.addBuilding(
        name: name,
        location: location,
        floorCoeffs: floorCoeffs,
        dirCoeffs: dirCoeffs,
      );
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addApartment({
    required String buildingId,
    required String aptNumber,
    required double area,
    required String floorName,
    required String directionName,
    String unitType = 'apartment',
    Map<String, double> customCoeffs = const {},
  }) async {
    try {
      await _erpRepository.addApartment(
        buildingId: buildingId,
        aptNumber: aptNumber,
        area: area,
        floorName: floorName,
        directionName: directionName,
        unitType: unitType,
        customCoeffs: customCoeffs,
      );
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) async {
    try {
      await _erpRepository.updateBuilding(
        id: id,
        name: name,
        location: location,
      );
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: 'فشل تعديل المحضر: $e',
        ),
      );
    }
  }

  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) async {
    try {
      await _erpRepository.updateApartment(
        id: id,
        apartmentNumber: apartmentNumber,
        area: area,
        directionName: directionName,
      );
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: 'فشل تعديل الشقة: $e',
        ),
      );
    }
  }

  Future<void> deleteBuilding(String buildingId) async {
    try {
      await _erpRepository.softDeleteBuilding(buildingId);
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString().replaceAll('Exception:', '').trim(),
        ),
      );
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    try {
      await _erpRepository.softDeleteApartment(apartmentId);
      await loadData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString().replaceAll('Exception:', '').trim(),
        ),
      );
    }
  }
}
