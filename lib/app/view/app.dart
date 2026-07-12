//lib\app\view\app.dart
import 'dart:io' show Platform, InternetAddress; // 🌟 أضفنا InternetAddress هنا

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/dashboard/view/dashboard_page.dart';
import 'package:our_home_erp_app/login/view/login_page.dart';
import 'package:window_manager/window_manager.dart';

class App extends StatelessWidget {
  const App({
    required this.erpRepository,
    super.key,
  });

  final ErpRepository erpRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<ErpRepository>.value(
          value: erpRepository,
          // الدالة التي ستعمل عند التخلص من الـ Provider
          // للأسف RepositoryProvider.value لا يملك خاصية dispose تلقائية،
          // لذلك هذا الإجراء كافٍ بما أن الـ ErpRepository يعيش طوال دورة حياة التطبيق.
          // لكن دالة dispose التي أضفناها ستكون جاهزة للاستخدام في الـ main أو الـ teardown إذا احتجنا.
        ),
        BlocProvider(
          create: (context) => AuthCubit(erpRepository),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  /// 🛡️ حماية المنصة: التحقق من أن بيئة التشغيل هي نظام مكتبي وليس ويب أو موبايل
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our Home ERP',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      locale: const Locale('ar', 'AE'),
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma',
      ),

      // 🌟 استخدام BlocConsumer لتحديث شريط الويندوز وبناء الشاشات
      home: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.userName != current.userName ||
            previous.status != current.status,
        listener: (context, state) async {
          // 🛡️ لا نعدل عنوان النافذة إلا إذا كنا على أنظمة الديسكتوب
          if (!_isDesktop) return;

          if (state.status == AuthStatus.authenticated &&
              state.userName != null) {
            await windowManager.setTitle(
              ' بيتنا Our Home - [ ${state.userName} | ${state.roleName} ]',
            );
          } else {
            await windowManager.setTitle(' بيتنا Our Home');
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

          // 👇👇 [الأسطر الجديدة] 👇👇
          // 🛑 إذا كان التطبيق مقفلاً بسبب انتهاء فترة الأوفلاين
          if (state.status == AuthStatus.offlineLock) {
            return const _OfflineLockScreen();
          }
          // 👆👆 [نهاية الإضافة] 👆👆

          // 👇👇 [السطرين الجديدين] 👇👇
          if (state.status == AuthStatus.subscriptionExpired) {
            return const _SubscriptionLockScreen();
          }
          // 👆👆 [نهاية الإضافة] 👆👆

          if (state.status == AuthStatus.authenticated) {
            return const DashboardPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}

/// 🌟 فصل شاشة التحميل في ويدجت مستقل لزيادة المقروئية وقابلية الاختبار
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

// ==========================================
// 🛑 شاشة القفل الإجباري (Offline Limit Reached)
// ==========================================
class _OfflineLockScreen extends StatefulWidget {
  const _OfflineLockScreen();

  @override
  State<_OfflineLockScreen> createState() => _OfflineLockScreenState();
}

// ==========================================
// 💸 شاشة انتهاء الاشتراك (Subscription Expired)
// ==========================================
class _SubscriptionLockScreen extends StatefulWidget {
  const _SubscriptionLockScreen();

  @override
  State<_SubscriptionLockScreen> createState() =>
      _SubscriptionLockScreenState();
}

class _SubscriptionLockScreenState extends State<_SubscriptionLockScreen> {
  bool _isSyncing = false;

  Future<void> _checkSubscriptionUpdate() async {
    setState(() => _isSyncing = true);

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('لا يوجد اتصال بالإنترنت للتحقق من الرخصة.');
      }

      // 🌟 سحب البيانات (ومن ضمنها تاريخ الاشتراك الجديد) من Supabase
      final msg = await context.read<ErpRepository>().forceSyncWithCloud();

      if (!msg.contains('بنجاح')) {
        throw Exception(msg);
      }

      // إعادة فحص الجلسة (ستختفي هذه الشاشة تلقائياً إذا قام المطور بتمديد التاريخ)
      if (mounted) {
        await context.read<AuthCubit>().checkSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
    final state = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: Colors.black87, // لون خلفية مظلم يدل على الإيقاف
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

              const Text(
                'انتهت صلاحية الرخصة',
                style: TextStyle(
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
                  state.errorMessage ??
                      'انتهت فترة الاشتراك. يرجى التواصل مع الدعم الفني.',
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
                        ? 'جاري التحقق مع السيرفر...'
                        : 'التحقق من تجديد الاشتراك',
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
                label: const Text('تسجيل الخروج وإقفال الحساب'),
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
    setState(() => _isSyncing = true);

    try {
      // 1. فحص اتصال الإنترنت
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.');
      }

      // 2. محاولة المزامنة الإجبارية
      final msg = await context.read<ErpRepository>().forceSyncWithCloud();

      if (!msg.contains('بنجاح')) {
        throw Exception(msg);
      }

      // 3. إعادة فحص الجلسة (التي ستقرأ تاريخ النبضة الجديد وتفتح التطبيق)
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
                  child: Text(e.toString().replaceAll('Exception: ', '')),
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
    final state = context.watch<AuthCubit>().state;

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
              // أيقونة القفل
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

              // العنوان
              const Text(
                'النظام مقفل مؤقتاً',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // رسالة الخطأ القادمة من الـ AuthCubit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  state.errorMessage ??
                      'انتهت صلاحية العمل دون اتصال بالإنترنت.',
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

              // زر المزامنة
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
                        ? 'جاري المزامنة مع السحابة...'
                        : 'توصيل ومزامنة البيانات الآن',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // زر تسجيل الخروج الإجباري
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                onPressed: _isSyncing
                    ? null
                    : () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج وإقفال الحساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
