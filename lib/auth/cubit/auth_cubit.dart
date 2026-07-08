import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show LocalUser;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._erpRepository) : super(const AuthState()) {
    _init();
  }

  final ErpRepository _erpRepository;

  void _init() {
    // نستخدم دالة فرعية لبدء التحقق وتجنب الاستدعاء العشوائي المعلق داخل المشيّد (Constructor)
    checkSession();
  }

  Future<void> checkSession() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final userId = _erpRepository.currentUserId;

      // 1. إذا لم يكن هناك يوزر في السحابة، فهو غير مسجل دخول
      if (userId == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      // 2. إذا كان مسجلاً، نجلب بياناته من قاعدة البيانات المحلية (Drift)
      final localUser = await _erpRepository.getLocalUserById(userId);

      if (localUser == null) {
        // إذا كان مسجل دخول لكن بياناته لم تنزل بعد محلياً (أول مرة يفتح التطبيق)
        // نقوم بإجبار مزامنة سريعة لجلب بياناته فوراً
        await _erpRepository.pullDataFromCloud();
        final retryUser = await _erpRepository.getLocalUserById(userId);

        if (retryUser == null) {
          emit(
            state.copyWith(
              status: AuthStatus.error,
              errorMessage:
                  'بيانات المستخدم غير موجودة في النظام. تواصل مع الإدارة.',
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
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 🌟 محرك دمج الصلاحيات (الرياضيات الذكية والمحمية)
  Future<void> _processUserPermissions(LocalUser localUser) async {
    // 1. التحقق من حالة الحساب
    if (localUser.isActive == false) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'هذا الحساب تم إيقافه من قبل الإدارة.',
        ),
      );
      return;
    }

    var roleName = 'بدون دور';
    var isSystemAdmin = false;
    final finalPermissions = <String>{}; // نستخدم Set لمنع التكرار

    // 2. جلب قالب الدور (Role)
    if (localUser.roleId != null && localUser.roleId!.isNotEmpty) {
      final role = await _erpRepository.getRoleById(localUser.roleId!);
      if (role != null) {
        roleName = role.name;
        isSystemAdmin = role.isSystemRole;

        // 🛡️ حماية فك تشفير صلاحيات الدور
        final rolePermsStr = role.permissionsJson.trim();
        if (rolePermsStr.isNotEmpty && rolePermsStr != 'null') {
          try {
            final rolePerms = jsonDecode(rolePermsStr) as List<dynamic>;
            finalPermissions.addAll(rolePerms.cast<String>());
          } catch (e, stackTrace) {
            log(
              '⚠️ خطأ في فك تشفير صلاحيات الدور',
              error: e,
              stackTrace: stackTrace,
            );
          }
        }
      }
    }

    // 3. إضافة الاستثناءات (Extra)
    // 🛡️ حماية فك تشفير الاستثناءات
    final extraPermsStr = localUser.extraPermissionsJson.trim();
    if (extraPermsStr.isNotEmpty && extraPermsStr != 'null') {
      try {
        final extraPerms = jsonDecode(extraPermsStr) as List<dynamic>;
        finalPermissions.addAll(extraPerms.cast<String>());
      } catch (e, stackTrace) {
        log(
          '⚠️ خطأ في فك تشفير الاستثناءات المضافة',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    // 4. طرح الصلاحيات المسحوبة (Revoked)
    // 🛡️ حماية فك تشفير الممنوعات
    final revokedPermsStr = localUser.revokedPermissionsJson.trim();
    if (revokedPermsStr.isNotEmpty && revokedPermsStr != 'null') {
      try {
        final revokedPerms = jsonDecode(revokedPermsStr) as List<dynamic>;
        finalPermissions.removeAll(revokedPerms.cast<String>());
      } catch (e, stackTrace) {
        log(
          '⚠️ خطأ في فك تشفير الاستثناءات المسحوبة',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    // 5. حفظ النتيجة النهائية النظيفة في الحالة (State)
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

  // دالة لتسجيل الخروج يدوياً
  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _erpRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  // 🌟 [جديد] تسجيل وقت الإدخال الصحيح للـ PIN لتفعيل فترة السماح
  void markPinVerified() {
    emit(state.copyWith(lastPinVerificationTime: DateTime.now()));
  }
}
