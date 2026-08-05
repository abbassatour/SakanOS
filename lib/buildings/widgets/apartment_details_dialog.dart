// lib/buildings/widgets/apartment_details_dialog.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;
import 'package:our_home_erp_app/l10n/l10n.dart';

void showApartmentDetailsDialog(BuildContext context, Apartment apt) {
  unawaited(
    showDialog<void>(
      context: context,
      builder: (ctx) => _ApartmentDetailsDialogContent(apt: apt),
    ),
  );
}

class _ApartmentDetailsDialogContent extends StatelessWidget {
  const _ApartmentDetailsDialogContent({required this.apt});

  final Apartment apt;

  String _getLocalizedKey(BuildContext context, String key) {
    final l10n = context.l10n;
    switch (key) {
      case 'مساحة البلاطة (م2)':
        return l10n.coeffSlabArea;
      case 'مساحة التراس (م2)':
        return l10n.coeffTerraceArea;
      case 'مساحة الوجيبة (م2)':
        return l10n.coeffYardArea;
      case 'عرض الواجهة الفعلي (متر)':
        return l10n.coeffFacadeLength;
      case 'معامل التميز للوجيبة':
        return l10n.coeffYardExcellence;
      case 'هامش الربح':
        return l10n.coeffProfitMargin;
      case 'تميز الواجهة':
        return l10n.coeffFacadeExcellence;
      case 'الموقع':
        return l10n.coeffLocation;
      case 'الشارع':
        return l10n.coeffStreet;
      default:
        return key;
    }
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

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade600, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final physicalAreas = <String, dynamic>{};
    final financialCoeffs = <String, dynamic>{};

    try {
      final allData =
          jsonDecode(apt.customCoefficients) as Map<String, dynamic>;

      allData.forEach((key, value) {
        if (key.startsWith('مساحة') ||
            key.startsWith('عرض') ||
            key.toLowerCase().contains('area') ||
            key.toLowerCase().contains('width')) {
          physicalAreas[key] = value;
        } else {
          financialCoeffs[key] = value;
        }
      });
    } on Exception catch (e) {
      // ignore: avoid_print
      print('Error decoding: $e');
    }

    final isAvailable = apt.status == 'available';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.indigo.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.aptDetailsDialogTitle(apt.apartmentNumber),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAvailable
                    ? Colors.green.shade200
                    : Colors.red.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.lock,
                  size: 16,
                  color: isAvailable
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  isAvailable
                      ? l10n.aptStatusAvailableTag
                      : l10n.aptStatusSoldTag,
                  style: TextStyle(
                    color: isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.shade50.withOpacity(0.5)
                      : Colors.red.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAvailable
                      ? l10n.aptStatusAvailableDesc
                      : l10n.aptStatusSoldDesc,
                  style: TextStyle(
                    color: isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      l10n.aptFloorHeader,
                      apt.floorName,
                      Icons.layers,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      l10n.aptDirectionHeader,
                      _getLocalizedDirection(context, apt.directionName),
                      Icons.explore,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.architecture, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aptEngineeringHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.aptSalesAreaTitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${apt.area} m²',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (physicalAreas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.aptInputDataHeader,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...physicalAreas.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getLocalizedKey(context, e.key),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                e.value.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.percent, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aptFinancialCoeffsHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (financialCoeffs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            l10n.aptNoFinancialCoeffs,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: financialCoeffs.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getLocalizedKey(context, e.key),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${e.value}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.btnCloseDetails,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
