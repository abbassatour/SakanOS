// lib/buildings/cubit/buildings_cubit.dart
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building, BuildingAttachment, ApartmentAttachment;

part 'buildings_state.dart';

class BuildingsCubit extends Cubit<BuildingsState> {
  BuildingsCubit(this._erpRepository) : super(const BuildingsState());

  final ErpRepository _erpRepository;

  Future<void> loadData() async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final buildings = await _erpRepository.getBuildings();
      final apartments = await _erpRepository.getAllApartments();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      final allBldAttachments = await _erpRepository
          .getAllBuildingAttachments();
      final attachmentsMap = <String, List<BuildingAttachment>>{};
      for (final att in allBldAttachments) {
        attachmentsMap.putIfAbsent(att.buildingId, () => []).add(att);
      }

      final allAptAttachments = await _erpRepository
          .getAllApartmentAttachments();
      final aptAttachmentsMap = <String, List<ApartmentAttachment>>{};
      for (final att in allAptAttachments) {
        aptAttachmentsMap.putIfAbsent(att.apartmentId, () => []).add(att);
      }

      emit(
        state.copyWith(
          status: BuildingsStatus.success,
          buildings: buildings,
          apartments: apartments,
          userNamesMap: namesMap,
          attachmentsMap: attachmentsMap,
          apartmentAttachmentsMap: aptAttachmentsMap,
        ),
      );
    } catch (e, stackTrace) {
      log('خطأ في تحميل بيانات المحاضر', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      log('خطأ في إضافة محضر جديد', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      log('خطأ في إضافة شقة جديدة', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      log('خطأ في تحديث المحضر', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
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
    } catch (e, stackTrace) {
      log('خطأ في تحديث الشقة', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteBuilding(String buildingId) async {
    try {
      await _erpRepository.softDeleteBuilding(buildingId);
      await loadData();
    } catch (e, stackTrace) {
      log('خطأ في حذف المحضر', error: e, stackTrace: stackTrace);
      final rawMsg = e.toString();
      String errorKey = rawMsg.replaceAll('Exception:', '').trim();
      if (rawMsg.contains('لوجود وحدات مباعة')) {
        errorKey = 'bldErrorDeleteHasSoldUnits';
      }
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: errorKey,
        ),
      );
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    try {
      await _erpRepository.softDeleteApartment(apartmentId);
      await loadData();
    } catch (e, stackTrace) {
      log('خطأ في حذف الشقة', error: e, stackTrace: stackTrace);
      final rawMsg = e.toString();
      String errorKey = rawMsg.replaceAll('Exception:', '').trim();
      if (rawMsg.contains('حالتها')) {
        errorKey = 'bldErrorDeleteUnitNotAvailable';
      }
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: errorKey,
        ),
      );
    }
  }

  Future<void> attachFileToApartmentGallery({
    required String apartmentId,
    required String filePath,
    required String extension,
    required String originalFileName,
  }) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final file = File(filePath);

      await _erpRepository.attachFileToApartmentGallery(
        apartmentId: apartmentId,
        file: file,
        extension: extension,
        originalFileName: originalFileName,
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

  Future<void> deleteApartmentAttachment(String attachmentId) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      await _erpRepository.deleteApartmentAttachment(attachmentId);
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

  Future<void> attachFileToBuildingGallery({
    required String buildingId,
    required String filePath,
    required String extension,
    required String originalFileName,
  }) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final file = File(filePath);

      await _erpRepository.attachFileToBuildingGallery(
        buildingId: buildingId,
        file: file,
        extension: extension,
        originalFileName: originalFileName,
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

  Future<void> deleteBuildingAttachment(String attachmentId) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      await _erpRepository.deleteBuildingAttachment(attachmentId);
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

  Future<String?> getSecureAttachmentUrl(String storedPath) async {
    try {
      return await _erpRepository.resolveFileUrl(
        'building_attachments',
        storedPath,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BuildingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return null;
    }
  }
}
