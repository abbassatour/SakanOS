// lib/payments/widgets/payments_data_table.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/core/utils/deposit_pdf_generator.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/core/utils/pdf_preview_page.dart';
import 'package:our_home_erp_app/core/utils/refund_pdf_generator.dart';
import 'package:our_home_erp_app/core/utils/whatsapp_helper.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/widgets.dart';

class PaymentsDataTable extends StatelessWidget {
  const PaymentsDataTable({
    required this.state,
    required this.canEdit,
    required this.canDelete,
    super.key,
  });

  final PaymentsState state;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Colors.deepOrange.shade50,
                ),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 75,
                columns: [
                  DataColumn(
                    label: Text(
                      l10n.paymentColReceipt,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColBaseMeter,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColRatioEffect,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColMeters,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColProgress,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColUpdated,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n.paymentColActions,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
                rows: state.ledgerEntries.asMap().entries.map((mapEntry) {
                  final index = mapEntry.key;
                  final entry = mapEntry.value;
                  final isLatestEntry = index == 0;
                  final isRefund = entry.amountPaid < 0;
                  final minutesPassed = DateTime.now()
                      .toUtc()
                      .difference(entry.createdAt)
                      .inMinutes;
                  final isGracePeriod = minutesPassed <= 5;

                  final double feesValue = entry.fees;
                  final bool hasFees = feesValue != 0;
                  final bool isPenalty = feesValue < 0;

                  final double effectiveMeterPrice = entry.convertedMeters != 0
                      ? (entry.amountPaid.abs() / entry.convertedMeters.abs())
                      : entry.meterPriceAtPayment;

                  final contractIdx = state.contracts.indexWhere(
                    (c) => c.id == entry.contractId,
                  );
                  final contract = contractIdx >= 0
                      ? state.contracts[contractIdx]
                      : state.contracts.first;

                  final isAllocated = contract.contractType == 'متخصص';
                  final double percentage =
                      (isAllocated && contract.totalArea > 0)
                      ? (entry.convertedMeters.abs() / contract.totalArea) * 100
                      : 0.0;

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (index.isEven) {
                          return Colors.grey.withValues(alpha: 0.03);
                        }
                        return null;
                      },
                    ),
                    cells: [
                      DataCell(
                        Text(
                          entry.receiptNumber != null
                              ? entry.receiptNumber.toString()
                              : entry.id.split('-').first.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRefund
                                  ? Icons.remove_circle_outline
                                  : Icons.add_circle_outline,
                              color: isRefund ? Colors.red : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${NumberFormatters.formatWithCommas(
                                entry.amountPaid.abs(),
                              )} ل.س',
                              style: TextStyle(
                                color: isRefund ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          NumberFormatters.formatWithCommas(
                            entry.meterPriceAtPayment,
                          ),
                          style: TextStyle(
                            color: hasFees
                                ? Colors.grey.shade600
                                : Colors.black87,
                            decoration: hasFees
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        hasFees
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPenalty
                                          ? Colors.red.shade50
                                          : Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isPenalty
                                            ? Colors.red.shade200
                                            : Colors.teal.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isPenalty
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          size: 14,
                                          color: isPenalty
                                              ? Colors.red.shade700
                                              : Colors.teal.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${isPenalty ? "" : "+"}${feesValue.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isPenalty
                                                ? Colors.red.shade700
                                                : Colors.teal.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.paymentCellActualPrice(
                                      NumberFormatters.formatWithCommas(
                                        effectiveMeterPrice,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isPenalty
                                          ? Colors.red.shade900
                                          : Colors.teal.shade900,
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isRefund
                                ? Colors.red.shade50
                                : Colors.deepOrange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isRefund
                                  ? Colors.red.shade100
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            '${isRefund ? "-" : "+"}'
                            '${entry.convertedMeters.abs().toStringAsFixed(3)} '
                            'م²',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isRefund
                                  ? Colors.red.shade700
                                  : Colors.deepOrange.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        isAllocated
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${isRefund ? "-" : "+"}%${percentage.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isRefund
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey.shade200,
                                        color: isRefund
                                            ? Colors.red.shade400
                                            : Colors.green.shade500,
                                        minHeight: 5,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.paymentCellInvestmentShares,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      DataCell(
                        Text(
                          '${entry.paymentDate.year}/'
                          '${entry.paymentDate.month}/'
                          '${entry.paymentDate.day}',
                          style: const TextStyle(color: Colors.black87),
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
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.userNamesMap[entry.userId] ??
                                      l10n.clientUnknownUser,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.updatedAt.year}/'
                                  '${entry.updatedAt.month.toString().padLeft(2, '0')}/'
                                  '${entry.updatedAt.day.toString().padLeft(2, '0')} '
                                  '${entry.updatedAt.hour}:'
                                  '${entry.updatedAt.minute.toString().padLeft(2, '0')}',
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
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print, color: Colors.blue),
                              tooltip: l10n.paymentActionPrintTooltip,
                              onPressed: () async {
                                final contractIdx = state.contracts.indexWhere(
                                  (c) => c.id == entry.contractId,
                                );
                                if (contractIdx == -1) return;
                                final contract = state.contracts[contractIdx];

                                final clientIdx = state.clients.indexWhere(
                                  (c) => c.id == contract.clientId,
                                );
                                if (clientIdx == -1) return;
                                final client = state.clients[clientIdx];

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.paymentActionPrintLoading,
                                    ),
                                  ),
                                );

                                final isRefundCall = entry.amountPaid < 0;
                                final pdfBytes = await () async {
                                  if (!isRefundCall) {
                                    final bonusPct = entry.fees;
                                    double? originalInst;
                                    double? meterPriceBonus;

                                    if (bonusPct != 0) {
                                      originalInst =
                                          entry.amountPaid +
                                          (entry.amountPaid *
                                              (bonusPct.abs() / 100));
                                      meterPriceBonus =
                                          entry.amountPaid /
                                          entry.convertedMeters;
                                    }
                                    return DepositPdfGenerator.generate(
                                      entry: entry,
                                      contract: contract,
                                      client: client,
                                      originalInstallment: originalInst,
                                      bonusPercentage: bonusPct != 0
                                          ? bonusPct
                                          : null,
                                      meterPriceAfterBonus: meterPriceBonus,
                                    );
                                  } else {
                                    final penaltyPct = entry.fees;
                                    double? meterPricePenalty;

                                    if (penaltyPct != 0) {
                                      meterPricePenalty =
                                          entry.amountPaid.abs() /
                                          entry.convertedMeters.abs();
                                    }
                                    return RefundPdfGenerator.generate(
                                      entry: entry,
                                      contract: contract,
                                      client: client,
                                      penaltyPercentage: penaltyPct != 0
                                          ? penaltyPct
                                          : null,
                                      meterPriceAfterPenalty: meterPricePenalty,
                                    );
                                  }
                                }();

                                if (context.mounted) {
                                  final titleStr = isRefundCall
                                      ? 'سند_استرداد_${client.name}'
                                      : 'إيصال_دفع_${client.name}';
                                  unawaited(
                                    Navigator.push<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => PdfPreviewPage(
                                          pdfBytes: pdfBytes,
                                          title: titleStr,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: entry.isWhatsAppSent
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                              tooltip: entry.isWhatsAppSent
                                  ? l10n.paymentActionWhatsappSent
                                  : l10n.paymentActionWhatsappSend,
                              onPressed: () async {
                                final cIdx = state.contracts.indexWhere(
                                  (c) => c.id == entry.contractId,
                                );
                                if (cIdx == -1) return;
                                final contract = state.contracts[cIdx];

                                final clIdx = state.clients.indexWhere(
                                  (c) => c.id == contract.clientId,
                                );
                                if (clIdx == -1) return;
                                final client = state.clients[clIdx];

                                final success =
                                    await WhatsAppHelper.sendReceiptMessage(
                                      entry: entry,
                                      contract: contract,
                                      client: client,
                                    );

                                if (context.mounted && success) {
                                  unawaited(
                                    context.read<PaymentsCubit>().markAsSent(
                                      entry.id,
                                      contract.id,
                                    ),
                                  );
                                }
                              },
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: canEdit
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                              ),
                              tooltip: canEdit
                                  ? l10n.paymentActionEditTooltip
                                  : l10n.paymentActionEditNoPerm,
                              onPressed: canEdit
                                  ? () => showEditPaymentDialog(context, entry)
                                  : null,
                            ),
                            if (canDelete)
                              IconButton(
                                icon: Icon(
                                  isLatestEntry
                                      ? (isGracePeriod
                                            ? Icons.delete_forever
                                            : Icons.autorenew)
                                      : Icons.delete_forever,
                                  color: isLatestEntry
                                      ? (isGracePeriod
                                            ? Colors.red
                                            : Colors.orange.shade800)
                                      : Colors.grey.shade300,
                                ),
                                tooltip: isLatestEntry
                                    ? (isGracePeriod
                                          ? l10n.paymentActionDeleteGraceTooltip(
                                              5 - minutesPassed,
                                            )
                                          : l10n.paymentActionDeleteReverseTooltip)
                                    : l10n.paymentActionDeleteNoPerm,
                                onPressed: isLatestEntry
                                    ? () => showDeletePaymentDialog(
                                        context,
                                        entry,
                                      )
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
