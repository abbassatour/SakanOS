// lib/app/view/app.dart
import 'dart:io' show Platform, InternetAddress;

import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:our_home_erp_app/l10n/cubit/locale_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/dashboard/view/dashboard_page.dart';
import 'package:our_home_erp_app/login/view/login_page.dart';
import 'package:window_manager/window_manager.dart';

String _resolveAuthErrorMessage(BuildContext context, String? errorKey) {
  final l10n = context.l10n;
  switch (errorKey) {
    case 'authErrorUserNotFound':
      return l10n.authErrorUserNotFound;
    case 'authErrorAccountDisabled':
      return l10n.authErrorAccountDisabled;
    case 'authErrorTimeTampered':
      return l10n.authErrorTimeTampered;
    case 'authErrorOfflineLimitExceeded':
      return l10n.authErrorOfflineLimitExceeded;
    case 'authErrorSubscriptionExpired':
      return l10n.authErrorSubscriptionExpired;
    default:
      return errorKey ?? l10n.homeUnexpectedError;
  }
}

class App extends StatelessWidget {
  const App({
    required this.erpRepository,
    super.key,
  });

  final ErpRepository erpRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ErpRepository>.value(
      value: erpRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocaleCubit(),
          ),
          BlocProvider(
            create: (context) => AuthCubit(erpRepository),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;

    return MaterialApp(
      title: 'SakanOS',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma',
      ),
      home: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.userName != current.userName ||
            previous.status != current.status,
        listener: (context, state) async {
          if (!_isDesktop) return;

          if (state.status == AuthStatus.authenticated &&
              state.userName != null) {
            await windowManager.setTitle(
              '  SakanOS - [ ${state.userName} | ${state.roleName} ]',
            );
          } else {
            await windowManager.setTitle('  SakanOS');
          }
        },
        buildWhen: (previous, current) {
          if ((previous.status == AuthStatus.unauthenticated ||
                  previous.status == AuthStatus.error) &&
              current.status == AuthStatus.loading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state.status == AuthStatus.initial ||
              state.status == AuthStatus.loading) {
            return const _LoadingScreen();
          }

          if (state.status == AuthStatus.offlineLock) {
            return const _OfflineLockScreen();
          }

          if (state.status == AuthStatus.subscriptionExpired) {
            return const _SubscriptionLockScreen();
          }

          if (state.status == AuthStatus.authenticated) {
            return const DashboardPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _OfflineLockScreen extends StatefulWidget {
  const _OfflineLockScreen();

  @override
  State<_OfflineLockScreen> createState() => _OfflineLockScreenState();
}

class _SubscriptionLockScreen extends StatefulWidget {
  const _SubscriptionLockScreen();

  @override
  State<_SubscriptionLockScreen> createState() =>
      _SubscriptionLockScreenState();
}

class _SubscriptionLockScreenState extends State<_SubscriptionLockScreen> {
  bool _isSyncing = false;

  Future<void> _checkSubscriptionUpdate() async {
    final l10n = context.l10n;
    setState(() => _isSyncing = true);

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception(l10n.lockSubscriptionNoInternet);
      }

      // 🌟 التعديل السحري: الاعتماد على رمي الأخطاء (Exceptions) بدلاً من فحص النصوص الثابتة
      await context.read<ErpRepository>().forceSyncWithCloud();

      if (mounted) {
        await context.read<AuthCubit>().checkSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // 🌟 تنظيف مظهر رسالة الخطأ
            content: Text(
              e
                  .toString()
                  .replaceAll('Exception: ', '')
                  .replaceAll('Exception', ''),
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AuthCubit>().state;

    final errorMessage = _resolveAuthErrorMessage(context, state.errorMessage);

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_off_rounded,
                  size: 80,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.lockSubscriptionTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSyncing ? null : _checkSubscriptionUpdate,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isSyncing
                        ? l10n.lockSubscriptionVerifying
                        : l10n.lockSubscriptionVerifyBtn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: _isSyncing
                    ? null
                    : () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.lockLogoutBtn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineLockScreenState extends State<_OfflineLockScreen> {
  bool _isSyncing = false;

  Future<void> _attemptForceSync() async {
    final l10n = context.l10n;
    setState(() => _isSyncing = true);

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception(l10n.lockOfflineNoInternet);
      }

      // 🌟 التعديل السحري: الاعتماد على رمي الأخطاء (Exceptions) بدلاً من فحص النصوص الثابتة
      await context.read<ErpRepository>().forceSyncWithCloud();

      if (mounted) {
        await context.read<AuthCubit>().checkSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e
                        .toString()
                        .replaceAll('Exception: ', '')
                        .replaceAll('Exception', ''),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AuthCubit>().state;

    final errorMessage = _resolveAuthErrorMessage(context, state.errorMessage);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.lockOfflineTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSyncing ? null : _attemptForceSync,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _isSyncing
                        ? l10n.lockOfflineSyncing
                        : l10n.lockOfflineSyncBtn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: _isSyncing
                    ? null
                    : () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.lockLogoutBtn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
