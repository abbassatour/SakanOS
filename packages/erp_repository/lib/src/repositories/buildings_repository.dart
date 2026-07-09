// packages/erp_repository/lib/src/repositories/buildings_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart';

class BuildingsRepository {
  const BuildingsRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  Future<List<Building>> getBuildings() => _localApi.getBuildings();

  Future<List<Apartment>> getAllApartments() => _localApi.getAllApartments();

  // 🌟 الواجهة ترسل نصوصاً وقواميس (Maps) عادية فقط
  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final building = BuildingsCompanion.insert(
      name: name,
      location: drift.Value(location),
      floorCoefficients: drift.Value(jsonEncode(floorCoeffs)),
      directionCoefficients: drift.Value(jsonEncode(dirCoeffs)),
      userId: drift.Value(userId),
    );

    await _localApi.addBuilding(building);
    await _syncRepo.syncPendingData();
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
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final apartment = ApartmentsCompanion.insert(
      buildingId: buildingId,
      unitType: drift.Value(unitType),
      apartmentNumber: aptNumber,
      area: area,
      floorName: floorName,
      directionName: directionName, // 🌟 تم إزالة drift.Value من هنا
      customCoefficients: drift.Value(jsonEncode(customCoeffs)),
      status: const drift.Value('available'),
      userId: drift.Value(userId),
    );

    await _localApi.addApartment(apartment);
    await _syncRepo.syncPendingData();
  }

  Future<void> updateBuilding({
    required String id,
    required String name,
    required String location,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.buildings)..where((t) => t.id.equals(id))).write(
      BuildingsCompanion(
        name: drift.Value(name),
        location: drift.Value(location),
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> updateApartment({
    required String id,
    required String apartmentNumber,
    required double area,
    required String directionName,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.apartments)..where((t) => t.id.equals(id))).write(
      ApartmentsCompanion(
        apartmentNumber: drift.Value(apartmentNumber),
        area: drift.Value(area),
        directionName: drift.Value(directionName),
        userId: drift.Value(userId),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> changeApartmentStatus(String apartmentId, String status) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.changeApartmentStatus(apartmentId, status, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> softDeleteApartment(String apartmentId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    final apt = await (db.select(
      db.apartments,
    )..where((t) => t.id.equals(apartmentId))).getSingle();

    if (apt.status != 'available') {
      throw Exception('⚠️ لا يمكن حذف هذه الوحدة لأن حالتها: ${apt.status}');
    }

    await db.softDeleteApartment(apartmentId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> softDeleteBuilding(String buildingId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    final buildingApartments =
        await (db.select(db.apartments)..where(
              (t) =>
                  t.buildingId.equals(buildingId) & t.isDeleted.equals(false),
            ))
            .get();

    final hasSoldApartments = buildingApartments.any(
      (apt) => apt.status != 'available',
    );

    if (hasSoldApartments) {
      throw Exception(
        '⛔ لا يمكن حذف المحضر لوجود وحدات مباعة. احذف المتاحة يدوياً أولاً.',
      );
    }

    await db.softDeleteBuilding(buildingId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> restoreApartment(String apartmentId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.database.restoreSoftDeletedApartment(apartmentId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> restoreBuilding(String buildingId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.database.restoreSoftDeletedBuilding(buildingId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> forceHardDeleteApartment(String apartmentId) async {
    await _localApi.database.hardDeleteApartment(apartmentId);
  }

  Future<void> forceHardDeleteBuilding(String buildingId) async {
    await _localApi.database.hardDeleteBuilding(buildingId);
  }

  Future<List<Building>> getDeletedBuildings() =>
      _localApi.database.getDeletedBuildings();

  Future<List<Apartment>> getDeletedApartments() =>
      _localApi.database.getDeletedApartments();

  // ==========================================
  // 📎 إدارة المرفقات المتعددة للشقق
  // ==========================================
  Future<List<ApartmentAttachment>> getAllApartmentAttachments() =>
      _localApi.database.getAllApartmentAttachments();

  Future<List<ApartmentAttachment>> getAttachmentsForApartment(
    String apartmentId,
  ) => _localApi.database.getAttachmentsForApartment(apartmentId);

  Future<void> attachFileToApartmentGallery({
    required String apartmentId,
    required File file,
    required String extension,
    required String originalFileName,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final attachmentId = const Uuid().v7();

    // 1. الحفظ المحلي المؤقت
    final dir = await getApplicationSupportDirectory();
    final localDirPath = p.join(dir.path, 'pending_uploads');
    final localDir = Directory(localDirPath);
    if (!await localDir.exists()) await localDir.create(recursive: true);

    final fileName = 'attach_$attachmentId.$extension';
    final localFile = await file.copy(p.join(localDir.path, fileName));

    // 2. الحفظ في الداتابيز
    final newAttachment = ApartmentAttachmentsCompanion.insert(
      id: drift.Value(attachmentId),
      apartmentId: apartmentId,
      fileUrl: localFile.path,
      fileName: drift.Value(originalFileName),
      fileType: drift.Value(extension),
      userId: userId,
      isSynced: const drift.Value(false),
    );

    await _localApi.database.insertApartmentAttachment(newAttachment);
    await _syncRepo.syncPendingData();
  }

  Future<void> deleteApartmentAttachment(String attachmentId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.database.softDeleteApartmentAttachment(
      attachmentId,
      userId,
    );
    await _syncRepo.syncPendingData();
  }
}
