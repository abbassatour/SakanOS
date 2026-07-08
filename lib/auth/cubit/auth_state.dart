// lib/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

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
    this.lastPinVerificationTime, // 🌟 [جديد] وقت آخر إدخال للـ PIN
  });

  final AuthStatus status;
  final String? userId;
  final String? userName;
  final String? roleName;
  final String securityPin;
  final bool isSystemAdmin;
  final List<String> permissions;
  final String? errorMessage;
  final DateTime? lastPinVerificationTime; // 🌟 [جديد]

  bool hasPermission(String permission) {
    if (isSystemAdmin) return true;
    return permissions.contains(permission);
  }

  // 🌟 [جديد] دالة للتحقق من صلاحية الجلسة المفتوحة (5 دقائق)
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
    DateTime? lastPinVerificationTime, // 🌟
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
      // إذا تم تمرير null، سيتجاهله ويحتفظ بالقديم. لتفريغه نمرر تاريخ قديم، لكننا لا نحتاج ذلك هنا.
      lastPinVerificationTime:
          lastPinVerificationTime ?? this.lastPinVerificationTime,
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
    lastPinVerificationTime, // 🌟
  ];
}
