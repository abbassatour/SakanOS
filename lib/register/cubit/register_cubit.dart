//lib\register\cubit\register_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._erpRepository) : super(const RegisterState());

  final ErpRepository _erpRepository;

  void fullNameChanged(String value) => emit(state.copyWith(fullName: value, status: RegisterStatus.initial));
  void emailChanged(String value) => emit(state.copyWith(email: value, status: RegisterStatus.initial));
  void passwordChanged(String value) => emit(state.copyWith(password: value, status: RegisterStatus.initial));
  // 🌟 دالة الاستماع لتأكيد كلمة المرور
  void confirmPasswordChanged(String value) => emit(state.copyWith(confirmPassword: value, status: RegisterStatus.initial));

  Future<void> submit() async {
    // 1. التحقق من الحقول الفارغة
    if (state.fullName.isEmpty || state.email.isEmpty || state.password.isEmpty || state.confirmPassword.isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'يرجى تعبئة جميع الحقول بشكل صحيح.'));
      return;
    }
    
    // 🌟 2. التحقق من تطابق كلمتي المرور
    if (state.password != state.confirmPassword) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'كلمتا المرور غير متطابقتين! يرجى التأكد منهما.'));
      return;
    }
    
    // 3. التحقق من طول كلمة المرور (قاعدة في Supabase)
    if (state.password.length < 6) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'كلمة المرور يجب أن تتكون من 6 أحرف أو أرقام على الأقل.'));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));
    
    try {
      // 4. إرسال الطلب للسحابة
      await _erpRepository.signUp(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
      );
      
      emit(state.copyWith(status: RegisterStatus.success));
      
    } catch (e) {
      // Supabase سيرجع خطأ إذا كان الإيميل مستخدماً من قبل
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'فشل التسجيل. قد يكون البريد الإلكتروني مستخدماً بالفعل.'));
    }
  }
}