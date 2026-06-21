// lib/buildings/widgets/building_card.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building;

import '../cubit/buildings_cubit.dart';
import 'widgets.dart';

int _getFloorLevel(String name) {
  if (name.contains('الأرضي')) return 0;

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

  if (name.contains('القبو')) return -level;

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

  DataRow _buildDataRow(
    BuildContext context,
    Apartment apt, {
    required bool isShop,
    required Map<String, String> userNamesMap,
  }) {
    final mainColor = isShop ? Colors.orange : Colors.indigo;

    Color statusColor;
    Color statusBorderColor;
    Color statusBgColor;
    String statusText;

    if (apt.status == 'available') {
      statusText = 'متاحة';
      statusColor = Colors.green.shade700;
      statusBorderColor = Colors.green.shade200;
      statusBgColor = Colors.green.shade50;
    } else if (apt.status == 'delivered') {
      statusText = 'مُسلّمة';
      statusColor = Colors.teal.shade700;
      statusBorderColor = Colors.teal.shade200;
      statusBgColor = Colors.teal.shade50;
    } else {
      statusText = 'مباعة';
      statusColor = Colors.red.shade700;
      statusBorderColor = Colors.red.shade200;
      statusBgColor = Colors.red.shade50;
    }

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
            '${apt.area} م²',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            apt.directionName,
            style: TextStyle(color: Colors.grey.shade700),
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
                    userNamesMap[apt.userId] ?? 'مجهول',
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
                tooltip: 'تعديل الوحدة',
                onPressed: () => showEditApartmentDialog(context, apt),
              ),
              IconButton(
                icon: const Icon(
                  Icons.visibility,
                  size: 22,
                  color: Colors.indigo,
                ),
                tooltip: 'عرض التفاصيل',
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
    final allUnits = context.select<BuildingsCubit, List<Apartment>>(
      (c) => c.state.apartments
          .where((a) => a.buildingId == building.id)
          .toList(),
    );
    final userNamesMap = context.select<BuildingsCubit, Map<String, String>>(
      (c) => c.state.userNamesMap,
    );

    final bldApartments = allUnits
        .where((a) => a.unitType == 'apartment')
        .toList();
        
    final bldShops = allUnits
        .where((a) => a.unitType == 'shop')
        .toList();

    var availableFloors = <String, dynamic>{};
    try {
      availableFloors = jsonDecode(building.floorCoefficients)
          as Map<String, dynamic>;
    } on Exception catch (_) {}

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
                      '📍 ${building.location ?? 'بدون عنوان'}  |  '
                      '🚪 ${bldApartments.length} شقق  |  '
                      '🏪 ${bldShops.length} محلات',
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
                          'آخر تعديل بواسطة: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          userNamesMap[building.userId] ?? 'مجهول',
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
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.orange),
                tooltip: 'تعديل بيانات المحضر',
                onPressed: () => showEditBuildingDialog(context, building),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.teal),
                tooltip: 'عرض التفاصيل والنسب',
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
                        'لم يتم إعداد الطوابق لهذا المحضر. يرجى تعديل '
                        'المحضر أولاً.',
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
                            color: Colors.black.withValues(alpha: 0.02),
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
                                '$floorName ( ${floorApts.length} شقق )',
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
                                  'لا توجد شقق مضافة في هذا الطابق بعد.',
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
                                        Colors.indigo.shade50
                                            .withValues(alpha: 0.5),
                                      ),
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'رقم الشقة',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'المساحة',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'الاتجاه',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'الحالة',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'آخر تعديل بواسطة',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'إجراءات',
                                            style: TextStyle(
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
                                color: Colors.indigo.shade50
                                    .withValues(alpha: 0.3),
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
                                    label: const Text(
                                      'إضافة شقة هنا',
                                      style: TextStyle(
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
                                      label: const Text(
                                        'نسخ نموذج الطابق',
                                        style: TextStyle(
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
                          color: Colors.orange.shade900.withValues(alpha: 0.04),
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
                              'المحلات التجارية ( ${bldShops.length} محلات )',
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
                                'لا توجد محلات تجارية مضافة في هذا المحضر بعد.',
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
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'رقم/رمز المحل',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'المساحة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'الواجهة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'الحالة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'آخر تعديل بواسطة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'إجراءات',
                                          style: TextStyle(
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
                              color: Colors.orange.shade50
                                  .withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.add_business, size: 20),
                                label: const Text(
                                  'إضافة محل تجاري هنا',
                                  style: TextStyle(
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
