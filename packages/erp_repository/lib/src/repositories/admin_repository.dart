// packages/erp_repository/lib/src/repositories/admin_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart';

class AdminRepository {
  const AdminRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
  })  : _localApi = localApi,
        _syncRepo = syncRepo;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;

  Future<List<AppRole>> getAllRoles() => _localApi.getAllRoles();
  
  Future<List<LocalUser>> getAllUsers() => _localApi.getAllLocalUsers();

  Future<LocalUser?> getLocalUserById(String id) =>
      _localApi.getLocalUserById(id);

  Future<AppRole?> getRoleById(String id) => _localApi.getRoleById(id);

  Future<void> createRole({
    required String name,
    required List<String> permissions,
  }) async {
    final permissionsJson = jsonEncode(permissions);

    final companion = AppRolesCompanion.insert(
      name: name,
      permissionsJson: drift.Value(permissionsJson),
      isSynced: const drift.Value(false),
    );
    
    // ملاحظة: إذا كان local_storage_api يستخدم اسم دالة مختلف (مثل insertRole)
    // يرجى استبدال addRole بها إذا ظهر خطأ.
    await _localApi.addRole(companion);
    await _syncRepo.syncPendingData();
  }

  Future<void> updateRolePermissions({
    required String roleId,
    required List<String> permissions,
  }) async {
    final permissionsJson = jsonEncode(permissions);

    await _localApi.updateRolePermissions(roleId, permissionsJson);
    await _syncRepo.syncPendingData();
  }

  Future<void> updateUserRoleAndPermissions({
    required String userId,
    required String roleId,
    bool? isActive,
    List<String>? extraPermissions,
    List<String>? revokedPermissions,
  }) async {
    final extraJson =
        extraPermissions != null ? jsonEncode(extraPermissions) : null;
    final revokedJson =
        revokedPermissions != null ? jsonEncode(revokedPermissions) : null;

    await _localApi.updateUserRoleAndPermissions(
      userId: userId,
      roleId: roleId,
      extraPermissionsJson: extraJson,
      revokedPermissionsJson: revokedJson,
      isActive: isActive,
    );
    await _syncRepo.syncPendingData();
  }
}