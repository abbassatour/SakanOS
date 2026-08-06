// lib/clients/view/clients_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/clients/cubit/clients_cubit.dart';
import 'package:our_home_erp_app/clients/widgets/widgets.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  String _searchQuery = '';

  String _resolveClientErrorMessage(BuildContext context, String? errorKey) {
    final l10n = context.l10n;
    switch (errorKey) {
      case 'clientErrorDeleteHasContracts':
        return l10n.clientErrorDeleteHasContracts;
      default:
        return errorKey ?? l10n.clientUnexpectedError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canCreate = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.hasPermission(AppPermissions.createClients),
    );
    final canEdit = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.hasPermission(AppPermissions.editClients),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: canCreate ? () => showAddClientDialog(context) : null,
        icon: const Icon(Icons.person_add),
        label: Text(
          l10n.clientAddButton,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: canCreate ? Colors.blueAccent : Colors.grey.shade300,
        foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
        elevation: canCreate ? 6 : 0,
        tooltip: canCreate
            ? l10n.clientAddTooltip
            : l10n.clientNoAddPermissionTooltip,
      ),
      body: SafeArea(
        child: BlocConsumer<ClientsCubit, ClientsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ClientsStatus.failure) {
              final resolvedMsg = _resolveClientErrorMessage(
                context,
                state.errorMessage,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    resolvedMsg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ClientsStatus.loading &&
                state.clients.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              );
            }

            if (state.clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off,
                      size: 80,
                      color: Colors.blue.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.clientEmptyList,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              );
            }

            final filteredClients = state.clients.where((client) {
              if (_searchQuery.isEmpty) return true;

              final searchLower = _searchQuery.toLowerCase();
              final idShort = client.id.split('-').first.toLowerCase();

              return client.name.toLowerCase().contains(searchLower) ||
                  client.phone.contains(searchLower) ||
                  (client.nationalId?.contains(searchLower) ?? false) ||
                  idShort.contains(searchLower);
            }).toList();

            return Column(
              children: [
                ClientSearchBar(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  filteredCount: filteredClients.length,
                ),
                Expanded(
                  child: filteredClients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.clientNoSearchHits,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClientTable(
                          filteredClients: filteredClients,
                          canEdit: canEdit,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
