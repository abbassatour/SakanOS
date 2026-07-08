part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.userName,
    this.roleName,
    this.securityPin = '0000', // 🌟 [جديد]
    this.isSystemAdmin = false,
    this.permissions = const [],
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? userName;
  final String? roleName;
  final String securityPin; // 🌟 [جديد]
  final bool isSystemAdmin;
  final List<String> permissions;
  final String? errorMessage;

  bool hasPermission(String permission) {
    if (isSystemAdmin) return true;
    return permissions.contains(permission);
  }

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? userName,
    String? roleName,
    String? securityPin, // 🌟
    bool? isSystemAdmin,
    List<String>? permissions,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      roleName: roleName ?? this.roleName,
      securityPin: securityPin ?? this.securityPin, // 🌟
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
    securityPin, // 🌟
    isSystemAdmin,
    permissions,
    errorMessage,
  ];
}
