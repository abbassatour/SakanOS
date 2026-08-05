// lib/payments/widgets/payments_top_bar.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building;

import 'package:our_home_erp_app/core/utils/allocated_ledger_pdf.dart';
import 'package:our_home_erp_app/core/utils/excel_export_helper.dart';
import 'package:our_home_erp_app/core/utils/pdf_preview_page.dart';
import 'package:our_home_erp_app/core/utils/unallocated_ledger_pdf.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/widgets.dart';

class PaymentsTopBar extends StatelessWidget {
  const PaymentsTopBar({
    required this.state,
    required this.canAdd,
    super.key,
  });

  final PaymentsState state;
  final bool canAdd;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _exportExcel(BuildContext context) async {
    final l10n = context.l10n;
    if (state.ledgerEntries.isEmpty) {
      _showError(context, l10n.paymentEmptyNoPayments);
      return;
    }
    _showInfo(context, 'جاري تجهيز ملف الإكسل...');

    final contract = state.contracts.firstWhere(
      (c) => c.id == state.selectedContractId,
    );
    final client = state.clients.firstWhere((c) => c.id == contract.clientId);

    final filePath = await ExcelExportHelper.exportLedgerToExcel(
      ledgerEntries: state.ledgerEntries,
      contract: contract,
      client: client,
    );

    if (context.mounted) {
      if (filePath != null) {
        _showSuccess(context, l10n.paymentTopBarExcelSuccess(filePath));
      } else {
        _showError(context, l10n.paymentTopBarExcelError);
      }
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    final l10n = context.l10n;
    if (state.ledgerEntries.isEmpty) {
      _showError(context, l10n.paymentEmptyNoPayments);
      return;
    }

    _showInfo(context, 'جاري تجهيز كشف الحساب (PDF)...');

    final contract = state.contracts.firstWhere(
      (c) => c.id == state.selectedContractId,
    );
    final client = state.clients.firstWhere((c) => c.id == contract.clientId);

    Apartment? selectedApartment;
    Building? selectedBuilding;

    if (contract.apartmentId != null) {
      final aptIndex = state.apartments.indexWhere(
        (a) => a.id == contract.apartmentId,
      );
      if (aptIndex != -1) {
        selectedApartment = state.apartments[aptIndex];
        final bldIndex = state.buildings.indexWhere(
          (b) => b.id == selectedApartment!.buildingId,
        );
        if (bldIndex != -1) {
          selectedBuilding = state.buildings[bldIndex];
        }
      }
    }

    final isAllocated = contract.contractType == 'متخصص';
    final pdfBytes = await () async {
      if (isAllocated) {
        if (selectedApartment == null || selectedBuilding == null) {
          return null;
        }
        return AllocatedLedgerPdf.generatePdf(
          ledgerEntries: state.ledgerEntries,
          contract: contract,
          client: client,
          apartment: selectedApartment,
          building: selectedBuilding,
        );
      } else {
        return UnallocatedLedgerPdf.generatePdf(
          ledgerEntries: state.ledgerEntries,
          contract: contract,
          client: client,
        );
      }
    }();

    if (pdfBytes == null) {
      if (context.mounted) {
        _showError(context, l10n.paymentTopBarPdfError);
      }
      return;
    }

    if (context.mounted) {
      unawaited(
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PdfPreviewPage(
              pdfBytes: pdfBytes,
              title: 'كشف_حساب_${client.name}',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.deepOrange.shade50, width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.deepOrange.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    hintText: l10n.paymentTopBarSearchHint,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.deepOrange.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                    initialSelection:
                        state.contracts.any(
                          (c) => c.id == state.selectedContractId,
                        )
                        ? state.selectedContractId
                        : null,
                    onSelected: (val) {
                      if (val != null) {
                        unawaited(
                          context.read<PaymentsCubit>().selectContract(val),
                        );
                      }
                    },
                    dropdownMenuEntries: state.contracts.map((contract) {
                      final clientIdx = state.clients.indexWhere(
                        (c) => c.id == contract.clientId,
                      );
                      final clientName = clientIdx >= 0
                          ? state.clients[clientIdx].name
                          : 'مجهول';
                      return DropdownMenuEntry<String>(
                        value: contract.id,
                        label: '$clientName (${contract.apartmentDetails})',
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          if (state.selectedContractId != null) ...[
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => unawaited(_exportExcel(context)),
                icon: const Icon(Icons.table_view, size: 20),
                label: Text(
                  l10n.paymentTopBarExcelBtn,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => unawaited(_exportPdf(context)),
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: Text(
                  l10n.paymentTopBarPdfBtn,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: canAdd
                  ? l10n.paymentTopBarAddTooltip
                  : l10n.paymentTopBarAddNoPerm,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: canAdd
                      ? () => showAddPaymentDialog(
                          context,
                          state.selectedContractId!,
                        )
                      : null,
                  icon: const Icon(Icons.add_card, size: 20),
                  label: Text(
                    l10n.paymentTopBarAddBtn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAdd
                        ? Colors.deepOrange.shade600
                        : Colors.grey.shade300,
                    foregroundColor: canAdd
                        ? Colors.white
                        : Colors.grey.shade600,
                    elevation: canAdd ? 2 : 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
