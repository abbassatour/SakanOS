// مسار الملف: lib/contracts/widgets/dialogs/edit_contract_dialog.dart

import 'dart:async';
import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/verify_pin_dialog.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';

import 'edit_contract_sections/penalty_settings_section.dart';

void showEditContractDialog(BuildContext parentContext, Contract contract) {
  final authState = parentContext.read<AuthCubit>().state;
  final canEdit = authState.hasPermission(AppPermissions.createContracts);
  // صلاحية الحذف (عادة نربطها بصلاحية الإنشاء أو المدير)
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

  // 🌟 دالة الحفظ الموحدة (يتم استدعاؤها من أزرار الحفظ في التبويبات المختلفة)
  Future<void> _saveContractData(String successMessage) async {
    // 🛡️ حماية صارمة: منع الحقول الفارغة نهائياً
    if (isAllocated && isPenaltyActive) {
      if (penaltyPctCtrl.text.trim().isEmpty ||
          double.tryParse(penaltyPctCtrl.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'أدخل نسبة غرامة صحيحة! الحقل لا يمكن أن يكون فارغاً.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (penaltyIntervalCtrl.text.trim().isEmpty ||
          int.tryParse(penaltyIntervalCtrl.text) == null ||
          int.parse(penaltyIntervalCtrl.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مدة التطبيق يجب أن تكون شهراً واحداً على الأقل.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.zero, // تصفير الحواف لتمتد التبويبات بشكل جميل
      backgroundColor: Colors.white,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text(
            'إغلاق النافذة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      // 🌟 بناء هيكل التبويبات (Tabs) بتصميم عصري
      content: DefaultTabController(
        length: 2,
        child: SizedBox(
          width: 650,
          height: 520, // زيادة مساحة النافذة للراحة البصرية
          child: Column(
            children: [
              // --- 1. رأس النافذة والتبويبات ---
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
                                'إدارة وإعدادات العقد',
                                style: TextStyle(
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),

                          // 🌟 أزرار الأرشفة والحذف بتصميم "Chips"
                          Row(
                            children: [
                              // حالة العقد + زر الأرشفة
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
                                            ? 'مغلق (انقر للفتح)'
                                            : 'أرشفة وإغلاق',
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

                              // زر الحذف
                              if (widget.canDelete)
                                Tooltip(
                                  message: 'تدمير العقد وحذفه',
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
                                            'حذف',
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
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.article_outlined),
                          text: 'البيانات النصية',
                        ),
                        Tab(
                          icon: Icon(Icons.gavel_outlined),
                          text: 'الغرامات والجزاء',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. محتوى التبويبات ---
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBasicInfoTab(canEdit),
                    _buildPenaltyTab(canEdit),
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
                  'لتعديل (المبالغ المالية، مدة التقسيط، أو تاريخ التوقيع)، يرجى الذهاب إلى صفحة "المراقبة" واستخدام أدوات "إعادة الجدولة" أو "الخصائص" المخصصة لذلك لضمان دقة الحسابات.',
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
            labelText: 'وصف العقد / التفاصيل الإضافية',
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
            labelText: 'اسم الكفيل الضامن',
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
              label: const Text(
                'اعتماد وحفظ البيانات النصية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'الغرامات غير متاحة في عقود "المحفظة الاستثمارية".',
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
              label: const Text(
                'اعتماد وحفظ إعدادات الغرامة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () =>
                  _saveContractData('تم تحديث الشروط الجزائية بنجاح ✅'),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 📦 دالة الأرشفة وإعادة الفتح (تم تطويرها بالكامل)
  // ==========================================
  void _toggleArchive() {
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
              isCompleted ? 'إعادة تنشيط العقد' : 'أرشفة وإغلاق العقد',
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
                    ? 'هل أنت متأكد من رغبتك في إعادة فتح هذا العقد المغلق؟ إليك ما سيحدث:'
                    : 'هل أنت متأكد من رغبتك في إغلاق وأرشفة هذا العقد نهائياً؟ إليك ما سيحدث:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),

              if (!isCompleted) ...[
                // ماذا يحدث عند الأرشفة
                _buildInfoRowForDialog(
                  Icons.lock,
                  Colors.red,
                  'حماية السجل:',
                  'يُقفل العقد وتُمنع إضافة، تعديل، أو مسح أي دفعات أو أقساط مالية تخصه.',
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.visibility_off,
                  Colors.orange,
                  'شاشات المراقبة:',
                  'سيختفي العقد تماماً من رادار المتأخرات والمطالبات وقوائم الأقساط النشطة.',
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.pie_chart,
                  Colors.blue,
                  'الإحصائيات (KPIs):',
                  'سيبقى ضمن إجمالي المبيعات والأرباح، لكن سيُطرح من عداد "العقود الفعالة" في لوحة التحكم.',
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
                          'يُستخدم هذا الخيار فقط عند اكتمال دفعات العميل وتسليمه الوحدة وإنهاء كافة الالتزامات.',
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
                // ماذا يحدث عند إعادة الفتح
                _buildInfoRowForDialog(
                  Icons.lock_open,
                  Colors.green,
                  'استعادة الصلاحيات:',
                  'سيتم تفعيل العقد من جديد وتتمكن من إضافة مدفوعات وتعديل بياناته بحرية.',
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.radar,
                  Colors.blue,
                  'شاشات المراقبة:',
                  'سيعود العقد للظهور في قوائم الرادار والأقساط المتأخرة إذا كان هناك أقساط غير مسددة.',
                ),
                const SizedBox(height: 12),
                _buildInfoRowForDialog(
                  Icons.trending_up,
                  Colors.purple,
                  'الإحصائيات (KPIs):',
                  'سيُضاف العقد مجدداً إلى عداد "العقود الفعالة" في لوحة تحكم الإدارة.',
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
            child: const Text(
              'إلغاء التراجع',
              style: TextStyle(
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
              isCompleted ? 'نعم، أعد فتح العقد' : 'نعم، أرشف وأغلق العقد',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.pop(confirmCtx); // إغلاق نافذة التأكيد

              final isAuth = await showVerifyPinDialog(widget.parentContext);
              if (isAuth && widget.parentContext.mounted) {
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      isCompleted
                          ? 'جاري تفعيل العقد... ⏳'
                          : 'جاري أرشفة العقد... ⏳',
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
                Navigator.pop(context); // إغلاق نافذة التعديل الرئيسية
              }
            },
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لرسم صفوف الشرح في ديالوج الأرشفة
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

  // ==========================================
  // 🗑️ دالة تأكيد الحذف
  // ==========================================
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تحذير تدمير العقد', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذا العقد ونقله إلى سلة المحذوفات؟\n\n'
          'سيؤدي هذا إلى تصفير كافة الحسابات المتعلقة به وتحرير الشقة لتعود (متاحة للبيع) في الكتالوج.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmCtx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('نعم، دمر العقد'),
            onPressed: () async {
              Navigator.pop(confirmCtx); // إغلاق رسالة التأكيد

              final isAuth = await showVerifyPinDialog(widget.parentContext);
              if (isAuth && widget.parentContext.mounted) {
                widget.parentContext.read<ContractsCubit>().deleteContract(
                  widget.contract.id,
                );
                Navigator.pop(context); // إغلاق نافذة التعديل
                ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف العقد وتحرير الشقة بنجاح ✅'),
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
