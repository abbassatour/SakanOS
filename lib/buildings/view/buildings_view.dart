// lib/buildings/view/buildings_view.dart
// ignore_for_file: always_use_package_imports, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/buildings_cubit.dart';
import '../widgets/widgets.dart';

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          const Icon(Icons.domain, color: Colors.indigo, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'كتالوج المشاريع والوحدات',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Text(
              'الإجمالي: $count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text(
          'إضافة محضر جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocListener<BuildingsCubit, BuildingsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == BuildingsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'حدث خطأ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<BuildingsCubit, BuildingsState>(
            buildWhen: (previous, current) =>
                previous.status == BuildingsStatus.loading ||
                previous.buildings.length != current.buildings.length,
            builder: (context, state) {
              if (state.status == BuildingsStatus.loading &&
                  state.buildings.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo.shade600,
                  ),
                );
              }

              if (state.buildings.isEmpty) {
                return Column(
                  children: [
                    _buildHeader(0),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.domain_disabled,
                              size: 80,
                              color: Colors.indigo.shade100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد محاضر عقارية حتى الآن.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              final buildings = state.buildings;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(buildings.length),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      itemCount: buildings.length,
                      itemBuilder: (context, index) {
                        final building = buildings[index];
                        return BuildingCard(
                          building: building,
                          isFirst: index == 0,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
