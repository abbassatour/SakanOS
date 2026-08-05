// lib/recycle_bin/view/recycle_bin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../cubit/recycle_bin_cubit.dart';
import 'dialogs/verify_hard_delete_dialog.dart';

String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecycleBinCubit(context.read<ErpRepository>())..loadAllDeletedData(),
      child: const RecycleBinView(),
    );
  }
}

class RecycleBinView extends StatelessWidget {
  const RecycleBinView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.watch<AuthCubit>().state;
    final bool canRestore = authState.hasPermission(
      AppPermissions.restoreItems,
    );
    final bool canHardDelete = authState.hasPermission(
      AppPermissions.hardDeleteItems,
    );

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.recycleBinTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.people),
                text: l10n.recycleBinTabClients,
              ),
              Tab(
                icon: const Icon(Icons.domain),
                text: l10n.recycleBinTabBuildings,
              ),
              Tab(
                icon: const Icon(Icons.door_front_door),
                text: l10n.recycleBinTabApartments,
              ),
              Tab(
                icon: const Icon(Icons.description),
                text: l10n.recycleBinTabContracts,
              ),
              Tab(
                icon: const Icon(Icons.receipt_long),
                text: l10n.recycleBinTabPayments,
              ),
            ],
          ),
        ),
        body: BlocConsumer<RecycleBinCubit, RecycleBinState>(
          listener: (context, state) {
            if (state.status == RecycleBinStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? l10n.homeUnexpectedError,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == RecycleBinStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            return TabBarView(
              children: [
                // 1. العملاء
                _buildList(
                  context: context,
                  items: state.deletedClients,
                  emptyCategory: l10n.recycleBinTabClients,
                  icon: Icons.person_off,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) =>
                      '${l10n.recycleBinClientPrefix}${item.name}',
                  getSubtitle: (item) =>
                      '${l10n.recycleBinPhonePrefix}${item.phone}${item.nationalId != null ? "${l10n.recycleBinNationalIdPrefix}${item.nationalId}" : ""}',
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? l10n.clientUnknownUser,
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreClient(item.id),
                  onHardDelete: (item) =>
                      context.read<RecycleBinCubit>().hardDeleteClient(item.id),
                ),

                // 2. المحاضر
                _buildList(
                  context: context,
                  items: state.deletedBuildings,
                  emptyCategory: l10n.recycleBinTabBuildings,
                  icon: Icons.domain_disabled,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) =>
                      '${l10n.recycleBinBuildingPrefix}${item.name}',
                  getSubtitle: (item) =>
                      '${l10n.recycleBinLocationPrefix}${item.location ?? l10n.bldUnspecified}',
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? l10n.clientUnknownUser,
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreBuilding(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteBuilding(item.id),
                ),

                // 3. الوحدات
                _buildList(
                  context: context,
                  items: state.deletedApartments,
                  emptyCategory: l10n.recycleBinTabApartments,
                  icon: Icons.do_not_disturb_alt,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => l10n.recycleBinUnitNumber(
                    item.unitType == 'shop'
                        ? l10n.recycleBinShopLabel
                        : l10n.recycleBinApartmentLabel,
                    item.apartmentNumber,
                  ),
                  getSubtitle: (item) {
                    final bldgs = state.referenceBuildings.where(
                      (b) => b.id == item.buildingId,
                    );
                    final bldgName = bldgs.isNotEmpty
                        ? bldgs.first.name
                        : l10n.bldUnspecified;
                    return '${l10n.recycleBinBuildingPrefix}$bldgName${l10n.recycleBinFloorLabel}${item.floorName}${l10n.recycleBinAreaLabel(item.area)}';
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? l10n.clientUnknownUser,
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreApartment(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteApartment(item.id),
                ),

                // 4. العقود
                _buildList(
                  context: context,
                  items: state.deletedContracts,
                  emptyCategory: l10n.recycleBinTabContracts,
                  icon: Icons.file_copy_outlined,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) =>
                      l10n.recycleBinContractPrefix(item.contractType),
                  getSubtitle: (item) {
                    final clients = state.referenceClients.where(
                      (c) => c.id == item.clientId,
                    );
                    final clientName = clients.isNotEmpty
                        ? clients.first.name
                        : l10n.contractDeletedClient;
                    return '${l10n.recycleBinClientPrefix}$clientName${l10n.recycleBinDetailsPrefix}${item.apartmentDetails}${l10n.recycleBinAreaLabel(item.totalArea)}';
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? l10n.clientUnknownUser,
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreContract(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteContract(item.id),
                ),

                // 5. المدفوعات
                _buildList(
                  context: context,
                  items: state.deletedPayments,
                  emptyCategory: l10n.recycleBinTabPayments,
                  icon: Icons.money_off,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => l10n.recycleBinReceiptPrefix(
                    formatWithCommas(item.amountPaid),
                  ),
                  getSubtitle: (item) {
                    final contracts = state.referenceContracts.where(
                      (c) => c.id == item.contractId,
                    );
                    final contract = contracts.isNotEmpty
                        ? contracts.first
                        : null;
                    if (contract != null) {
                      final clients = state.referenceClients.where(
                        (c) => c.id == contract.clientId,
                      );
                      final clientName = clients.isNotEmpty
                          ? clients.first.name
                          : l10n.contractDeletedClient;
                      return '${l10n.recycleBinClientPrefix}$clientName\n${l10n.contractDetailsContractNumber(contract.id.split('-').first.toUpperCase())}${l10n.recycleBinConvertedMetersPrefix(item.convertedMeters.toStringAsFixed(2))}';
                    }
                    return l10n.clientUnknownUser;
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? l10n.clientUnknownUser,
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restorePayment(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeletePayment(item.id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList<T>({
    required BuildContext context,
    required List<T> items,
    required String emptyCategory,
    required IconData icon,
    required bool canRestore,
    required bool canHardDelete,
    required String Function(T) getTitle,
    required String Function(T) getSubtitle,
    required String Function(T) getDeletedBy,
    required DateTime Function(T) getUpdatedAt,
    required void Function(T) onRestore,
    required void Function(T) onHardDelete,
  }) {
    final l10n = context.l10n;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.recycleBinEmptyCategory(emptyCategory),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.recycleBinAutoCleanNotice,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = getTitle(item);
        final subtitle = getSubtitle(item);
        final deletedBy = getDeletedBy(item);

        final deletionDate = getUpdatedAt(item).toLocal();
        final daysPassed = DateTime.now().difference(deletionDate).inDays;
        final daysLeft = (7 - daysPassed).clamp(0, 7);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade100, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.red.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        l10n.recycleBinDaysLeft(daysLeft),
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.recycleBinDeletedBy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                deletedBy,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${deletionDate.year}/${deletionDate.month.toString().padLeft(2, '0')}/${deletionDate.day.toString().padLeft(2, '0')} - ${deletionDate.hour}:${deletionDate.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        if (canRestore)
                          TextButton.icon(
                            icon: const Icon(Icons.restore),
                            label: Text(l10n.recycleBinRestoreBtn),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.recycleBinRestoringNotice),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                              onRestore(item);
                            },
                          ),
                        if (canHardDelete)
                          TextButton.icon(
                            icon: const Icon(Icons.delete_forever),
                            label: Text(l10n.recycleBinDestroyBtn),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () {
                              showVerifyHardDeleteDialog(
                                context: context,
                                itemName: title,
                                onConfirm: () => onHardDelete(item),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
