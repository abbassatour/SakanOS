part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.userName,
    this.roleName,
    this.isSystemAdmin = false,
    this.permissions = const [],
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? userName;
  final String? roleName;
  final bool isSystemAdmin; // 🌟 إذا كانت true، هذا المستخدم يتخطى كل الفحوصات
  final List<String> permissions; // قائمة الصلاحيات النهائية الصافية
  final String? errorMessage;

  // 🌟 هذه هي الدالة السحرية التي سنستخدمها في الواجهة (UI) لإخفاء/إظهار الأزرار
  bool hasPermission(String permission) {
    if (isSystemAdmin) return true; // الآدمن يرى كل شيء دائماً
    return permissions.contains(permission);
  }

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? userName,
    String? roleName,
    bool? isSystemAdmin,
    List<String>? permissions,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      roleName: roleName ?? this.roleName,
      isSystemAdmin: isSystemAdmin ?? this.isSystemAdmin,
      permissions: permissions ?? this.permissions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    userName,
    roleName,
    isSystemAdmin,
    permissions,
    errorMessage,
  ];
}
