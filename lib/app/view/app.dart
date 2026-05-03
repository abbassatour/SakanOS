import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:erp_repository/erp_repository.dart';
import 'package:window_manager/window_manager.dart'; // 🌟 استدعاء المكتبة هنا

import '../../auth/cubit/auth_cubit.dart'; 
import '../../login/view/login_page.dart';
import '../../dashboard/view/dashboard_page.dart';

class App extends StatelessWidget {
  const App({
    required this.erpRepository,
    super.key,
  });

  final ErpRepository erpRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:[
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our Home ERP',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const[
        Locale('ar', 'AE'), 
      ],
      locale: const Locale('ar', 'AE'), 
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma', 
      ),
      
      // 🌟 استخدام BlocConsumer بدلاً من BlocBuilder
      home: BlocConsumer<AuthCubit, AuthState>(
        // 🌟 المستمع (Listener) لتغيير شريط الويندوز في الأعلى
        listenWhen: (previous, current) => previous.userName != current.userName || previous.status != current.status,
        listener: (context, state) async {
          if (state.status == AuthStatus.authenticated && state.userName != null) {
            // إضافة اسم الموظف ودوره بجانب اسم البرنامج في الويندوز
            await windowManager.setTitle(' بيتنا Our Home - [ ${state.userName} | ${state.roleName} ]');
          } else {
            // إرجاع الاسم الافتراضي عند تسجيل الخروج
            await windowManager.setTitle(' بيتنا Our Home');
          }
        },
        // 🌟 حماية التطبيق من الكراش أثناء الانتقال
        buildWhen: (previous, current) {
          if ((previous.status == AuthStatus.unauthenticated || previous.status == AuthStatus.error) && 
              current.status == AuthStatus.loading) {
            return false; 
          }
          return true;
        },
        builder: (context, state) {
          if (state.status == AuthStatus.initial || state.status == AuthStatus.loading) {
            return const Scaffold(
              backgroundColor: Colors.blueGrey,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
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