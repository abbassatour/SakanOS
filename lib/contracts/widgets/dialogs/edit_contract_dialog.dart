// lib/contracts/widgets/dialogs/edit_contract_dialog.dart

import 'dart:async';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/verify_pin_dialog.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';

// استيراد الأقسام المعزولة الأنيقة
import 'edit_contract_sections/attachment_manager_section.dart';
import 'edit_contract_sections/penalty_settings_section.dart';

void showEditContractDialog(BuildContext parentContext, Contract contract) {
  final authState = parentContext.read<AuthCubit>().state;
  final canEdit =
      authState.hasPermission(AppPermissions.createContracts) &&
      !contract.isCompleted;

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => _EditContractDialogContent(
        contract: contract,
        parentContext: parentContext,
        canEdit: canEdit,
      ),
    ),
  );
}

class _EditContractDialogContent extends StatefulWidget {
  const _EditContractDialogContent({
    required this.contract,
    required this.parentContext,
    required this.canEdit,
  });

  final Contract contract;
  final BuildContext parentContext;
  final bool canEdit;

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

  // 🌟 دالة الحفظ الموحدة (يتم استدعاؤها من أزرار الحفظ في التبويبات المختلفة)
  Future<void> _saveContractData(String successMessage) async {
    if (isPenaltyActive && double.tryParse(penaltyPctCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل نسبة غرامة صحيحة!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context); // إغلاق النافذة
    final isAuth = await showVerifyPinDialog(widget.parentContext);

    if (isAuth && widget.parentContext.mounted) {
      unawaited(
        widget.parentContext.read<ContractsCubit>().updateContract(
          id: widget.contract.id,
          details: detailsController.text,
          guarantorName: guarantorController.text.isEmpty
              ? 'بدون كفيل'
              : guarantorController.text,
          // الحفاظ على البيانات المالية
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
    final contract = widget.contract;
    final canEdit = widget.canEdit;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.zero, // تصفير الحواف لتمتد التبويبات بشكل جميل
      // 🌟 التخلص من زر الحفظ السفلي العام القديم، واستبداله بزر الإغلاق فقط
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text(
            'إغلاق النافذة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
        ),
      ],
      // 🌟 بناء هيكل التبويبات (Tabs)
      content: DefaultTabController(
        length: 3,
        child: SizedBox(
          width: 550,
          height: 480, // تحديد ارتفاع ثابت للنافذة لمنع الانهيار
          child: Column(
            children: [
              // --- 1. رأس النافذة والتبويبات ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade200, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.edit_document, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'تعديل وإدارة العقد',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          if (contract.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'مغلق',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    TabBar(
                      labelColor: Colors.blue.shade900,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: Colors.blue.shade700,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(icon: Icon(Icons.article), text: 'بيانات العقد'),
                        Tab(icon: Icon(Icons.gavel), text: 'الغرامات'),
                        Tab(icon: Icon(Icons.attach_file), text: 'المرفقات'),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. محتوى التبويبات ---
              Expanded(
                child: TabBarView(
                  children: [
                    // 📝 التبويب الأول: بيانات العقد النصية
                    _buildBasicInfoTab(canEdit),

                    // 🔑 التبويب الثاني: الغرامات (للشقق المخصصة فقط)
                    _buildPenaltyTab(canEdit),

                    // 📎 التبويب الثالث: المرفقات
                    _buildAttachmentsTab(canEdit),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 📝 التبويب الأول: البيانات الإدارية
  // ==========================================
  Widget _buildBasicInfoTab(bool canEdit) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'لتعديل (المبالغ المالية، مدة التقسيط، أو تاريخ التوقيع)، يرجى الذهاب إلى صفحة "المراقبة" واستخدام أدوات "إعادة الجدولة".',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: detailsController,
          enabled: canEdit,
          decoration: const InputDecoration(
            labelText: 'وصف العقد / التفاصيل الإضافية',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: guarantorController,
          enabled: canEdit,
          decoration: const InputDecoration(
            labelText: 'اسم الكفيل الضامن',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_pin),
          ),
        ),
        const SizedBox(height: 24),
        if (canEdit)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.save),
              label: const Text('حفظ البيانات النصية'),
              onPressed: () =>
                  _saveContractData('تم حفظ التعديلات النصية بنجاح ✅'),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 🔑 التبويب الثاني: الغرامات والشروط الجزائية
  // ==========================================
  Widget _buildPenaltyTab(bool canEdit) {
    if (!isAllocated) {
      return const Center(
        child: Text(
          'الغرامات غير متاحة في عقود "المحفظة الاستثمارية".',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PenaltySettingsSection(
          canEdit: canEdit,
          isPenaltyActive: isPenaltyActive,
          penaltyPctCtrl: penaltyPctCtrl,
          penaltyIntervalCtrl: penaltyIntervalCtrl,
          onPenaltyToggle: (val) => setState(() => isPenaltyActive = val),
        ),
        const SizedBox(height: 24),
        if (canEdit)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.local_fire_department),
              label: const Text('حفظ إعدادات الغرامة'),
              onPressed: () =>
                  _saveContractData('تم تحديث الشروط الجزائية بنجاح ✅'),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 📎 التبويب الثالث: المرفقات (تستخدم القسم الذي عزلناه)
  // ==========================================
  Widget _buildAttachmentsTab(bool canEdit) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'النسخة الإلكترونية من العقد (PDF/Word)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'يمكنك إرفاق نسخة ممسوحة ضوئياً من العقد الورقي الموقّع هنا لسهولة الوصول إليه لاحقاً.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // 🌟 استدعاء القطعة المعزولة التي أنشأناها في الخطوة السابقة
        AttachmentManagerSection(
          contract: widget.contract,
          canEdit: canEdit,
          parentContext: widget.parentContext,
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.cloud_done_outlined, color: Colors.teal),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'المرفقات يتم حفظها ورفعها للسحابة فوراً بشكل مستقل، ولا تحتاج لضغط زر حفظ إضافي.',
                  style: TextStyle(color: Colors.teal, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
