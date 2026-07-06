//lib/login/view/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../register/view/register_page.dart';
import 'package:erp_repository/erp_repository.dart';

import '../cubit/login_cubit.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 🌟 استدعاء دالة قراءة الإيميل المحفوظ بمجرد فتح الشاشة
      create: (context) =>
          LoginCubit(context.read<ErpRepository>())..loadSavedEmail(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // 🌟 استخدمنا Controller لكي نتمكن من تعبئة الإيميل تلقائياً إذا كان محفوظاً
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      // 🌟 التعديل الجوهري: إضافة MultiBlocListener
      body: MultiBlocListener(
        listeners: [
          // 1. مستمع تسجيل الدخول (LoginCubit)
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.email.isNotEmpty && _emailController.text.isEmpty) {
                _emailController.text = state.email;
              }

              if (state.status == LoginStatus.failure) {
                // 🌟 تحسين شكل عرض الخطأ بناءً على نوعه (إنترنت أو بيانات خاطئة)
                final isNetworkError =
                    state.errorMessage != null &&
                    state.errorMessage!.contains('الإنترنت');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isNetworkError ? Icons.wifi_off : Icons.error_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage ?? 'حدث خطأ غير معروف',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: isNetworkError
                        ? Colors.red.shade800
                        : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              // عند النجاح، نطلب من الحارس الشخصي فحص الصلاحيات
              else if (state.status == LoginStatus.success) {
                context.read<AuthCubit>().checkSession();
              }
            },
          ),

          // 2. مستمع الصلاحيات (AuthCubit) - لكشف أخطاء عدم وجود المستخدم
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.error) {
                // إظهار سبب الفشل الحقيقي (مثل: حسابك غير مفعل، أو غير موجود في جدول app_users)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'حدث خطأ أثناء التحقق من الصلاحيات',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
                // حماية إضافية: تسجيل الخروج لتنظيف الجلسة العالقة
                context.read<AuthCubit>().logout();
              }
            },
          ),
        ],
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment, size: 80, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text(
                    'نظام بيتنا العقاري',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'تسجيل الدخول للموظفين',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // حقل الإيميل مع تمرير الـ Controller
                  _EmailInput(controller: _emailController),
                  const SizedBox(height: 20),

                  // حقل كلمة المرور
                  const _PasswordInput(),
                  const SizedBox(height: 12),

                  // مربع اختيار "تذكرني" الأنيق
                  const _RememberMeCheckbox(),
                  const SizedBox(height: 32),

                  // زر تسجيل الدخول
                  const _LoginButton(),

                  const SizedBox(height: 24), // مسافة
                  // 🌟 زر إنشاء حساب موظف جديد
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.blueGrey,
                    ),
                    label: const Text(
                      'إنشاء حساب موظف جديد',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🧩 مكونات الشاشة الفرعية
// ==========================================

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'البريد الإلكتروني',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: true, // إخفاء الباسورد
          decoration: const InputDecoration(
            labelText: 'كلمة المرور',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

// 🌟 ميزة "تذكرني"
class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) =>
          previous.rememberMe != current.rememberMe,
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              value: state.rememberMe,
              activeColor: Colors.blueGrey,
              onChanged: (value) =>
                  context.read<LoginCubit>().rememberMeChanged(value ?? false),
            ),
            const Text(
              'تذكر البريد الإلكتروني',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    // 🌟 التعديل الجوهري: نراقب أيضاً حالة الصلاحيات
    final authState = context.watch<AuthCubit>().state;

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        // إذا كان التسجيل جاري، أو الصلاحيات قيد التحميل، نظهر دائرة التحميل
        final isLoading =
            state.status == LoginStatus.loading ||
            authState.status == AuthStatus.loading;

        return isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => context.read<LoginCubit>().submit(),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
      },
    );
  }
}
