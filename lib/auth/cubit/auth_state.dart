// lib/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

// 🌟 التعديل هنا: إضافة subscriptionExpired
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  offlineLock,
  subscriptionExpired,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.userName,
    this.roleName,
    this.securityPin = '0000',
    this.isSystemAdmin = false,
    this.permissions = const [],
    this.errorMessage,
    this.lastPinVerificationTime, // وقت آخر إدخال للـ PIN
    this.loadingMessageKey =
        'syncStepConnecting', // 🌟 [جديد] مفتاح ترجمة الخطوة الحالية
    this.loadingProgress = 0.0, // 🌟 [جديد] نسبة تقدم التحميل من 0.0 إلى 1.0
  });

  final AuthStatus status;
  final String? userId;
  final String? userName;
  final String? roleName;
  final String securityPin;
  final bool isSystemAdmin;
  final List<String> permissions;
  final String? errorMessage;
  final DateTime? lastPinVerificationTime;
  final String loadingMessageKey; // 🌟 [جديد]
  final double loadingProgress; // 🌟 [جديد]

  bool hasPermission(String permission) {
    if (isSystemAdmin) return true;
    return permissions.contains(permission);
  }

  // 🌟 دالة للتحقق من صلاحية الجلسة المفتوحة (5 دقائق)
  bool get isPinGracePeriodActive {
    if (lastPinVerificationTime == null) return false;
    final difference = DateTime.now().difference(lastPinVerificationTime!);
    return difference.inMinutes < 5; // يمكنك تغيير الرقم حسب رغبتك
  }

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? userName,
    String? roleName,
    String? securityPin,
    bool? isSystemAdmin,
    List<String>? permissions,
    String? errorMessage,
    DateTime? lastPinVerificationTime,
    bool clearGracePeriod = false, // لإجبار مسح الجلسة
    String? loadingMessageKey, // 🌟 [جديد]
    double? loadingProgress, // 🌟 [جديد]
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      roleName: roleName ?? this.roleName,
      securityPin: securityPin ?? this.securityPin,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      permissions: permissions ?? this.permissions,
      errorMessage: errorMessage ?? this.errorMessage,
      lastPinVerificationTime: clearGracePeriod
          ? null
          : (lastPinVerificationTime ?? this.lastPinVerificationTime),
      loadingMessageKey:
          loadingMessageKey ?? this.loadingMessageKey, // 🌟 [جديد]
      loadingProgress: loadingProgress ?? this.loadingProgress, // 🌟 [جديد]
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    userName,
    roleName,
    securityPin,
    isSystemAdmin,
    permissions,
    errorMessage,
    lastPinVerificationTime,
    loadingMessageKey, // 🌟 [جديد]
    loadingProgress, // 🌟 [جديد]
  ];
}
