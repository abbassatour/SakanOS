// lib/contracts/view/contracts_view.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/view/add_contract_page.dart';
import 'package:our_home_erp_app/contracts/widgets/widgets.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/settings/cubit/settings_cubit.dart';

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  String _searchQuery = '';
  String _statusFilter = 'active';
  String _typeFilter = 'all';
  String _handoverFilter = 'all';

  String _getStatusName(BuildContext context, String f) {
    final l10n = context.l10n;
    if (f == 'active') return l10n.contractStatusActiveName;
    if (f == 'completed') return l10n.contractStatusCompletedName;
    return l10n.contractStatusAllName;
  }

  String _getTypeName(BuildContext context, String f) {
    final l10n = context.l10n;
    if (f == 'allocated') return l10n.contractTypeAllocatedName;
    if (f == 'unallocated') return l10n.contractTypeUnallocatedName;
    return l10n.contractTypeAllName;
  }

  String _getHandoverName(BuildContext context, String f) {
    final l10n = context.l10n;
    if (f == 'delivered') return l10n.contractHandoverDeliveredName;
    if (f == 'pending') return l10n.contractHandoverPendingName;
    return l10n.contractHandoverAllName;
  }

  String _resolveContractErrorMessage(BuildContext context, String? errorKey) {
    final l10n = context.l10n;
    if (errorKey == null) return l10n.homeUnexpectedError;

    if (errorKey.startsWith('contractErrorUpdate:')) {
      final err = errorKey.replaceFirst('contractErrorUpdate:', '');
      return l10n.contractErrorUpdate(err);
    }
    if (errorKey.startsWith('contractErrorHandover:')) {
      final err = errorKey.replaceFirst('contractErrorHandover:', '');
      return l10n.contractErrorHandover(err);
    }
    if (errorKey.startsWith('contractErrorCancelHandover:')) {
      final err = errorKey.replaceFirst('contractErrorCancelHandover:', '');
      return l10n.contractErrorCancelHandover(err);
    }
    if (errorKey.startsWith('contractErrorToggleCompletion:')) {
      final err = errorKey.replaceFirst('contractErrorToggleCompletion:', '');
      return l10n.contractErrorToggleCompletion(err);
    }
    if (errorKey.startsWith('contractErrorAttachFile:')) {
      final err = errorKey.replaceFirst('contractErrorAttachFile:', '');
      return l10n.contractErrorAttachFile(err);
    }
    if (errorKey.startsWith('contractErrorDeleteAttach:')) {
      final err = errorKey.replaceFirst('contractErrorDeleteAttach:', '');
      return l10n.contractErrorDeleteAttach(err);
    }
    if (errorKey.startsWith('contractErrorSecureUrl:')) {
      final err = errorKey.replaceFirst('contractErrorSecureUrl:', '');
      return l10n.contractErrorSecureUrl(err);
    }

    return errorKey;
  }

  void _showFilterSheet() {
    unawaited(
      () async {
        final result = await showFilterBottomSheet(
          context: context,
          currentStatus: _statusFilter,
          currentType: _typeFilter,
          currentHandover: _handoverFilter,
        );

        if (result != null && mounted) {
          setState(() {
            _statusFilter = result.status;
            _typeFilter = result.type;
            _handoverFilter = result.handover;
          });
        }
      }(),
    );
  }

  void _navigateToAddContract() {
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<ContractsCubit>()),
              BlocProvider.value(value: context.read<BuildingsCubit>()),
              BlocProvider.value(value: context.read<SettingsCubit>()),
            ],
            child: const AddContractPage(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canCreate = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.hasPermission(AppPermissions.createContracts),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: canCreate ? _navigateToAddContract : null,
        icon: const Icon(Icons.add_home_work),
        label: Text(
          l10n.contractFabAdd,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: canCreate
            ? Colors.teal.shade600
            : Colors.grey.shade300,
        foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
        elevation: canCreate ? 6 : 0,
        tooltip: canCreate
            ? l10n.contractFabTooltip
            : l10n.contractFabNoPermission,
      ),
      body: SafeArea(
        child: BlocListener<ContractsCubit, ContractsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ContractsStatus.failure) {
              final resolvedMsg = _resolveContractErrorMessage(
                context,
                state.errorMessage,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resolvedMsg),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<ContractsCubit, ContractsState>(
            builder: (context, state) {
              if (state.status == ContractsStatus.loading &&
                  state.contracts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              if (state.clients.isEmpty) {
                return EmptyContractsView(
                  message: l10n.contractNoClients,
                  icon: Icons.group_add,
                  iconColor: Colors.grey,
                );
              }

              if (state.contracts.isEmpty) {
                return EmptyContractsView(
                  message: l10n.contractEmptyList,
                  icon: Icons.real_estate_agent,
                  iconColor: Colors.teal,
                );
              }

              final filteredContracts = state.contracts.where((contract) {
                final passStatus =
                    _statusFilter == 'all' ||
                    (_statusFilter == 'active' && !contract.isCompleted) ||
                    (_statusFilter == 'completed' && contract.isCompleted);

                final passType =
                    _typeFilter == 'all' ||
                    (_typeFilter == 'allocated' &&
                        contract.contractType == 'متخصص') ||
                    (_typeFilter == 'unallocated' &&
                        contract.contractType == 'لاحق التخصص');

                final passHandover =
                    _handoverFilter == 'all' ||
                    (_handoverFilter == 'delivered' && contract.isHandedOver) ||
                    (_handoverFilter == 'pending' && !contract.isHandedOver);

                var passSearch = true;
                if (_searchQuery.isNotEmpty) {
                  final clientIdx = state.clients.indexWhere(
                    (c) => c.id == contract.clientId,
                  );
                  final clientName = clientIdx >= 0
                      ? state.clients[clientIdx].name.toLowerCase()
                      : '';

                  final searchLower = _searchQuery.toLowerCase();
                  passSearch =
                      clientName.contains(searchLower) ||
                      contract.apartmentDetails.toLowerCase().contains(
                        searchLower,
                      ) ||
                      contract.id.contains(searchLower);
                }

                return passStatus && passType && passHandover && passSearch;
              }).toList();

              final hasActiveFilters =
                  _statusFilter != 'all' ||
                  _typeFilter != 'all' ||
                  _handoverFilter != 'all';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContractsSearchBar(
                    searchQuery: _searchQuery,
                    resultCount: filteredContracts.length,
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      border: Border.all(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.teal, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasActiveFilters
                                    ? l10n.contractFilterActiveLabel
                                    : l10n.contractFilterAllLabel,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (hasActiveFilters)
                                Text(
                                  '${_getStatusName(context, _statusFilter)} | '
                                  '${_getTypeName(context, _typeFilter)} | '
                                  '${_getHandoverName(context, _handoverFilter)}',
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _showFilterSheet,
                          icon: const Icon(Icons.filter_alt, size: 18),
                          label: Text(
                            l10n.contractFilterBtn,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: l10n.contractFilterClearTooltip,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                            ),
                            onPressed: () {
                              setState(() {
                                _statusFilter = 'all';
                                _typeFilter = 'all';
                                _handoverFilter = 'all';
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredContracts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.contractNoHits,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ).copyWith(bottom: 80),
                            children: [
                              ContractsDataTable(
                                contracts: filteredContracts,
                                clients: state.clients,
                                userNamesMap: state.userNamesMap,
                                attachmentsMap: state.attachmentsMap,
                              ),
                            ],
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
