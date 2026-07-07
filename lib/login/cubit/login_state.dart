//lib\login\cubit\login_state.dart
part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.rememberMe = false, // 🌟 الحقل الجديد
    this.errorMessage,
  });

  final LoginStatus status;
  final String email;
  final String password;
  final bool rememberMe; // 🌟
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? rememberMe,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    rememberMe,
    errorMessage,
  ];
}
