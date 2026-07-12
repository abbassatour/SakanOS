// lib/settings/view/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';

import '../cubit/settings_cubit.dart';
import 'price_history_page.dart';
// 🌟 استدعاء شاشة سجل الدولار (سننشئها في الخطوة القادمة)
import 'dollar_history_page.dart';

import 'dialogs/confirm_restore_dialog.dart';
import 'dialogs/result_message_dialog.dart';
import '../../recycle_bin/view/recycle_bin_page.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

// ==========================================
// 🌟 أداة تنسيق الأرقام بالفواصل
// ==========================================
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatNumber(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

// ==========================================
// 🌟 الصفحة الرئيسية
// ==========================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsCubit(context.read<ErpRepository>())..fetchPrices(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // متحكمات أسعار المواد
  final ironController = TextEditingController();
  final cementController = TextEditingController();
  final blockController = TextEditingController();
  final formworkController = TextEditingController();
  final aggregatesController = TextEditingController();
  final workerController = TextEditingController();

  // 🌟 متحكم سعر الدولار الجديد
  final dollarController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isProcessingBackup = false;

  @override
  void dispose() {
    ironController.dispose();
    cementController.dispose();
    blockController.dispose();
    formworkController.dispose();
    aggregatesController.dispose();
    workerController.dispose();
    dollarController.dispose(); // 🌟 تنظيف الذاكرة
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // 🎯 دوال الحفظ (Actions)
  // ==========================================

  void _saveMaterialPrices(BuildContext context) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري حفظ أسعار المواد...'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
    context.read<SettingsCubit>().updatePrices(
      iron: double.tryParse(ironController.text.replaceAll(',', '')) ?? 0,
      cement: double.tryParse(cementController.text.replaceAll(',', '')) ?? 0,
      block15: double.tryParse(blockController.text.replaceAll(',', '')) ?? 0,
      formwork:
          double.tryParse(formworkController.text.replaceAll(',', '')) ?? 0,
      aggregates:
          double.tryParse(aggregatesController.text.replaceAll(',', '')) ?? 0,
      worker: double.tryParse(workerController.text.replaceAll(',', '')) ?? 0,
    );
  }

  void _saveDollarPrice(BuildContext context) {
    FocusScope.of(context).unfocus();
    final rate =
        double.tryParse(dollarController.text.replaceAll(',', '')) ?? 0;
    if (rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سعر صحيح للدولار'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري حفظ سعر الدولار...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    context.read<SettingsCubit>().updateDollarPrice(rate);
  }

  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _isProcessingBackup = true);
    final resultMsg = await context.read<SettingsCubit>().createManualBackup();
    setState(() => _isProcessingBackup = false);
    if (mounted)
      showResultMessageDialog(
        context,
        title: 'النسخ الاحتياطي',
        message: resultMsg,
      );
  }

  Future<void> _handleRestore(BuildContext context) async {
    final confirm = await showConfirmRestoreDialog(context);
    if (confirm == true && mounted) {
      setState(() => _isProcessingBackup = true);
      final resultMsg = await context.read<SettingsCubit>().restoreDatabase();
      setState(() => _isProcessingBackup = false);
      if (mounted)
        showResultMessageDialog(
          context,
          title: 'استعادة البيانات',
          message: resultMsg,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final hasUpdatePermission = authState.hasPermission(
      AppPermissions.updatePrices,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.currentPrices != current.currentPrices ||
              previous.currentDollarPrice !=
                  current.currentDollarPrice, // 🌟 الاستماع للدولار

          listener: (context, state) {
            // تعبئة أسعار المواد
            if (state.status == SettingsStatus.success &&
                state.currentPrices != null) {
              ironController.text = formatNumber(
                state.currentPrices!.ironPrice,
              );
              cementController.text = formatNumber(
                state.currentPrices!.cementPrice,
              );
              blockController.text = formatNumber(
                state.currentPrices!.block15Price,
              );
              formworkController.text = formatNumber(
                state.currentPrices!.formworkAndPouringWages,
              );
              aggregatesController.text = formatNumber(
                state.currentPrices!.aggregateMaterialsPrice,
              );
              workerController.text = formatNumber(
                state.currentPrices!.ordinaryWorkerWage,
              );
            }
            // 🌟 تعبئة سعر الدولار
            if (state.status == SettingsStatus.success &&
                state.currentDollarPrice != null) {
              dollarController.text = formatNumber(
                state.currentDollarPrice!.exchangeRate,
              );
            }

            if (state.status == SettingsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == SettingsStatus.loading ||
                state.status == SettingsStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blueGrey),
              );
            }

            return Center(
              child: SizedBox(
                width: 700,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🌟 العنوان
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.settings_suggest,
                                  color: Colors.blueGrey.shade700,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'إعدادات النظام والأسعار',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ==========================================
                          // 💵 بطاقة إعداد سعر الدولار (مستقلة ومنظمة)
                          // ==========================================
                          _buildDollarCard(context, hasUpdatePermission),

                          const SizedBox(height: 24),

                          // ==========================================
                          // 🧱 بطاقة إعداد الأسعار الإفرادية للمواد
                          // ==========================================
                          _buildMaterialPricesCard(
                            context,
                            hasUpdatePermission,
                          ),

                          const SizedBox(height: 24),

                          // ==========================================
                          // 🗑️ بطاقة سلة المحذوفات
                          // ==========================================
                          if (authState.hasPermission(
                            AppPermissions.viewRecycleBin,
                          )) ...[
                            _buildRecycleBinCard(context),
                            const SizedBox(height: 24),
                          ],

                          // ==========================================
                          // 🔐 بطاقة رمز الأمان (تم نقلها لتكون فوق النسخ الاحتياطي)
                          // ==========================================
                          if (authState.isSystemAdmin) ...[
                            // 🌟 أضف بطاقة معلومات الرخصة هنا
                            _buildSubscriptionCard(
                              context,
                              state.subscriptionExpiryDate,
                            ),
                            const SizedBox(height: 24),

                            _buildSecurityCard(context, authState.securityPin),
                            const SizedBox(height: 36),
                          ],

                          // ==========================================
                          // 🛡️ بطاقة النسخ الاحتياطي والاستعادة
                          // ==========================================
                          _buildBackupRestoreCard(
                            context,
                            authState.isSystemAdmin,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🧩 تصميم الأجزاء (Components) المنفصلة
  // ==========================================

  // 💵 1. بطاقة الدولار
  Widget _buildDollarCard(BuildContext context, bool hasPermission) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سعر صرف الدولار (مبيع)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يُستخدم لتقييم الدفعات، الأقساط، والتحويلات النقدية.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade300, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final cubit = context.read<SettingsCubit>();
                  cubit.fetchDollarHistory(); // جلب السجل
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const DollarHistoryPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 20),
                label: const Text(
                  'سجل الدولار',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  controller: dollarController,
                  label: 'سعر 1 دولار (USD)',
                  icon: Icons.attach_money,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) =>
                      hasPermission ? _saveDollarPrice(context) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: hasPermission
                        ? () => _saveDollarPrice(context)
                        : null,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'اعتماد سعر الصرف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🧱 2. بطاقة أسعار المواد
  Widget _buildMaterialPricesCard(BuildContext context, bool hasPermission) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأسعار الافرادية للمواد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'النظام سيضرب هذه الأرقام بالكميات الثابتة لحساب سعر المتر',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: BorderSide(color: Colors.indigo.shade200, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final cubit = context.read<SettingsCubit>();
                  cubit.fetchPriceHistory();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const PriceHistoryPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 20),
                label: const Text(
                  'سجل أسعار المواد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  controller: ironController,
                  label: 'سعر (1 كغ) حديد مبروم',
                  icon: Icons.hardware,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceField(
                  controller: cementController,
                  label: 'سعر (1 كيس) اسمنت',
                  icon: Icons.foundation,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  controller: blockController,
                  label: 'سعر (1 بلوكة) سماكة 15',
                  icon: Icons.view_in_ar,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceField(
                  controller: formworkController,
                  label: 'أجور كوفراج وبيتون (1 م³)',
                  icon: Icons.architecture,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  controller: aggregatesController,
                  label: 'سعر (1 م³) مواد حصوية',
                  icon: Icons.landslide,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceField(
                  controller: workerController,
                  label: 'أجرة (يوم) عامل 7 ساعات',
                  icon: Icons.engineering,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) =>
                      hasPermission ? _saveMaterialPrices(context) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: hasPermission
                  ? () => _saveMaterialPrices(context)
                  : null,
              icon: const Icon(Icons.save),
              label: const Text(
                'اعتماد وحفظ الأسعار',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🗑️ 3. بطاقة سلة المحذوفات
  Widget _buildRecycleBinCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.03),
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
              Icon(Icons.delete_sweep, color: Colors.red.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'إدارة المحذوفات (سلة المهملات)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'استعادة العملاء، العقود، المحاضر، الشقق والإيصالات الملغاة أو حذفها نهائياً.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade800,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecycleBinPage()),
              ),
              icon: const Icon(Icons.recycling, size: 24),
              label: const Text(
                'فتح سلة المحذوفات الشاملة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 بطاقة رمز الأمان
  Widget _buildSecurityCard(BuildContext context, String currentPin) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.03),
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
              Icon(Icons.password, color: Colors.red.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'رمز الأمان وحماية العمليات الحساسة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'هذا الرمز يُطلب عند الحذف أو استرجاع الأموال والعمليات الإدارية الحساسة. (الرمز الافتراضي 0000)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade800,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _showChangePinDialog(context, currentPin),
              icon: const Icon(Icons.edit_attributes, size: 24),
              label: const Text(
                'تغيير رمز الأمان (PIN)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ديالوج تغيير الـ PIN
  void _showChangePinDialog(BuildContext parentContext, String currentPin) {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تغيير رمز الأمان',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinCtrl,
              obscureText: true,
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الرمز الحالي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الرمز الجديد',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (oldPinCtrl.text != currentPin) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('الرمز الحالي غير صحيح!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPinCtrl.text.isEmpty) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('أدخل رمزاً جديداً!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              await parentContext.read<SettingsCubit>().updateSecurityPin(
                newPinCtrl.text.trim(),
              );
              // تحديث الـ AuthCubit ليعكس الرمز الجديد فوراً في التطبيق
              await parentContext.read<AuthCubit>().checkSession();

              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('تم تغيير الرمز بنجاح! ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('حفظ الرمز الجديد'),
          ),
        ],
      ),
    );
  }

  // 🛡️ 4. بطاقة النسخ الاحتياطي
  Widget _buildBackupRestoreCard(BuildContext context, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.03),
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
              Icon(Icons.security, color: Colors.teal.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'أمان قاعدة البيانات المحلية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أخذ نسخة احتياطية يدوية أو استعادة بيانات سابقة.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isProcessingBackup
                        ? null
                        : () => _handleBackup(context),
                    icon: _isProcessingBackup
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_alt),
                    label: const Text(
                      'نسخ احتياطي يدوي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade100,
                      foregroundColor: Colors.blueGrey.shade900,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (_isProcessingBackup || !isAdmin)
                        ? null
                        : () => _handleRestore(context),
                    icon: const Icon(Icons.restore_page),
                    label: const Text(
                      'استعادة البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 أداة حقل الإدخال المشتركة
  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputAction textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      inputFormatters: [ThousandsFormatter()],
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 22),
        suffixText: 'ل.س',
        suffixStyle: TextStyle(
          color: Colors.blueGrey.shade300,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
          borderSide: BorderSide(color: Colors.blueGrey.shade500, width: 2),
        ),
      ),
    );
  }

  // ==========================================
  // 📜 بطاقة معلومات الرخصة والاشتراك (للمدير فقط)
  // ==========================================
  Widget _buildSubscriptionCard(BuildContext context, DateTime? expiryDate) {
    if (expiryDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final remainingDays = expiryDate.difference(now).inDays;

    // تحديد لون وحالة البطاقة بناءً على الأيام المتبقية
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (remainingDays < 0) {
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel;
      statusText = 'الرخصة منتهية الصلاحية!';
    } else if (remainingDays <= 15) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'الرخصة تقترب من الانتهاء';
    } else {
      statusColor = Colors.teal.shade700;
      statusIcon = Icons.verified_user;
      statusText = 'الرخصة فعّالة وسارية';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.04),
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
              Icon(
                Icons.workspace_premium,
                color: Colors.purple.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات ترخيص النظام (License)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تاريخ انتهاء الاشتراك:',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expiryDate.year}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            remainingDays >= 0
                                ? 'متبقي $remainingDays يوم'
                                : 'منتهية منذ ${remainingDays.abs()} يوم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
