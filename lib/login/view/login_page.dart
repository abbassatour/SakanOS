// lib/login/view/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../register/view/register_page.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/login_cubit.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _resolveLoginErrorMessage(BuildContext context, String? errorKey) {
    final l10n = context.l10n;
    switch (errorKey) {
      case 'loginErrorEmptyFields':
        return l10n.loginErrorEmptyFields;
      case 'loginErrorNoInternet':
        return l10n.loginErrorNoInternet;
      case 'loginErrorEmailNotConfirmed':
        return l10n.loginErrorEmailNotConfirmed;
      case 'loginErrorInvalidCredentials':
        return l10n.loginErrorInvalidCredentials;
      case 'loginErrorConnectionLost':
        return l10n.loginErrorConnectionLost;
      case 'loginErrorDefault':
        return l10n.loginErrorDefault;
      default:
        return errorKey ?? l10n.homeUnexpectedError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.email.isNotEmpty && _emailController.text.isEmpty) {
                _emailController.text = state.email;
              }

              if (state.status == LoginStatus.failure) {
                // 🌟 مسح حقل كلمة المرور تلقائياً إذا كانت البيانات خاطئة
                if (state.errorMessage == 'loginErrorInvalidCredentials') {
                  _passwordController.clear();
                  context.read<LoginCubit>().passwordChanged('');
                }

                final isNetworkError =
                    state.errorMessage != null &&
                    (state.errorMessage == 'loginErrorNoInternet' ||
                        state.errorMessage == 'loginErrorConnectionLost');

                final translatedMsg = _resolveLoginErrorMessage(
                  context,
                  state.errorMessage,
                );

                // 🌟 إخفاء أي رسالة خطأ سابقة لمنع التراكم
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

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
                          child: Text(translatedMsg),
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
              } else if (state.status == LoginStatus.success) {
                context.read<AuthCubit>().checkSession();
              }
            },
          ),
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.error) {
                // 🌟 إخفاء أي رسالة خطأ سابقة لمنع التراكم
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? l10n.loginAuthCheckError,
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SakanOS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginStaffTitle,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  _EmailInput(controller: _emailController),
                  const SizedBox(height: 20),

                  _PasswordInput(controller: _passwordController),
                  const SizedBox(height: 12),

                  const _RememberMeCheckbox(),
                  const SizedBox(height: 32),

                  const _LoginButton(),

                  const SizedBox(height: 24),
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
                    label: Text(
                      l10n.loginCreateAccountBtn,
                      style: const TextStyle(
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

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: controller,
      onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next, // 🌟 نقل التحديد لحقل كلمة المرور
      decoration: InputDecoration(
        labelText: l10n.loginEmailLabel,
        prefixIcon: const Icon(Icons.email_outlined),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({required this.controller});

  final TextEditingController controller;

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextField(
      controller: widget.controller,
      onChanged: (password) =>
          context.read<LoginCubit>().passwordChanged(password),
      obscureText: _isObscure,
      textInputAction: TextInputAction.done, // 🌟 إظهار زر "تم" في الكيبورد
      onSubmitted: (_) => context
          .read<LoginCubit>()
          .submit(), // 🌟 تسجيل الدخول عند الضغط على Enter
      decoration: InputDecoration(
        labelText: l10n.loginPasswordLabel,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.blueGrey,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            Text(
              l10n.loginRememberMe,
              style: const TextStyle(
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
    final l10n = context.l10n;
    final authState = context.watch<AuthCubit>().state;

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
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
                  child: Text(
                    l10n.loginSubmitBtn,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
      },
    );
  }
}
