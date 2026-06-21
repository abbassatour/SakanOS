// lib/buildings/view/buildings_page.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/buildings_cubit.dart';
import 'buildings_view.dart';

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BuildingsCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return const BuildingsView();
  }
}