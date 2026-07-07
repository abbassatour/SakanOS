// lib/login/cubit/login_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._erpRepository, {
    // 🌟 حقن التبعية: نسمح بتمرير دالة الفحص من الخارج لتسهيل الاختبار
    Future<bool> Function()? checkInternetConnection,
  }) : _checkInternetConnection =
           checkInternetConnection ?? _defaultCheckInternet,
       super(const LoginState());

  final ErpRepository _erpRepository;
  final Future<bool> Function() _checkInternetConnection;

  // 🌟 الدالة الافتراضية التي سيستخدمها التطبيق الحقيقي
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
    } catch (e) {}
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
          errorMessage: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // ==========================================
      // 🛡️ 1. الفحص المسبق للإنترنت (باستخدام الدالة المحقونة)
      // ==========================================
      final hasInternet = await _checkInternetConnection();

      if (!hasInternet) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage:
                'لا يوجد اتصال بالإنترنت! يرجى التحقق من الشبكة والمحاولة مجدداً. 🌐❌',
          ),
        );
        return; // خروج لعدم استدعاء قاعدة البيانات
      }

      // ==========================================
      // 🔄 2. محاولة تسجيل الدخول الفعلية
      // ==========================================
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

      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      // ==========================================
      // 🐛 3. التقاط الأخطاء وتخصيص الرسائل
      // ==========================================
      String msg =
          'فشل تسجيل الدخول. تأكد من صحة البيانات أو اتصالك بالإنترنت.';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('email not confirmed')) {
        msg = 'يرجى تأكيد بريدك الإلكتروني أولاً عبر الرابط الذي أرسلناه إليك.';
      } else if (errorString.contains('invalid login credentials')) {
        msg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      } else if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('clientexception')) {
        msg = 'انقطع الاتصال بالإنترنت أثناء تسجيل الدخول. 🌐❌';
      }

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: msg,
        ),
      );
    }
  }
}
