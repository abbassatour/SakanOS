import 'dart:convert';
import 'dart:developer';
import 'dart:async';
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
      // lib/auth/cubit/auth_cubit.dart
    } catch (e, stackTrace) {
      log(
        'خطأ أثناء التحقق من جلسة المستخدم',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: AuthStatus.error,
          // 🌟 التعديل هنا: إزالة كلمة Exception من رسالة الخطأ
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  // ==========================================
  // 🛡️ دالة سحرية لتنظيف وفك تشفير الـ JSON المعطوب يدوياً
  // ==========================================
  List<String> _safeParsePermissions(String? jsonString) {
    if (jsonString == null ||
        jsonString.trim().isEmpty ||
        jsonString == 'null') {
      return [];
    }

    final trimmed = jsonString.trim();

    try {
      // 1. المحاولة الأولى: فك تشفير نظامي
      final decoded = jsonDecode(trimmed) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      // 2. المحاولة الثانية: إذا فشل بسبب إدخال يدوي خاطئ مثل [all_access] أو [admin, user]
      log(
        '⚠️ تم اكتشاف JSON غير قياسي، جاري تنظيفه واستخلاص الصلاحيات: $trimmed',
      );

      // إزالة الأقواس المربعة وعلامات التنصيص المفردة والمزدوجة
      String cleaned = trimmed
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", "");

      if (cleaned.trim().isEmpty) return [];

      // تقسيم النص بناءً على الفواصل وتنظيف الفراغات
      return cleaned
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  // ==========================================
  // 🌟 محرك دمج الصلاحيات
  // ==========================================
  Future<void> _processUserPermissions(LocalUser localUser) async {
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
    final finalPermissions = <String>{};

    // 1. جلب صلاحيات الدور (Role) بأمان تام
    if (localUser.roleId != null && localUser.roleId!.isNotEmpty) {
      final role = await _erpRepository.getRoleById(localUser.roleId!);
      if (role != null) {
        roleName = role.name;
        isSystemAdmin = role.isSystemRole;

        final rolePerms = _safeParsePermissions(role.permissionsJson);
        finalPermissions.addAll(rolePerms);
      }
    }

    // 2. إضافة الاستثناءات (Extra) بأمان تام
    final extraPerms = _safeParsePermissions(localUser.extraPermissionsJson);
    finalPermissions.addAll(extraPerms);

    // 3. طرح الصلاحيات المسحوبة (Revoked) بأمان تام
    final revokedPerms = _safeParsePermissions(
      localUser.revokedPermissionsJson,
    );
    finalPermissions.removeAll(revokedPerms);
    // 👇👇 [التحقق من اشتراك الشركة السحابي] 👇👇
    final expiryDate = await _erpRepository.getLocalSubscriptionExpiry();
    final now = DateTime.now().toUtc();

    // 1. إذا لم يجد تاريخ (تلاعب)، أو 2. إذا تجاوز تاريخ اليوم تاريخ الانتهاء (انتهى الاشتراك)
    if (expiryDate == null || now.isAfter(expiryDate)) {
      emit(
        state.copyWith(
          status: AuthStatus.subscriptionExpired,
          errorMessage:
              'انتهت صلاحية اشتراك الشركة في النظام. يرجى التواصل مع المطور لتسوية الدفعات وتجديد رخصة العمل.',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return; // 🛑 منع الدخول تماماً
    }
    // 👆👆 [نهاية فحص الاشتراك] 👆👆

    // 👇👇 [الأسطر الجديدة للتحقق من النبضة (Heartbeat)] 👇👇
    // ========================================================
    // 🛡️ 1. فحص نبض السحابة (Offline Limit) والتلاعب بالوقت أولاً!
    // ========================================================
    final lastHeartbeat = await _erpRepository.getLastHeartbeatTime();

    // نستخدم التوقيت الآمن بدلاً من التوقيت المحلي المزور

    // تقليص فترة السماح إلى 5 دقائق بدلاً من 24 ساعة لسد الثغرة الأولى بالكامل
    final bool isTimeTampered =
        lastHeartbeat != null &&
        now.isBefore(lastHeartbeat.subtract(const Duration(minutes: 5)));

    final int daysPassed = lastHeartbeat != null
        ? now.difference(lastHeartbeat).inDays
        : 999;

    // الطرد الفوري إذا تم إرجاع الزمن للوراء أو تجاوز 7 أيام
    if (lastHeartbeat == null || daysPassed >= 7 || isTimeTampered) {
      emit(
        state.copyWith(
          status: AuthStatus.offlineLock,
          errorMessage: isTimeTampered
              ? 'تم اكتشاف تلاعب في ساعة النظام (محاولة إرجاع الزمن). يرجى المزامنة لفك القفل.'
              : 'تجاوزت الحد المسموح للعمل دون اتصال بالإنترنت (7 أيام). يرجى المزامنة.',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return; // 🛑 خروج فوري ومنع الدخول للتطبيق
    }

    // ========================================================
    // 💳 2. فحص رخصة اشتراك الشركة (بعد التأكد من سلامة الوقت)
    // ========================================================

    // السحر المحاسبي: نقارن تاريخ الانتهاء مع (أحدث وقت موثوق به)
    // سواء كان الآن، أو آخر نبضة حقيقية من السيرفر، أيهما أحدث.
    final referenceTime = now.isAfter(lastHeartbeat) ? now : lastHeartbeat;

    if (expiryDate == null || referenceTime.isAfter(expiryDate)) {
      emit(
        state.copyWith(
          status: AuthStatus.subscriptionExpired,
          errorMessage:
              'انتهت صلاحية رخصة النظام. يرجى التواصل مع المطور لتسوية الدفعات وتجديد رخصة العمل.',
          userId: localUser.id,
          userName: localUser.fullName ?? localUser.email,
          roleName: roleName,
          isSystemAdmin: isSystemAdmin,
          permissions: finalPermissions.toList(),
        ),
      );
      return; // 🛑 منع الدخول تماماً
    }

    // 3. حفظ النتيجة النهائية النظيفة في الحالة (State) (في الوضع الطبيعي)
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
