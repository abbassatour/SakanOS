// lib/register/cubit/register_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._erpRepository) : super(const RegisterState());

  final ErpRepository _erpRepository;

  void fullNameChanged(String value) =>
      emit(state.copyWith(fullName: value, status: RegisterStatus.initial));
  void emailChanged(String value) =>
      emit(state.copyWith(email: value, status: RegisterStatus.initial));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, status: RegisterStatus.initial));
  void confirmPasswordChanged(String value) => emit(
    state.copyWith(confirmPassword: value, status: RegisterStatus.initial),
  );

  Future<void> submit() async {
    if (state.fullName.isEmpty ||
        state.email.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'registerErrorFillFields',
        ),
      );
      return;
    }

    if (state.password != state.confirmPassword) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'registerErrorPasswordMismatch',
        ),
      );
      return;
    }

    if (state.password.length < 6) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'registerErrorPasswordTooShort',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      bool hasInternet = false;
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet = true;
        }
      } catch (_) {
        hasInternet = false;
      }

      if (!hasInternet) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'registerErrorNoInternet',
          ),
        );
        return;
      }

      await _erpRepository.signUp(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      String errorKey = 'registerErrorDefault';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('user already exists') ||
          errorString.contains('already registered')) {
        errorKey = 'registerErrorEmailExists';
      } else if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup')) {
        errorKey = 'registerErrorConnectionLost';
      }

      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: errorKey,
        ),
      );
    }
  }
}
