// test/login/login_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:our_home_erp_app/login/cubit/login_cubit.dart';

import '../helpers/mocks.dart';

void main() {
  group('LoginCubit - Authentication & Network Behavior', () {
    late MockErpRepository mockErpRepository;

    setUp(() {
      mockErpRepository = MockErpRepository();
    });

    // =========================================================
    // ⚠️ 1. اختبار الحماية من الحقول الفارغة (Validation)
    // =========================================================
    blocTest<LoginCubit, LoginState>(
      'emits [failure] when email or password is empty without calling the server',
      build: () => LoginCubit(mockErpRepository),
      seed: () => const LoginState(email: 'admin@erp.com', password: ''),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const LoginState(
          status: LoginStatus.failure,
          email: 'admin@erp.com',
          password: '',
          errorMessage: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockErpRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    // =========================================================
    // 🌐 2. اختبار انقطاع الإنترنت (Offline Handling) - بعد حقن التبعية (DI)
    // =========================================================
    blocTest<LoginCubit, LoginState>(
      'emits [loading, failure] when there is no internet connection (Ping fails)',
      build: () => LoginCubit(
        mockErpRepository,
        // 🌟 السحر هنا: نحقن دالة فحص إنترنت تعيد "false" (مقطوع)
        checkInternetConnection: () async => false,
      ),
      seed: () => const LoginState(
        email: 'admin@erp.com',
        password: 'password123',
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const LoginState(
          status: LoginStatus.loading,
          email: 'admin@erp.com',
          password: 'password123',
        ),
        const LoginState(
          status: LoginStatus.failure,
          email: 'admin@erp.com',
          password: 'password123',
          errorMessage:
              'لا يوجد اتصال بالإنترنت! يرجى التحقق من الشبكة والمحاولة مجدداً. 🌐❌',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockErpRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    // =========================================================
    // 🔐 3. اختبار ترجمة أخطاء السيرفر (Invalid Credentials)
    // =========================================================
    blocTest<LoginCubit, LoginState>(
      'emits [loading, failure] with Arabic translation when Supabase throws invalid credentials',
      build: () {
        when(
          () => mockErpRepository.signIn(
            email: 'admin@erp.com',
            password: 'wrong_password',
          ),
        ).thenThrow(Exception('invalid login credentials'));

        return LoginCubit(
          mockErpRepository,
          // 🌟 نحقن إنترنت متصل لكي يتخطى فحص الشبكة ويستدعي السيرفر
          checkInternetConnection: () async => true,
        );
      },
      seed: () => const LoginState(
        email: 'admin@erp.com',
        password: 'wrong_password',
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const LoginState(
          status: LoginStatus.loading,
          email: 'admin@erp.com',
          password: 'wrong_password',
        ),
        const LoginState(
          status: LoginStatus.failure,
          email: 'admin@erp.com',
          password: 'wrong_password',
          errorMessage: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        ),
      ],
      verify: (_) {
        verify(
          () => mockErpRepository.signIn(
            email: 'admin@erp.com',
            password: 'wrong_password',
          ),
        ).called(1);
      },
    );
  });
}
