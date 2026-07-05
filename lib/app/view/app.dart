import 'dart:io' show Platform;

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
        RepositoryProvider.value(value: erpRepository),
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