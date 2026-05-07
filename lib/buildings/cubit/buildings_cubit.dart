// lib/buildings/cubit/buildings_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show BuildingsCompanion, ApartmentsCompanion, Building, Apartment;
import 'package:drift/drift.dart' show Value;

part 'buildings_state.dart';

class BuildingsCubit extends Cubit<BuildingsState> {
  BuildingsCubit(this._erpRepository) : super(const BuildingsState());

  final ErpRepository _erpRepository;

  /// جلب كل المحاضر والشقق من القاعدة المحلية
  Future<void> loadData() async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final buildings = await _erpRepository.getBuildings();
      final apartments = await _erpRepository.getAllApartments();
      
      // 🌟 السحر هنا: جلب المستخدمين وصنع قاموس للأسماء
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
        status: BuildingsStatus.success, 
        buildings: buildings, 
        apartments: apartments,
        userNamesMap: namesMap, 
      ));
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة محضر جديد (مبنى)
  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) async {
    try {
      final building = BuildingsCompanion.insert(
        name: name, 
        location: Value(location),
        floorCoefficients: Value(jsonEncode(floorCoeffs)),
        directionCoefficients: Value(jsonEncode(dirCoeffs)),
        userId: const Value(''), 
      );
      await _erpRepository.addBuilding(building);
      await loadData();
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة شقة داخل محضر
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
      final apartment = ApartmentsCompanion.insert(
        buildingId: buildingId,
        unitType: Value(unitType),
        apartmentNumber: aptNumber,
        area: area,
        floorName: floorName,
        directionName: directionName, 
        customCoefficients: Value(jsonEncode(customCoeffs)),
        status: const Value('available'), 
        userId: const Value(''),
      );
      await _erpRepository.addApartment(apartment);
      await loadData(); 
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 تعديل بيانات المحضر (المبنى)
  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) async {
    try {
      await _erpRepository.updateBuilding(id: id, name: name, location: location);
      await loadData(); 
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: 'فشل تعديل المحضر: $e'));
    }
  }

  /// 🌟 تعديل بيانات الشقة
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
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: 'فشل تعديل الشقة: $e'));
    }
  }

  /// 🗑️ حذف محضر (ينقله لسلة المحذوفات)
  Future<void> deleteBuilding(String buildingId) async {
    try {
      await _erpRepository.softDeleteBuilding(buildingId);
      await loadData(); 
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  /// 🗑️ حذف شقة/محل (ينقله لسلة المحذوفات)
  Future<void> deleteApartment(String apartmentId) async {
    try {
      await _erpRepository.softDeleteApartment(apartmentId);
      await loadData(); 
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString().replaceAll('Exception:', '').trim()));
    }
  }
}