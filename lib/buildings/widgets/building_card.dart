// lib/buildings/widgets/building_card.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building, ApartmentAttachment;
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';
import 'package:our_home_erp_app/buildings/widgets/widgets.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/buildings/view/building_attachments_page.dart';
import 'package:our_home_erp_app/buildings/view/apartment_attachments_page.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

int _getFloorLevel(String name) {
  if (name.contains('الأرضي') || name.toLowerCase().contains('ground'))
    return 0;

  var level = 99;
  if (name.contains('الثاني عشر')) {
    level = 12;
  } else if (name.contains('الحادي عشر')) {
    level = 11;
  } else if (name.contains('العاشر')) {
    level = 10;
  } else if (name.contains('التاسع')) {
    level = 9;
  } else if (name.contains('الثامن')) {
    level = 8;
  } else if (name.contains('السابع')) {
    level = 7;
  } else if (name.contains('السادس')) {
    level = 6;
  } else if (name.contains('الخامس')) {
    level = 5;
  } else if (name.contains('الرابع')) {
    level = 4;
  } else if (name.contains('الثالث')) {
    level = 3;
  } else if (name.contains('الثاني')) {
    level = 2;
  } else if (name.contains('الأول')) {
    level = 1;
  } else {
    final match = RegExp(r'\d+').firstMatch(name);
    if (match != null) {
      level = int.parse(match.group(0)!);
    }
  }

  if (name.contains('القبو') || name.toLowerCase().contains('basement'))
    return -level;

  return level;
}

class BuildingCard extends StatelessWidget {
  const BuildingCard({
    required this.building,
    required this.isFirst,
    super.key,
  });

  final Building building;
  final bool isFirst;

  BoxDecoration _tableDecoration(Color borderColor) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }

  String _getLocalizedDirection(BuildContext context, String direction) {
    final l10n = context.l10n;
    return direction
        .replaceAll('شمالي', l10n.coeffNorth)
        .replaceAll('جنوبي', l10n.coeffSouth)
        .replaceAll('شرقي', l10n.coeffEast)
        .replaceAll('غربي', l10n.coeffWest)
        .replaceAll('واجهة تجارية', l10n.coeffCommercialFacade);
  }

  DataRow _buildDataRow(
    BuildContext context,
    Apartment apt, {
    required bool isShop,
    required Map<String, String> userNamesMap,
    required Map<String, List<ApartmentAttachment>> attachmentsMap,
    required bool canManage,
  }) {
    final l10n = context.l10n;
    final mainColor = isShop ? Colors.orange : Colors.indigo;

    Color statusColor;
    Color statusBorderColor;
    Color statusBgColor;
    String statusText;

    if (apt.status == 'available') {
      statusText = l10n.bldStatusAvailable;
      statusColor = Colors.green.shade700;
      statusBorderColor = Colors.green.shade200;
      statusBgColor = Colors.green.shade50;
    } else if (apt.status == 'delivered') {
      statusText = l10n.bldStatusDelivered;
      statusColor = Colors.teal.shade700;
      statusBorderColor = Colors.teal.shade200;
      statusBgColor = Colors.teal.shade50;
    } else {
      statusText = l10n.bldStatusSold;
      statusColor = Colors.red.shade700;
      statusBorderColor = Colors.red.shade200;
      statusBgColor = Colors.red.shade50;
    }

    final attachmentsCount = attachmentsMap[apt.id]?.length ?? 0;

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isShop ? Icons.store : Icons.door_front_door_outlined,
                size: 18,
                color: mainColor.shade300,
              ),
              const SizedBox(width: 8),
              Text(
                apt.apartmentNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: mainColor.shade700,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '${apt.area} m²',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            _getLocalizedDirection(context, apt.directionName),
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                ApartmentAttachmentsPage.route(
                  apt,
                  canManage,
                  context.read<BuildingsCubit>(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: attachmentsCount > 0
                    ? mainColor.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: attachmentsCount > 0
                      ? mainColor.shade300
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: attachmentsCount > 0
                        ? mainColor.shade700
                        : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$attachmentsCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: attachmentsCount > 0
                          ? mainColor.shade700
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusBorderColor),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 13,
                    color: mainColor.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userNamesMap[apt.userId] ?? l10n.bldUnknownUser,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: mainColor.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 11, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${apt.updatedAt.year}/'
                    '${apt.updatedAt.month.toString().padLeft(2, '0')}/'
                    '${apt.updatedAt.day.toString().padLeft(2, '0')} '
                    '${apt.updatedAt.hour}:'
                    '${apt.updatedAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_note,
                  size: 22,
                  color: Colors.orange,
                ),
                tooltip: l10n.bldEditUnitTooltip,
                onPressed: () => showEditApartmentDialog(context, apt),
              ),
              IconButton(
                icon: const Icon(
                  Icons.visibility,
                  size: 22,
                  color: Colors.indigo,
                ),
                tooltip: l10n.bldViewUnitTooltip,
                onPressed: () => showApartmentDetailsDialog(context, apt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final canManage = context.select<AuthCubit, bool>(
      (c) => c.state.hasPermission(AppPermissions.manageBuildings),
    );

    final allUnits = context.select<BuildingsCubit, List<Apartment>>(
      (c) =>
          c.state.apartments.where((a) => a.buildingId == building.id).toList(),
    );
    final userNamesMap = context.select<BuildingsCubit, Map<String, String>>(
      (c) => c.state.userNamesMap,
    );

    final attachmentsMap = context
        .select<BuildingsCubit, Map<String, List<ApartmentAttachment>>>(
          (c) => c.state.apartmentAttachmentsMap,
        );

    final bldApartments = allUnits
        .where((a) => a.unitType == 'apartment')
        .toList();

    final bldShops = allUnits.where((a) => a.unitType == 'shop').toList();

    var availableFloors = <String, dynamic>{};
    try {
      availableFloors =
          jsonDecode(building.floorCoefficients) as Map<String, dynamic>;
    } catch (_) {}

    final sortedFloorNames = availableFloors.keys.toList()
      ..sort((a, b) => _getFloorLevel(a).compareTo(_getFloorLevel(b)));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.indigo.shade50, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isFirst,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.indigo.shade600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${building.location ?? l10n.bldNoAddress}  |  '
                      '🚪 ${l10n.bldApartmentsCount(bldApartments.length)}  |  '
                      '🏪 ${l10n.bldShopsCount(bldShops.length)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_calendar,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.bldLastUpdatedBy,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          userNamesMap[building.userId] ?? l10n.bldUnknownUser,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${building.updatedAt.year}/'
                          '${building.updatedAt.month}/'
                          '${building.updatedAt.day})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.perm_media,
                      color: Colors.blueAccent,
                    ),
                    tooltip: l10n.bldGalleryTooltip,
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      final canManage = authState.hasPermission(
                        AppPermissions.manageBuildings,
                      );
                      Navigator.push(
                        context,
                        BuildingAttachmentsPage.route(
                          building,
                          canManage,
                          context.read<BuildingsCubit>(),
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final attachments = context.select<BuildingsCubit, int>(
                        (cubit) =>
                            cubit.state.attachmentsMap[building.id]?.length ??
                            0,
                      );
                      if (attachments == 0) return const SizedBox.shrink();
                      return Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$attachments',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.orange),
                tooltip: l10n.bldEditTooltip,
                onPressed: () => showEditBuildingDialog(context, building),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.teal),
                tooltip: l10n.bldDetailsTooltip,
                onPressed: () => showBuildingDetailsDialog(context, building),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
          children: [
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                children: [
                  if (sortedFloorNames.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.bldNoFloorsWarning,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ...sortedFloorNames.map((floorName) {
                    final floorApts = bldApartments
                        .where((a) => a.floorName == floorName)
                        .toList();

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.indigo.shade100,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Row(
                            children: [
                              Icon(
                                Icons.layers,
                                color: Colors.indigo.shade300,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.bldFloorAptsCount(
                                  floorName,
                                  floorApts.length,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            if (floorApts.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  l10n.bldNoAptsInFloor,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            if (floorApts.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Container(
                                  decoration: _tableDecoration(
                                    Colors.indigo.shade50,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: DataTable(
                                      headingRowHeight: 50,
                                      dataRowMinHeight: 55,
                                      dataRowMaxHeight: 65,
                                      horizontalMargin: 24,
                                      columnSpacing: 30,
                                      dividerThickness: 0.5,
                                      headingRowColor: WidgetStateProperty.all(
                                        Colors.indigo.shade50.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      columns: [
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColAptNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColArea,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColDirection,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColAttachments,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColStatus,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColUpdatedAt,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            l10n.bldColActions,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: floorApts
                                          .map(
                                            (apt) => _buildDataRow(
                                              context,
                                              apt,
                                              isShop: false,
                                              userNamesMap: userNamesMap,
                                              attachmentsMap: attachmentsMap,
                                              canManage: canManage,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50.withOpacity(
                                  0.3,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_home, size: 20),
                                    label: Text(
                                      l10n.bldAddApartmentHere,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.indigo.shade600,
                                    ),
                                    onPressed: () => showAddApartmentDialog(
                                      context,
                                      building,
                                      preSelectedFloor: floorName,
                                    ),
                                  ),
                                  if (floorApts.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.copy_all,
                                        size: 20,
                                      ),
                                      label: Text(
                                        l10n.bldCopyFloorModel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.orange.shade700,
                                      ),
                                      onPressed: () => showCopyFloorDialog(
                                        context,
                                        building,
                                        floorName,
                                        floorApts,
                                        availableFloors.keys.toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade900.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: bldShops.isNotEmpty,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.storefront,
                              color: Colors.orange.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.bldShopsHeader(bldShops.length),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          if (bldShops.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.bldNoShopsWarning,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          if (bldShops.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Container(
                                decoration: _tableDecoration(
                                  Colors.orange.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: DataTable(
                                    headingRowHeight: 50,
                                    dataRowMinHeight: 55,
                                    dataRowMaxHeight: 65,
                                    horizontalMargin: 24,
                                    columnSpacing: 30,
                                    dividerThickness: 0.5,
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.orange.shade50,
                                    ),
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColShopNumber,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColArea,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColFacade,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColAttachments,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColStatus,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColUpdatedAt,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.bldColActions,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: bldShops
                                        .map(
                                          (shop) => _buildDataRow(
                                            context,
                                            shop,
                                            isShop: true,
                                            userNamesMap: userNamesMap,
                                            attachmentsMap: attachmentsMap,
                                            canManage: canManage,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50.withOpacity(
                                0.5,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.add_business, size: 20),
                                label: Text(
                                  l10n.bldAddShopHere,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange.shade800,
                                ),
                                onPressed: () => showAddShopDialog(
                                  context,
                                  building,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
