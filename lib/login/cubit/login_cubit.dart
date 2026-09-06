// lib/login/cubit/login_cubit.dart
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // 👈 تم تصحيح الكلمة هنا
import 'package:erp_repository/erp_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._erpRepository, {
    Future<bool> Function()? checkInternetConnection,
  }) : _checkInternetConnection =
           checkInternetConnection ?? _defaultCheckInternet,
       super(const LoginState());

  final ErpRepository _erpRepository;
  final Future<bool> Function() _checkInternetConnection;

  static Future<bool> _defaultCheckInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadSavedEmail() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'remember_me.txt'));

      if (file.existsSync()) {
        final savedEmail = await file.readAsString();
        if (savedEmail.isNotEmpty) {
          emit(state.copyWith(email: savedEmail, rememberMe: true));
        }
      }
    } catch (_) {}
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
    if (state.email.isEmpty || state.password.isEmpty) {
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
      final hasInternet = await _checkInternetConnection();

      if (!hasInternet) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'loginErrorNoInternet',
          ),
        );
        return;
      }

      await _erpRepository.signIn(
        email: state.email.trim(),
        password: state.password,
      );

      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'remember_me.txt'));

      if (state.rememberMe) {
        await file.writeAsString(state.email.trim());
      } else {
        if (file.existsSync()) await file.delete();
      }

      // 🌟 تسجيل الدخول نجح
      emit(state.copyWith(status: LoginStatus.success));

      // 🌟 تنظيف الـ State بعد قليل لكي لا تبقى معلقة إذا قام بالخروج لاحقاً
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) {
          emit(state.copyWith(status: LoginStatus.initial, password: ''));
        }
      });
    } catch (e, stackTrace) {
      log('🚨 Supabase Login Error: $e', stackTrace: stackTrace);

      String errorKey = 'loginErrorDefault';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('email not confirmed')) {
        errorKey = 'loginErrorEmailNotConfirmed';
      } else if (errorString.contains('invalid login credentials')) {
        errorKey = 'loginErrorInvalidCredentials';
      } else if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('clientexception')) {
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
