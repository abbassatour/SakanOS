// lib/profile/view/contract_details_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client, Contract;
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../cubit/client_profile_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';
import '../../legal/cubit/legal_affairs_cubit.dart';
import '../../legal/view/legal_attachments_page.dart';
import '../../contracts/cubit/contracts_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';

import '../../core/utils/handover_pledge_pdf_helper.dart';
import '../../core/utils/pdf_preview_page.dart';
import '../../contracts/widgets/dialogs/verify_pin_dialog.dart';

String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

String _formatDateSafely(DateTime? date) {
  if (date == null) return 'غير محدد';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

class ContractDetailsPage extends StatelessWidget {
  final Contract contract;
  final Client client;
  final ContractProfileSummary? summary;

  const ContractDetailsPage({
    super.key,
    required this.contract,
    required this.client,
    this.summary,
  });

  void _showHandoverDialog(
    BuildContext parentContext,
    Contract currentContract,
    Client client,
  ) {
    final l10n = parentContext.l10n;
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.vpn_key, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  l10n.contractHandoverDialogTitle,
                  style: const TextStyle(color: Colors.teal),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.teal,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.contractHandoverDialogInfo,
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.contractHandoverActualDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.edit_calendar,
                          color: Colors.teal,
                        ),
                        label: Text(
                          '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: dialogCtx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2050),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.contractHandoverNotesHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(l10n.btnCancel),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check),
                label: Text(l10n.contractHandoverConfirmBtn),
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  final isAuth = await showVerifyPinDialog(parentContext);

                  if (isAuth && parentContext.mounted) {
                    await parentContext
                        .read<ContractsCubit>()
                        .markContractAsHandedOver(
                          contractId: currentContract.id,
                          actualHandoverDate: selectedDate,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );

                    if (!parentContext.mounted) return;

                    parentContext.read<ClientProfileCubit>().fetchClientData(
                      client,
                    );

                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.contractHandoverSuccess),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancelHandover(
    BuildContext context,
    Contract currentContract,
    Client client,
  ) async {
    final l10n = context.l10n;
    final isAuth = await showVerifyPinDialog(context);
    if (isAuth && context.mounted) {
      await context.read<ContractsCubit>().cancelContractHandover(
        contractId: currentContract.id,
      );

      if (!context.mounted) return;

      context.read<ClientProfileCubit>().fetchClientData(client);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contractHandoverCancelSuccess),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _printHandoverPdf(
    BuildContext context,
    Contract currentContract,
    Client client,
  ) async {
    final l10n = context.l10n;
    final buildingsState = context.read<BuildingsCubit>().state;

    final apartment = buildingsState.apartments
        .where((a) => a.id == currentContract.apartmentId)
        .firstOrNull;
    if (apartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contractHandoverAptMissing),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final building = buildingsState.buildings
        .where((b) => b.id == apartment.buildingId)
        .firstOrNull;
    if (building == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contractHandoverBldMissing),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.contractHandoverPdfGenerating),
        backgroundColor: Colors.teal,
      ),
    );

    final pdfBytes = await HandoverPledgePdfHelper.generatePdf(
      contract: currentContract,
      client: client,
      apartment: apartment,
      building: building,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewPage(
            pdfBytes: pdfBytes,
            title: 'محضر_استلام_${client.name}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocBuilder<ClientProfileCubit, ClientProfileState>(
          builder: (context, state) {
            ContractProfileSummary? currentSummary;
            try {
              currentSummary = state.contractsSummary.firstWhere(
                (s) => s.contract.id == contract.id,
              );
            } catch (_) {
              currentSummary = summary;
            }

            final currentContract = currentSummary?.contract ?? contract;

            final bool isAllocated = currentContract.contractType == 'متخصص';
            final Color mainColor = isAllocated
                ? Colors.amber.shade700
                : Colors.blue.shade700;
            final Color bgColor = isAllocated
                ? Colors.amber.shade50
                : Colors.blue.shade50;

            Map<String, dynamic> coefficientsMap = {};
            if (currentContract.coefficients.isNotEmpty &&
                currentContract.coefficients != '{}') {
              try {
                coefficientsMap =
                    jsonDecode(currentContract.coefficients)
                        as Map<String, dynamic>;
              } catch (_) {}
            }

            final bool isPenaltyActive =
                currentContract.isPenaltyActive ?? false;
            final double penaltyPct = currentContract.penaltyPercentage ?? 0.0;
            final int penaltyInterval =
                currentContract.penaltyIntervalMonths ?? 1;

            return Center(
              child: SizedBox(
                width: 700,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 220,
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  mainColor,
                                  if (isAllocated)
                                    Colors.amber.shade900
                                  else
                                    Colors.blue.shade900,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    Expanded(
                                      child: Text(
                                        l10n.contractDetailsTitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isAllocated
                                                ? Icons.apartment
                                                : Icons.savings,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            currentContract.contractType,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.description,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.contractDetailsClientName(
                                              client.name,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.contractDetailsContractNumber(
                                              currentContract.id
                                                  .split('-')
                                                  .first
                                                  .toUpperCase(),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            top: 160,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  _buildTopStat(
                                    l10n.contractDetailsMonthlyDue,
                                    formatWithCommas(
                                      currentContract.agreedMonthlyAmount,
                                    ),
                                    '',
                                    Icons.payments,
                                    Colors.deepOrange,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  if (isAllocated) ...[
                                    _buildTopStat(
                                      l10n.contractDetailsBaseMeterPrice,
                                      formatWithCommas(
                                        currentContract.baseMeterPriceAtSigning,
                                      ),
                                      '',
                                      Icons.price_change,
                                      Colors.teal,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                    _buildTopStat(
                                      l10n.contractDetailsTotalArea,
                                      currentContract.totalArea.toStringAsFixed(
                                        2,
                                      ),
                                      '',
                                      Icons.architecture,
                                      Colors.indigo,
                                    ),
                                  ] else ...[
                                    _buildTopStat(
                                      l10n.contractDetailsMeterPrice,
                                      l10n.contractDetailsMarketPrice,
                                      l10n.contractDetailsPayDay,
                                      Icons.trending_up,
                                      Colors.blue,
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.grey.shade200,
                                    ),
                                    _buildTopStat(
                                      l10n.contractDetailsArea,
                                      l10n.contractDetailsShares,
                                      l10n.contractDetailsUnallocated,
                                      Icons.pie_chart,
                                      Colors.indigo,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 80)),

                    if (currentContract.isCompleted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.archive_rounded,
                                      color: Colors.green.shade700,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      l10n.contractDetailsArchivedTitle,
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.contractDetailsArchivedDesc,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    height: 1.6,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.contractDetailsOperationalActions,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.account_balance_wallet,
                                    label:
                                        l10n.contractDetailsInstallmentsPageBtn,
                                    color: Colors.deepOrange.shade600,
                                    onTap: () {
                                      context
                                          .read<PaymentsCubit>()
                                          .selectContract(
                                            currentContract.id,
                                          );
                                      context.read<DashboardCubit>().changeTab(
                                        4,
                                      );
                                      Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.contractDetailsNavToInstallments,
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.radar,
                                    label: l10n.contractDetailsSchedulePageBtn,
                                    color: Colors.indigo.shade600,
                                    onTap: () {
                                      context
                                          .read<ScheduleCubit>()
                                          .selectContract(
                                            currentContract.id,
                                          );
                                      context.read<DashboardCubit>().changeTab(
                                        5,
                                      );
                                      Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.contractDetailsNavToSchedule,
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (currentContract.contractFileUrl != null &&
                                currentContract
                                    .contractFileUrl!
                                    .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  icon: Icons.attachment,
                                  label: l10n.contractDetailsViewAttachmentBtn,
                                  color: Colors.green.shade700,
                                  onTap: () async {
                                    final urlString =
                                        currentContract.contractFileUrl!;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.contractDetailsGeneratingLink,
                                        ),
                                        backgroundColor: Colors.teal,
                                      ),
                                    );

                                    final secureUrl = await context
                                        .read<ContractsCubit>()
                                        .getSecureContractUrl(urlString);

                                    if (secureUrl != null) {
                                      if (secureUrl.startsWith('http')) {
                                        final Uri url = Uri.parse(secureUrl);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.contractDetailsCannotOpenLink,
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        final result = await OpenFilex.open(
                                          secureUrl,
                                        );
                                        if (result.type != ResultType.done &&
                                            context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.contractDetailsLocalFileError(
                                                  result.message,
                                                ),
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionCard(
                          title: l10n.contractDetailsInfoTitle,
                          icon: Icons.info_outline,
                          color: mainColor,
                          bgColor: bgColor,
                          child: Column(
                            children: [
                              _buildInfoRow(
                                l10n.contractDetailsSignDate,
                                _formatDateSafely(currentContract.contractDate),
                                Icons.calendar_month,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                l10n.contractDetailsDuration,
                                l10n.contractDetailsMonths(
                                  currentContract.installmentsCount,
                                ),
                                Icons.timer,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                l10n.contractDetailsGuarantor,
                                currentContract.guarantorName,
                                Icons.person_pin,
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                l10n.contractDetailsPropertyDesc,
                                currentContract.apartmentDetails,
                                Icons.apartment,
                                isBold: true,
                                valueColor: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    if (isAllocated) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSectionCard(
                            title: l10n.contractDetailsHandoverStatusTitle,
                            icon: Icons.vpn_key,
                            color: currentContract.isHandedOver
                                ? Colors.teal.shade700
                                : Colors.orange.shade700,
                            bgColor: currentContract.isHandedOver
                                ? Colors.teal.shade50
                                : Colors.orange.shade50,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentContract.isHandedOver
                                        ? Colors.teal.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        currentContract.isHandedOver
                                            ? Icons.check_circle
                                            : Icons.hourglass_top,
                                        color: currentContract.isHandedOver
                                            ? Colors.teal.shade800
                                            : Colors.orange.shade800,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        currentContract.isHandedOver
                                            ? l10n.contractDetailsHandoverDone
                                            : l10n.contractDetailsHandoverPending,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: currentContract.isHandedOver
                                              ? Colors.teal.shade900
                                              : Colors.orange.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  l10n.contractDetailsAgreedHandoverDate,
                                  _formatDateSafely(
                                    currentContract.agreedHandoverDate,
                                  ),
                                  Icons.event,
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  l10n.contractDetailsGracePeriod,
                                  l10n.contractDetailsMonths(
                                    currentContract.gracePeriodMonths,
                                  ),
                                  Icons.hourglass_empty,
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  l10n.contractDetailsPenaltySystem,
                                  isPenaltyActive
                                      ? l10n.contractDetailsPenaltyActive(
                                          penaltyPct.toString(),
                                          penaltyInterval,
                                        )
                                      : l10n.contractDetailsPenaltyInactive,
                                  Icons.local_fire_department,
                                  isBold: isPenaltyActive,
                                  valueColor: isPenaltyActive
                                      ? Colors.deepOrange.shade700
                                      : Colors.grey,
                                ),

                                if (currentContract.isHandedOver) ...[
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    l10n.contractDetailsActualHandoverDate,
                                    _formatDateSafely(
                                      currentContract.actualHandoverDate,
                                    ),
                                    Icons.event_available,
                                    isBold: true,
                                    valueColor: Colors.teal.shade800,
                                  ),
                                  if (currentContract.handoverNotes != null &&
                                      currentContract
                                          .handoverNotes!
                                          .isNotEmpty) ...[
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      l10n.contractDetailsHandoverNotes,
                                      currentContract.handoverNotes!,
                                      Icons.note_alt,
                                      valueColor: Colors.red.shade700,
                                    ),
                                  ],

                                  if (currentSummary != null &&
                                      currentSummary.penaltyAmount > 0) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.red.shade700,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.contractDetailsPenaltyAlertTitle,
                                                  style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l10n.contractDetailsPenaltyAlertDesc(
                                                    formatWithCommas(
                                                      currentSummary
                                                          .penaltyAmount,
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.red.shade800,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],

                                if (!currentContract.isCompleted) ...[
                                  const SizedBox(height: 24),
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!currentContract.isHandedOver)
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.teal.shade700,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.vpn_key),
                                          label: Text(
                                            l10n.contractDetailsHandoverBtn,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () => _showHandoverDialog(
                                            context,
                                            currentContract,
                                            client,
                                          ),
                                        )
                                      else ...[
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.red.shade700,
                                            side: BorderSide(
                                              color: Colors.red.shade300,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.cancel_schedule_send,
                                          ),
                                          label: Text(
                                            l10n.contractDetailsCancelHandoverBtn,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () => _cancelHandover(
                                            context,
                                            currentContract,
                                            client,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blueGrey.shade800,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.print),
                                          label: Text(
                                            l10n.contractDetailsPrintHandoverBtn,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () => _printHandoverPdf(
                                            context,
                                            currentContract,
                                            client,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],

                    if (currentSummary != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSectionCard(
                            title: l10n.contractDetailsLegalSectionTitle,
                            icon: Icons.gavel,
                            color: Colors.brown.shade700,
                            bgColor: Colors.brown.shade50,
                            child: currentSummary.legalActions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        l10n.contractDetailsLegalClean,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: currentSummary.legalActions.map((
                                      action,
                                    ) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.brown.shade200,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.brown.shade100
                                                  .withOpacity(0.5),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildActionTypeChip(
                                                  action.actionType,
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.event,
                                                      size: 14,
                                                      color: Colors.brown,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatDateSafely(
                                                        action.actionDate,
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.brown,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (action.notes != null &&
                                                action.notes!.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Text(
                                                  action.notes!,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade800,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton.icon(
                                                icon: const Icon(
                                                  Icons.perm_media,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  l10n.contractDetailsLegalGalleryBtn,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.indigo,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  backgroundColor:
                                                      Colors.indigo.shade50,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  final authState = context
                                                      .read<AuthCubit>()
                                                      .state;
                                                  final canManageAttachments =
                                                      authState.hasPermission(
                                                        AppPermissions
                                                            .manageLegalAttachments,
                                                      );

                                                  Navigator.push(
                                                    context,
                                                    LegalAttachmentsPage.route(
                                                      action,
                                                      canManageAttachments,
                                                      context
                                                          .read<
                                                            LegalAffairsCubit
                                                          >(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionCard(
                          title: l10n.contractDetailsFinancialAnalysisTitle,
                          icon: Icons.analytics,
                          color: Colors.teal.shade700,
                          bgColor: Colors.teal.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isAllocated) ...[
                                if (coefficientsMap.isEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.contractDetailsNoCoefficients,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: coefficientsMap.entries.map((
                                      entry,
                                    ) {
                                      double percentage =
                                          (entry.value as num).toDouble() * 100;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50
                                              .withOpacity(
                                                0.5,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.teal.shade100,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade900,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      4,
                                                    ),
                                              ),
                                              child: Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ] else ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          l10n.contractDetailsUnallocatedPricingNote,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionTypeChip(String type) {
    Color bgColor;
    Color textColor;
    switch (type) {
      case 'إنذار':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
      case 'فراغ عقاري':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
      case 'رهن':
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
      case 'تسوية':
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
      case 'دعوى قضائية':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
      default:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTopStat(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      onPressed: onTap,
    );
  }
}
