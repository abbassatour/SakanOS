// lib/main_development.dart
import 'dart:io'; // لفحص نظام التشغيل
import 'package:flutter/foundation.dart'; // لفحص بيئة الويب kIsWeb
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:our_home_erp_app/app/app.dart';
import 'package:our_home_erp_app/bootstrap.dart';

void main() async {
  // 1. التأكد من تهيئة بيئة فلاتر أولاً
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🛡️ حماية الأندرويد: تشغيل إعدادات النافذة فقط إذا كنا على أنظمة الكمبيوتر
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    // إعدادات النافذة الافتراضية للكمبيوتر
    WindowOptions windowOptions = const WindowOptions(
      title: 'نظام بيتنا العقاري',
      center: true,
      minimumSize: Size(
        800,
        600,
      ), // يفضل وضع حجم أدنى لكي لا يصغر الموظف الشاشة جداً وتختفي الأزرار
    );

    // التحكم بالنافذة قبل إظهارها للمستخدم
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();

      // 🌟 السطر السحري الجديد: تكبير النافذة لتأخذ كامل الشاشة (Maximized) تلقائياً
      await windowManager.maximize();
    });
  }

  // 3. تشغيل التطبيق (هذا السطر سيعمل للكمبيوتر والأندرويد بشكل طبيعي)
  bootstrap((erpRepository) => App(erpRepository: erpRepository));
}
