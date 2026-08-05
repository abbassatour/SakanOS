// packages/erp_repository/lib/src/repositories/legal_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';
import 'package:uuid/uuid.dart';

import 'sync_repository.dart';

class LegalRepository {
  const LegalRepository({
    required LocalStorageApi localApi,
    required CloudStorageClient cloudApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _cloudApi = cloudApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  Future<List<LegalAction>> getAllLegalActions() =>
      _localApi.getAllLegalActions();

  Future<List<LegalActionAttachment>> getAllLegalActionAttachments() =>
      _localApi.getAllLegalActionAttachments();

  Future<List<LegalAction>> getLegalActionsForContract(String contractId) =>
      _localApi.getLegalActionsForContract(contractId);

  Future<void> addLegalAction({
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final newAction = LegalActionsCompanion.insert(
      id: drift.Value(const Uuid().v7()),
      contractId: contractId,
      actionType: actionType,
      actionDate: actionDate.toUtc(),
      notes: drift.Value(notes),
      userId: userId,
    );

    await _localApi.addLegalAction(newAction);

    // تسجيل الإجراء في العقد مباشرة ليعلم المدير
    await _localApi.markContractActionTaken(
      contractId,
      'تم اتخاذ إجراء قانوني: $actionType',
      userId,
    );

    await _syncRepo.syncPendingData();
  }

  Future<void> updateLegalAction({
    required String actionId,
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final updatedAction = LegalActionsCompanion(
      id: drift.Value(actionId),
      contractId: drift.Value(contractId),
      actionType: drift.Value(actionType),
      actionDate: drift.Value(actionDate.toUtc()),
      notes: drift.Value(notes),
    );

    await _localApi.updateLegalAction(updatedAction);
    await _syncRepo.syncPendingData();
  }

  Future<void> deleteLegalAction(String actionId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteLegalAction(actionId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> attachFileToLegalAction({
    required String actionId,
    required File file,
    required String extension,
    required String originalFileName,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final attachmentId = const Uuid().v7();

    // 1. الحفظ المحلي
    final dir = await getApplicationSupportDirectory();
    final localDirPath = p.join(dir.path, 'pending_uploads');
    final localDir = Directory(localDirPath);
    if (!await localDir.exists()) await localDir.create(recursive: true);

    final fileName = 'attach_$attachmentId.$extension';
    final localFile = await file.copy(p.join(localDir.path, fileName));

    // 2. حفظ المسار المحلي في قاعدة البيانات
    final newAttachment = LegalActionAttachmentsCompanion.insert(
      id: drift.Value(attachmentId),
      legalActionId: actionId,
      fileUrl: localFile.path, // 🌟 المسار المحلي
      fileName: drift.Value(originalFileName),
      fileType: drift.Value(extension),
      userId: userId,
      isSynced: const drift.Value(false),
    );

    await _localApi.database.insertLegalActionAttachment(newAttachment);
    await _syncRepo.syncPendingData();
  }

  Future<void> deleteLegalActionAttachment(String attachmentId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteLegalActionAttachment(attachmentId, userId);
    await _syncRepo.syncPendingData();
  }
}
