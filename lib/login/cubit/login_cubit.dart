// lib/login/cubit/login_cubit.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._erpRepository) : super(const LoginState());

  final ErpRepository _erpRepository;
  static const String _rememberEmailKey = 'saved_remember_me_email';

  /// Loads the saved email from SharedPreferences if "Remember Me" was previously checked.
  Future<void> loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_rememberEmailKey);
      if (savedEmail != null && savedEmail.isNotEmpty) {
        emit(state.copyWith(email: savedEmail, rememberMe: true));
      }
    } catch (e, stack) {
      log('Failed to load saved email', error: e, stackTrace: stack);
    }
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  void rememberMeChanged(bool value) {
    emit(state.copyWith(rememberMe: value, status: LoginStatus.initial));
  }

  Future<void> submit() async {
    final trimmedEmail = state.email.trim();
    if (trimmedEmail.isEmpty || state.password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'loginErrorEmptyFields',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // Direct sign-in attempt via repository
      await _erpRepository.signIn(
        email: trimmedEmail,
        password: state.password,
      );

      // Persist or clear Remember Me email
      final prefs = await SharedPreferences.getInstance();
      if (state.rememberMe) {
        await prefs.setString(_rememberEmailKey, trimmedEmail);
      } else {
        await prefs.remove(_rememberEmailKey);
      }

      emit(state.copyWith(status: LoginStatus.success));
    } on AuthException catch (e, stackTrace) {
      log(
        'Supabase AuthException: ${e.message} (code: ${e.code})',
        stackTrace: stackTrace,
      );

      String errorKey = 'loginErrorDefault';
      final msg = e.message.toLowerCase();

      if (msg.contains('email not confirmed') ||
          e.code == 'email_not_confirmed') {
        errorKey = 'loginErrorEmailNotConfirmed';
      } else if (msg.contains('invalid') ||
          e.code == 'invalid_credentials' ||
          e.statusCode == '400') {
        errorKey = 'loginErrorInvalidCredentials';
      }

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: errorKey,
        ),
      );
    } catch (e, stackTrace) {
      log('Unexpected Login Error: $e', stackTrace: stackTrace);

      final errorString = e.toString().toLowerCase();
      String errorKey = 'loginErrorDefault';

      if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('clientexception') ||
          errorString.contains('handshakeexception')) {
        errorKey = 'loginErrorConnectionLost';
      }

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: errorKey,
        ),
      );
    }
  }
}
