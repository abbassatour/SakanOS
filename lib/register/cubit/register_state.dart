//lib\register\cubit\register_state.dart
part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.errorMessage,
  });

  final RegisterStatus status;
  final String fullName;
  final String email;
  final String password;
  final String? errorMessage;

  RegisterState copyWith({
    RegisterStatus? status,
    String? fullName,
    String? email,
    String? password,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, fullName, email, password, errorMessage];
}