// lib/buildings/view/buildings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';
import 'package:our_home_erp_app/buildings/widgets/widgets.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: Text(
          l10n.bldAddBuildingFab,
          style: const TextStyle(
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
                    state.errorMessage ?? l10n.bldUnexpectedError,
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
                    const _BuildingsHeader(count: 0),
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
                              l10n.bldEmptyList,
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
                  _BuildingsHeader(count: buildings.length),
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

class _BuildingsHeader extends StatelessWidget {
  const _BuildingsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          const Icon(Icons.domain, color: Colors.indigo, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.bldCatalogTitle,
              style: const TextStyle(
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
              l10n.bldTotalCount(count),
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
}
