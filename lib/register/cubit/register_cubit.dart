// lib/register/cubit/register_cubit.dart
import 'dart:async'; // 🌟 لاستخدام المهلة timeout
import 'dart:io'; // 🌟 لاختبار الاتصال
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
    // 1. التحقق من الحقول الفارغة
    if (state.fullName.isEmpty ||
        state.email.isEmpty ||
        state.password.isEmpty ||
        state.confirmPassword.isEmpty) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'يرجى تعبئة جميع الحقول بشكل صحيح.',
        ),
      );
      return;
    }

    // 2. التحقق من تطابق كلمتي المرور
    if (state.password != state.confirmPassword) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'كلمتا المرور غير متطابقتين! يرجى التأكد منهما.',
        ),
      );
      return;
    }

    // 3. التحقق من طول كلمة المرور
    if (state.password.length < 6) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage:
              'كلمة المرور يجب أن تتكون من 6 أحرف أو أرقام على الأقل.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      // ==========================================
      // 🛡️ الفحص المسبق للإنترنت (مهلة 5 ثوانٍ فقط)
      // ==========================================
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

      // ⛔ إذا لم يكن هناك إنترنت، نوقف العملية فوراً
      if (!hasInternet) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage:
                'لا يوجد اتصال بالإنترنت! إنشاء الحساب يتطلب اتصالاً بالسحابة. 🌐❌',
          ),
        );
        return; // خروج لعدم استدعاء قاعدة البيانات
      }

      // ==========================================
      // 🔄 محاولة التسجيل الفعلية (الإنترنت متوفر)
      // ==========================================
      await _erpRepository.signUp(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      // ==========================================
      // 🐛 التقاط الأخطاء الخاصة بالتسجيل
      // ==========================================
      String msg = 'فشل التسجيل. يرجى التأكد من البيانات أو اتصالك بالشبكة.';
      final errorString = e.toString().toLowerCase();

      // اصطياد أخطاء Supabase الشائعة في التسجيل
      if (errorString.contains('user already exists') ||
          errorString.contains('already registered')) {
        msg =
            'البريد الإلكتروني مستخدم بالفعل! يرجى تسجيل الدخول أو استخدام بريد آخر.';
      }
      // في حال انقطع الإنترنت فجأة أثناء إرسال الطلب
      else if (errorString.contains('socketexception') ||
          errorString.contains('failed host lookup')) {
        msg = 'انقطع الاتصال بالإنترنت أثناء محاولة التسجيل. 🌐❌';
      }

      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: msg,
        ),
      );
    }
  }
}
