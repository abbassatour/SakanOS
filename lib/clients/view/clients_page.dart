// مسار الملف: lib/clients/view/clients_page.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';

import 'clients_view.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // إذا كنت تحتاج مستقبلاً إلى توفير BlocProvider جديد خاص بهذه الشاشة، 
    // فهذا هو المكان الأنسب له. حالياً نعرض الـ View مباشرة.
    return const ClientsView();
  }
}
