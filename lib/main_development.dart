// lib/main_development.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; // 🌟 المكتبة الجديدة
import 'package:our_home_erp_app/app/app.dart';
import 'package:our_home_erp_app/bootstrap.dart';

void main() async {
  // 🌟 يجب التأكد من تهيئة بيئة فلاتر والنافذة أولاً
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // إعدادات النافذة الافتراضية عند الفتح
  WindowOptions windowOptions = const WindowOptions(
    title: 'نظام بيتنا العقاري', 
    center: true,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // تشغيل التطبيق
  bootstrap((erpRepository) => App(erpRepository: erpRepository));
}