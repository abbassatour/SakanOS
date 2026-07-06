// lib/buildings/view/buildings_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';
import 'package:our_home_erp_app/buildings/view/buildings_view.dart';

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<BuildingsCubit>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    return const BuildingsView();
  }
}
