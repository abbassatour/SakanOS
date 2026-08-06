// lib/auth/cubit/auth_cubit.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show LocalUser, SecureTime;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._erpRepository) : super(const AuthState()) {
    _init();
  }

  final ErpRepository _erpRepository;

  void _init() {
    checkSession();
  }

  Future<void> checkSession() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final userId = _erpRepository.currentUserId;

      if (userId == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final localUser = await _erpRepository.getLocalUserById(userId);

      if (localUser == null) {
        await _erpRepository.pullDataFromCloud();
        final retryUser = await _erpRepository.getLocalUserById(userId);

        if (retryUser == null) {
          emit(
            state.copyWith(
              status: AuthStatus.error,
              errorMessage: 'authErrorUserNotFound',
            ),
          );
          return;
        }
        await _processUserPermissions(retryUser);
      } else {
        await _processUserPermissions(localUser);
      }
    } catch (e, stackTrace) {
      log(
        'خطأ أثناء التحقق من جلسة المستخدم',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  List<String> _safeParsePermissions(String? jsonString) {
    if (jsonString == null ||
        jsonString.trim().isEmpty ||
        jsonString == 'null') {
      return [];
    }

    final trimmed = jsonString.trim();

    try {
      final decoded = jsonDecode(trimmed) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      log(
        '⚠️ تم اكتشاف JSON غير قياسي، جاري تنظيفه واستخلاص الصلاحيات: $trimmed',
      );

      String cleaned = trimmed
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", "");

      if (cleaned.trim().isEmpty) return [];

      return cleaned
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  Future<void> _processUserPermissions(LocalUser localUser) async {
    if (localUser.isActive == false) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'authErrorAccountDisabled',
        ),
      );
      return;
    }

    var roleName = 'بدون دور';
    var isSystemAdmin = false;
    final finalPermissions = <String>{};

    if (localUser.roleId != null && localUser.roleId!.isNotEmpty) {
      final role = await _erpRepository.getRoleById(localUser.roleId!);
      if (role != null) {
        roleName = role.name;
        isSystemAdmin = role.isSystemRole;

        final rolePerms = _safeParsePermissions(role.permissionsJson);
        finalPermissions.addAll(rolePerms);
      }
    }

    final extraPerms = _safeParsePermissions(localUser.extraPermissionsJson);
    finalPermissions.addAll(extraPerms);

    final revokedPerms = _safeParsePermissions(
      localUser.revokedPermissionsJson,
    );
    finalPermissions.removeAll(revokedPerms);

    final expiryDate = await _erpRepository.getLocalSubscriptionExpiry();
    final now = SecureTime.now();

    if (expiryDate == null || now.isAfter(expiryDate)) {
      emit(
        state.copyWith(
          status: AuthStatus.subscriptionExpired,
          errorMessage: 'authErrorSubscriptionExpired',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return;
    }

    final lastHeartbeat = await _erpRepository.getLastHeartbeatTime();

    final bool isTimeTampered =
        lastHeartbeat != null &&
        now.isBefore(lastHeartbeat.subtract(const Duration(minutes: 5)));

    final int daysPassed = lastHeartbeat != null
        ? now.difference(lastHeartbeat).inDays
        : 999;

    if (lastHeartbeat == null || daysPassed >= 7 || isTimeTampered) {
      emit(
        state.copyWith(
          status: AuthStatus.offlineLock,
          errorMessage: isTimeTampered
              ? 'authErrorTimeTampered'
              : 'authErrorOfflineLimitExceeded',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return;
    }

    final referenceTime = now.isAfter(lastHeartbeat) ? now : lastHeartbeat;
    final bool isFreshInstall = lastHeartbeat == null && expiryDate == null;

    if (!isFreshInstall &&
        (expiryDate == null || referenceTime.isAfter(expiryDate))) {
      emit(
        state.copyWith(
          status: AuthStatus.subscriptionExpired,
          errorMessage: 'authErrorSubscriptionExpired',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        userId: localUser.id,
        userName: localUser.fullName ?? localUser.email,
        roleName: roleName,
        isSystemAdmin: isSystemAdmin,
        permissions: finalPermissions.toList(),
      ),
    );
  }

  Future<void> logout() async {
    _gracePeriodTimer?.cancel();
    emit(state.copyWith(status: AuthStatus.loading));
    await _erpRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  static const int gracePeriodMinutes = 5;
  Timer? _gracePeriodTimer;

  void markPinVerified() {
    emit(state.copyWith(lastPinVerificationTime: DateTime.now()));
    _gracePeriodTimer?.cancel();
    _gracePeriodTimer = Timer(const Duration(minutes: gracePeriodMinutes), () {
      lockPinSession();
    });
  }

  void lockPinSession() {
    _gracePeriodTimer?.cancel();
    emit(state.copyWith(clearGracePeriod: true));
  }

  @override
  Future<void> close() {
    _gracePeriodTimer?.cancel();
    return super.close();
  }
}
