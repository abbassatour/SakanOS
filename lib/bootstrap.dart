// lib/bootstrap.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart'; // 🌟 مكتبة ضرورية لـ PlatformDispatcher
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';

// استدعاء الحزم التي بنيناها
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:erp_repository/erp_repository.dart';

/// مراقب حالة التطبيق (BlocObserver)
/// يقوم بطباعة أي تغيير في حالة الشاشات أو أي خطأ برمجي لتسهيل اكتشاف الأخطاء
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// دالة التشغيل الأساسية (Bootstrap)
Future<void> bootstrap(FutureOr<Widget> Function(ErpRepository) builder) async {
  // 1. 🌟 التهيئة الأساسية لمُحرك فلاتر (يجب أن تكون في الجذر لتجنب Zone mismatch)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🌟 التقاط أخطاء واجهة المستخدم (UI / Synchronous Errors)
  FlutterError.onError = (details) {
    log(
      'Flutter UI Error: ${details.exceptionAsString()}',
      stackTrace: details.stack,
    );
  };

  // 3. 🌟 التقاط الأخطاء الخفية (Asynchronous Errors) - الطريقة الحديثة البديلة لـ runZonedGuarded
  PlatformDispatcher.instance.onError = (error, stack) {
    log('Async Error: $error', stackTrace: stack);
    return true; // إرجاع true يعني أننا قمنا بمعالجة الخطأ ولن ينهار التطبيق
  };

  // 4. تهيئة مراقب الـ BLoC
  Bloc.observer = const AppBlocObserver();

  try {
    // ==========================================
    // 5. تهيئة قاعدة البيانات السحابية (Supabase)
    // ==========================================
    await Supabase.initialize(
      url: 'https://krdfrdzyfdcqjmnuzads.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZGZyZHp5ZmRjcWptbnV6YWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NTQzOTksImV4cCI6MjA5MDEzMDM5OX0.IzREUxh7vyCE3mBlVj79U6ED8ACOfORGND6YS4yPxgg',
    );

    // ==========================================
    // 6. تهيئة الحزم المحلية والسحابية والمستودع
    // ==========================================
    final cloudStorageClient = CloudStorageClient();
    final localStorageApi = LocalStorageApi();

    final erpRepository = ErpRepository(
      localStorageApi: localStorageApi,
      cloudStorageClient: cloudStorageClient,
    );

    // 7. تشغيل واجهة المستخدم وتمرير المستودع لها
    runApp(await builder(erpRepository));
  } catch (e, stackTrace) {
    // التقاط أي خطأ قد يحدث أثناء التهيئة (Initialization)
    log('Critical Initialization Error: $e', stackTrace: stackTrace);
  }
}
