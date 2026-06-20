// packages/erp_repository/lib/src/repositories/auth_repository.dart

import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:local_storage_api/local_storage_api.dart';

class AuthRepository {
  const AuthRepository({
    required CloudStorageClient cloudApi,
    required LocalStorageApi localApi,
  })  : _cloudApi = cloudApi,
        _localApi = localApi;

  final CloudStorageClient _cloudApi;
  final LocalStorageApi _localApi;

  String? get currentUserId => _cloudApi.currentUserId;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _cloudApi.signIn(email: email, password: password);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _cloudApi.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _cloudApi.signOut();
    // حماية قصوى: مسح قاعدة البيانات المحلية
    await _localApi.formatDatabase();
  }
}