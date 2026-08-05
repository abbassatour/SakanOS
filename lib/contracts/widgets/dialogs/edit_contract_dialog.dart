// مسار الملف: lib/contracts/widgets/dialogs/edit_contract_dialog.dart

import 'dart:async';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/verify_pin_dialog.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import 'edit_contract_sections/penalty_settings_section.dart';

void showEditContractDialog(BuildContext parentContext, Contract contract) {
  final authState = parentContext.read<AuthCubit>().state;
  final canEdit = authState.hasPermission(AppPermissions.createContracts);
  final canDelete = authState.hasPermission(AppPermissions.createContracts);

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => _EditContractDialogContent(
        contract: contract,
        parentContext: parentContext,
        canEdit: canEdit,
        canDelete: canDelete,
      ),
    ),
  );
}

class _EditContractDialogContent extends StatefulWidget {
  const _EditContractDialogContent({
    required this.contract,
    required this.parentContext,
    required this.canEdit,
    required this.canDelete,
  });

  final Contract contract;
  final BuildContext parentContext;
  final bool canEdit;
  final bool canDelete;

  @override
  State<_EditContractDialogContent> createState() =>
      _EditContractDialogContentState();
}

class _EditContractDialogContentState
    extends State<_EditContractDialogContent> {
  late final TextEditingController detailsController;
  late final TextEditingController guarantorController;

  late bool isPenaltyActive;
  late final TextEditingController penaltyPctCtrl;
  late final TextEditingController penaltyIntervalCtrl;

  late bool isAllocated;

  @override
  void initState() {
    super.initState();
    final contract = widget.contract;

    detailsController = TextEditingController(text: contract.apartmentDetails);
    guarantorController = TextEditingController(text: contract.guarantorName);
    isAllocated = contract.contractType == 'متخصص';

    isPenaltyActive = contract.isPenaltyActive ?? false;
    penaltyPctCtrl = TextEditingController(
      text: contract.penaltyPercentage.toString(),
    );
    penaltyIntervalCtrl = TextEditingController(
      text: contract.penaltyIntervalMonths.toString(),
    );
  }

  @override
  void dispose() {
    detailsController.dispose();
    guarantorController.dispose();
    penaltyPctCtrl.dispose();
    penaltyIntervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveContractData(String successMessage) async {
    final l10n = context.l10n;

    if (isAllocated && isPenaltyActive) {
      if (penaltyPctCtrl.text.trim().isEmpty ||
          double.tryParse(penaltyPctCtrl.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contractEditValPenaltyPct),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (penaltyIntervalCtrl.text.trim().isEmpty ||
          int.tryParse(penaltyIntervalCtrl.text) == null ||
          int.parse(penaltyIntervalCtrl.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contractEditValPenaltyInterval),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Navigator.pop(context);
    final isAuth = await showVerifyPinDialog(widget.parentContext);

    if (isAuth && widget.parentContext.mounted) {
      unawaited(
        widget.parentContext.read<ContractsCubit>().updateContract(
          id: widget.contract.id,
          details: detailsController.text,
          guarantorName: guarantorController.text.isEmpty
              ? 'بدون كفيل'
              : guarantorController.text,
          installmentsCount: widget.contract.installmentsCount,
          agreedMonthlyAmount: widget.contract.agreedMonthlyAmount,
          contractDate: widget.contract.contractDate,
          isPenaltyActive: isAllocated && isPenaltyActive,
          penaltyPercentage: isAllocated && isPenaltyActive
              ? (double.tryParse(penaltyPctCtrl.text) ?? 0.0)
              : 0.0,
          penaltyIntervalMonths: isAllocated && isPenaltyActive
              ? (int.tryParse(penaltyIntervalCtrl.text) ?? 1)
              : 1,
        ),
      );

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contract = widget.contract;
    final canEdit = widget.canEdit;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: Text(
            l10n.contractEditCloseWindow,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      content: DefaultTabController(
        length: 2,
        child: SizedBox(
          width: 650,
          height: 520,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.indigo.shade100, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.edit_document,
                                  color: Colors.indigo.shade700,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.contractEditDialogTitle,
                                style: TextStyle(
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: widget.canEdit ? _toggleArchive : null,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: contract.isCompleted
                                        ? Colors.green.shade50
                                        : Colors.blueGrey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: contract.isCompleted
                                          ? Colors.green.shade300
                                          : Colors.blueGrey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        contract.isCompleted
                                            ? Icons.lock
                                            : Icons.archive_outlined,
                                        size: 18,
                                        color: contract.isCompleted
                                            ? Colors.green.shade700
                                            : Colors.blueGrey.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        contract.isCompleted
                                            ? l10n.contractEditClosedTag
                                            : l10n.contractEditArchiveBtn,
                                        style: TextStyle(
                                          color: contract.isCompleted
                                              ? Colors.green.shade800
                                              : Colors.blueGrey.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (widget.canDelete)
                                Tooltip(
                                  message: l10n.contractEditDeleteBtn,
                                  child: InkWell(
                                    onTap: _confirmDelete,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_forever,
                                            size: 18,
                                            color: Colors.red.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.contractEditDeleteBtn,
                                            style: TextStyle(
                                              color: Colors.red.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      labelColor: Colors.indigo.shade800,
                      unselectedLabelColor: Colors.blueGrey.shade400,
                      indicatorColor: Colors.indigo.shade600,
                      indicatorWeight: 4,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.article_outlined),
                          text: l10n.contractEditTabBasic,
                        ),
                        Tab(
                          icon: const Icon(Icons.gavel_outlined),
                          text: l10n.contractEditTabPenalty,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBasicInfoTab(canEdit, l10n),
                    _buildPenaltyTab(canEdit, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(bool canEdit, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.contractEditInfoNotice,
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: detailsController,
          enabled: canEdit,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: l10n.contractEditDetailsLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: canEdit ? Colors.white : Colors.grey.shade100,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: guarantorController,
          enabled: canEdit,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: l10n.contractEditGuarantorLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: canEdit ? Colors.white : Colors.grey.shade100,
            prefixIcon: const Icon(Icons.person_pin_outlined),
          ),
        ),
        const SizedBox(height: 24),
        if (canEdit)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                l10n.contractEditSaveTextBtn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () =>
                  _saveContractData(l10n.contractEditSuccessTextMsg),
            ),
          ),
      ],
    );
  }

  Widget _buildPenaltyTab(bool canEdit, AppLocalizations l10n) {
    if (!isAllocated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.contractEditPenaltyUnallocatedNotice,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        PenaltySettingsSection(
          canEdit: canEdit,
          isPenaltyActive: isPenaltyActive,
          penaltyPctCtrl: penaltyPctCtrl,
          penaltyIntervalCtrl: penaltyIntervalCtrl,
          onPenaltyToggle: (val) => setState(() => isPenaltyActive = val),
        ),
        const SizedBox(height: 32),
        if (canEdit)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.local_fire_department),
              label: Text(
                l10n.contractEditSavePenaltyBtn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () =>
                  _saveContractData(l10n.contractEditSuccessPenaltyMsg),
            ),
          ),
      ],
    );
  }

  void _toggleArchive() {
    final l10n = context.l10n;
    final isCompleted = widget.contract.isCompleted;

    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.shade50
                    : Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.lock_open_rounded : Icons.archive_rounded,
                color: isCompleted
                    ? Colors.green.shade700
                    : Colors.blueGrey.shade800,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              isCompleted
                  ? l10n.contractArchiveTitleActivate
                  : l10n.contractArchiveTitleClose,
              style: TextStyle(
                color: isCompleted
                    ? Colors.green.shade800
                    : Colors.blueGrey.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCompleted
                    ? l10n.contractArchiveConfirmActivateText
                    : l10n.contractArchiveConfirmCloseText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),

              if (!isCompleted) ...[
                _buildInfoRowForDialog(
                  Icons.lock,
                  Colors.red,
                  l10n.contractArchiveInfoLockTitle,
                  l10n.contractArchiveInfoLockDesc,
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.visibility_off,
                  Colors.orange,
                  l10n.contractArchiveInfoRadarTitle,
                  l10n.contractArchiveInfoRadarDesc,
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.pie_chart,
                  Colors.blue,
                  l10n.contractArchiveInfoKpiTitle,
                  l10n.contractArchiveInfoKpiDesc,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.contractArchiveUsageTip,
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildInfoRowForDialog(
                  Icons.lock_open,
                  Colors.green,
                  l10n.contractArchiveUnlockPermTitle,
                  l10n.contractArchiveUnlockPermDesc,
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.radar,
                  Colors.blue,
                  l10n.contractArchiveUnlockRadarTitle,
                  l10n.contractArchiveUnlockRadarDesc,
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.trending_up,
                  Colors.purple,
                  l10n.contractArchiveUnlockKpiTitle,
                  l10n.contractArchiveUnlockKpiDesc,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmCtx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              l10n.contractArchiveCancelBtn,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted
                  ? Colors.green.shade700
                  : Colors.blueGrey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(isCompleted ? Icons.lock_open : Icons.archive, size: 20),
            label: Text(
              isCompleted
                  ? l10n.contractArchiveConfirmActivateBtn
                  : l10n.contractArchiveConfirmCloseBtn,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.pop(confirmCtx);

              final isAuth = await showVerifyPinDialog(widget.parentContext);
              if (isAuth && widget.parentContext.mounted) {
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      isCompleted
                          ? l10n.contractArchiveProgressActivate
                          : l10n.contractArchiveProgressClose,
                    ),
                    backgroundColor: Colors.teal,
                  ),
                );

                widget.parentContext
                    .read<ContractsCubit>()
                    .toggleContractCompletion(
                      contractId: widget.contract.id,
                      isCompleted: !isCompleted,
                    );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowForDialog(
    IconData icon,
    Color color,
    String title,
    String desc,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Tahoma',
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              l10n.contractDeleteTitle,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Text(
          l10n.contractDeleteMsg,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmCtx),
            child: Text(
              l10n.btnCancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.contractDeleteConfirmBtn),
            onPressed: () async {
              Navigator.pop(confirmCtx);

              final isAuth = await showVerifyPinDialog(widget.parentContext);
              if (isAuth && widget.parentContext.mounted) {
                widget.parentContext.read<ContractsCubit>().deleteContract(
                  widget.contract.id,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  SnackBar(
                    content: Text(l10n.contractDeleteSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
