// packages/erp_repository/lib/src/repositories/clients_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart' hide SecureTime;

class ClientsRepository {
  const ClientsRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  Future<List<Client>> getClients() => _localApi.getClients();

  // 🌟 السحر هنا: الواجهة ترسل نصوصاً عادية فقط
  Future<void> addClient({
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // المستودع هو من يتعامل مع Drift والـ Companion
    final companion = ClientsCompanion.insert(
      name: name,
      phone: phone,
      nationalId: drift.Value(nationalId),
      userId: userId,
    );

    await _localApi.addClient(companion);
    await _syncRepo.syncPendingData();
  }

  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    final db = _localApi.database;
    await (db.update(db.clients)..where((t) => t.id.equals(id))).write(
      ClientsCompanion(
        name: drift.Value(name),
        phone: drift.Value(phone),
        nationalId: drift.Value(nationalId),
        userId: drift.Value(userId),
        updatedAt: drift.Value(SecureTime.now()),
        isSynced: const drift.Value(false),
      ),
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> deleteClient(String clientId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.deleteClient(clientId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<List<Client>> getDeletedClients() => _localApi.getDeletedClients();

  Future<void> restoreClient(String clientId) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.restoreClient(clientId, userId);
    await _syncRepo.syncPendingData();
  }

  Future<void> forceHardDeleteClient(String clientId) async {
    await _localApi.hardDeleteClientLocal(clientId);
  }
}
