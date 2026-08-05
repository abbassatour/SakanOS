// lib/register/view/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/register_cubit.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<ErpRepository>()),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure) {
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
                        state.errorMessage ?? l10n.homeUnexpectedError,
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
          } else if (state.status == RegisterStatus.success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_unread,
                      color: Colors.indigo,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.registerEmailConfirmTitle,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.registerEmailConfirmSent,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.registerStepsHeader,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.registerStep1}\n${l10n.registerStep2}\n${l10n.registerStep3}',
                      style: const TextStyle(height: 1.6, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.registerNoticeWarning,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.registerBackToLogin),
                  ),
                ],
              ),
            );
          }
        },
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
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 70,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registerTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registerSubtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    onChanged: (val) =>
                        context.read<RegisterCubit>().fullNameChanged(val),
                    decoration: InputDecoration(
                      labelText: l10n.registerFullName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (val) =>
                        context.read<RegisterCubit>().emailChanged(val),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.registerEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (val) =>
                        context.read<RegisterCubit>().passwordChanged(val),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.registerPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (val) => context
                        .read<RegisterCubit>()
                        .confirmPasswordChanged(val),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.registerConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_reset),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      return state.status == RegisterStatus.loading
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
                                onPressed: () =>
                                    context.read<RegisterCubit>().submit(),
                                child: Text(
                                  l10n.registerSubmitBtn,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
                    label: Text(
                      l10n.registerCancelBtn,
                      style: const TextStyle(color: Colors.blueGrey),
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
