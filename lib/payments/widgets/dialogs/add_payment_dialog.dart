// lib/payments/widgets/dialogs/add_payment_dialog.dart
// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/core/utils/calculator_helper.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';
import 'package:our_home_erp_app/settings/cubit/settings_cubit.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    var formatted = '';
    var count = 0;
    for (var i = digitsOnly.length - 1; i >= 0; i--) {
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

void showAddPaymentDialog(BuildContext parentContext, String contractId) {
  final paymentsCubit = parentContext.read<PaymentsCubit>();
  final settingsCubit = parentContext.read<SettingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: paymentsCubit),
            BlocProvider.value(value: settingsCubit),
          ],
          child: _AddPaymentDialogContent(
            contractId: contractId,
            parentContext: parentContext,
          ),
        );
      },
    ),
  );
}

class _AddPaymentDialogContent extends StatefulWidget {
  const _AddPaymentDialogContent({
    required this.contractId,
    required this.parentContext,
  });

  final String contractId;
  final BuildContext parentContext;

  @override
  State<_AddPaymentDialogContent> createState() =>
      _AddPaymentDialogContentState();
}

class _AddPaymentDialogContentState extends State<_AddPaymentDialogContent> {
  final amountController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final histDollarRateCtrl = TextEditingController();
  final meterPriceCtrl = TextEditingController();
  final histIronCtrl = TextEditingController();
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  bool isDeposit = true;
  bool isHistoricalPayment = false;
  bool isDetailedMode = false;
  bool isDollarPayment = false;
  DateTime selectedHistoricalDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    amountController.dispose();
    discountController.dispose();
    histDollarRateCtrl.dispose();
    meterPriceCtrl.dispose();
    histIronCtrl.dispose();
    histCementCtrl.dispose();
    histBlockCtrl.dispose();
    histFormworkCtrl.dispose();
    histAggregatesCtrl.dispose();
    histWorkerCtrl.dispose();
    super.dispose();
  }

  void _onInputChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final contract = context.read<PaymentsCubit>().state.contracts.firstWhere(
          (c) => c.id == widget.contractId,
        );

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final currentPrices = settingsState.currentPrices;
        final currentDollar = settingsState.currentDollarPrice;

        final enteredAmount = double.tryParse(
              amountController.text.replaceAll(',', ''),
            ) ??
            0;

        final historicalDollarRate = double.tryParse(
              histDollarRateCtrl.text.replaceAll(',', ''),
            ) ??
            0;

        var sypEquivalentAmount = enteredAmount;
        if (isDollarPayment) {
          if (isHistoricalPayment) {
            sypEquivalentAmount = enteredAmount * historicalDollarRate;
          } else if (currentDollar != null) {
            sypEquivalentAmount = enteredAmount * currentDollar.exchangeRate;
          }
        }

        final discountPct = double.tryParse(discountController.text) ?? 0;
        final effectiveAmount = sypEquivalentAmount +
            (sypEquivalentAmount * (discountPct / 100));

        var calculatedMeterPrice = 0.0;

        if (isHistoricalPayment && !isDetailedMode) {
          calculatedMeterPrice = double.tryParse(
                meterPriceCtrl.text.replaceAll(',', ''),
              ) ??
              0;
        } else {
          MaterialPricesHistoryData? targetPrices;

          if (isHistoricalPayment && isDetailedMode) {
            targetPrices = MaterialPricesHistoryData(
              id: 'dummy',
              effectiveDate: DateTime.now(),
              userId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isDeleted: false,
              isSynced: false,
              ironPrice: double.tryParse(
                    histIronCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
              cementPrice: double.tryParse(
                    histCementCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
              block15Price: double.tryParse(
                    histBlockCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
              formworkAndPouringWages: double.tryParse(
                    histFormworkCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
              aggregateMaterialsPrice: double.tryParse(
                    histAggregatesCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
              ordinaryWorkerWage: double.tryParse(
                    histWorkerCtrl.text.replaceAll(',', ''),
                  ) ??
                  0,
            );
          } else {
            targetPrices = currentPrices;
          }

          if (targetPrices != null) {
            try {
              final coeffs = jsonDecode(contract.coefficients)
                  as Map<String, dynamic>;
              final parsedCoeffs = coeffs.map(
                (k, dynamic v) => MapEntry(k, (v as num).toDouble()),
              );
              final calculations = CalculatorHelper.calculateContractValues(
                area: contract.totalArea > 0 ? contract.totalArea : 1.0,
                currentPrices: targetPrices,
                coefficients: parsedCoeffs,
              );
              calculatedMeterPrice = calculations['pricePerSqm'] ?? 0;
            } catch (_) {
              calculatedMeterPrice = 0;
            }
          }
        }

        final previewMeters = calculatedMeterPrice > 0
            ? (effectiveAmount / calculatedMeterPrice)
            : 0.0;

        final mainColor = isDeposit ? Colors.deepOrange : Colors.red.shade800;
        final titleText =
            isDeposit ? 'إدخال دفعة (إيداع)' : 'سحب / استرداد مبلغ';

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: mainColor,
              ),
              const SizedBox(width: 8),
              Text(
                titleText,
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'إيداع (قبض)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            value: true,
                            groupValue: isDeposit,
                            activeColor: Colors.deepOrange,
                            onChanged: (val) => setState(
                              () => isDeposit = val ?? true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'استرداد (سحب)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                            value: false,
                            groupValue: isDeposit,
                            activeColor: Colors.red,
                            onChanged: (val) async {
                              final authorized = await showVerifyPinDialog(
                                context: widget.parentContext,
                              );
                              if (authorized && mounted) {
                                setState(() => isDeposit = val ?? false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDollarPayment
                          ? Colors.green.shade50
                          : Colors.white,
                      border: Border.all(
                        color: isDollarPayment
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'إدخال المبلغ بالدولار الأمريكي (USD)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDollarPayment
                              ? Colors.green.shade700
                              : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: isHistoricalPayment
                          ? const Text(
                              'أدخل سعر صرف الدولار القديم في الأسفل',
                              style: TextStyle(color: Colors.green),
                            )
                          : (currentDollar != null
                              ? Text(
                                  'سعر الصرف: ${NumberFormatters.formatWithCommas(
                                    currentDollar.exchangeRate,
                                  )} ل.س',
                                  style: TextStyle(
                                    color: isDollarPayment
                                        ? Colors.green.shade900
                                        : Colors.grey,
                                  ),
                                )
                              : const Text(
                                  '⚠️ جاري تحميل التسعيرة أو لم يتم تعيينها',
                                  style: TextStyle(color: Colors.red),
                                )),
                      value: isDollarPayment,
                      activeColor: Colors.green,
                      onChanged: (isHistoricalPayment || currentDollar != null)
                          ? (val) {
                              setState(() {
                                isDollarPayment = val;
                                amountController.clear();
                              });
                            }
                          : null,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isHistoricalPayment
                          ? Colors.blue.shade50
                          : Colors.transparent,
                      border: Border.all(
                        color: isHistoricalPayment
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'إدخال عملية قديمة (تاريخية)',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'لتسجيل حركات سابقة وإدخال سعر المتر يدوياً.',
                      ),
                      value: isHistoricalPayment,
                      activeColor: Colors.blue,
                      onChanged: (val) async {
                        if (val) {
                          final authorized = await showVerifyPinDialog(
                            context: widget.parentContext,
                          );
                          if (authorized && mounted) {
                            setState(() => isHistoricalPayment = true);
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedHistoricalDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null && mounted) {
                              setState(
                                () => selectedHistoricalDate = pickedDate,
                              );
                            }
                          }
                        } else {
                          setState(() {
                            isHistoricalPayment = false;
                            isDetailedMode = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isHistoricalPayment) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blue.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '📅 تاريخ العملية:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue.shade700,
                                  elevation: 0,
                                  side: BorderSide(
                                    color: Colors.blue.shade300,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.calendar_month,
                                  size: 22,
                                ),
                                label: Text(
                                  '${selectedHistoricalDate.year}/'
                                  '${selectedHistoricalDate.month}/'
                                  '${selectedHistoricalDate.day}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedHistoricalDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null && mounted) {
                                    setState(
                                      () => selectedHistoricalDate = pickedDate,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          if (isDollarPayment) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: histDollarRateCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: InputDecoration(
                                labelText:
                                    'سعر صرف 1 دولار في ذلك التاريخ (ل.س)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.history_edu,
                                  color: Colors.green,
                                ),
                                filled: true,
                                fillColor: Colors.green.shade50,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.green.shade700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: _onInputChanged,
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Divider(color: Colors.blue),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text(
                                    'إدخال مباشر',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'سعر المتر فقط',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  value: false,
                                  groupValue: isDetailedMode,
                                  onChanged: (val) => setState(
                                    () => isDetailedMode = val ?? false,
                                  ),
                                  activeColor: Colors.blue,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text(
                                    'إدخال تفصيلي',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'مواد تُحفظ بالسجل',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  value: true,
                                  groupValue: isDetailedMode,
                                  onChanged: (val) => setState(
                                    () => isDetailedMode = val ?? false,
                                  ),
                                  activeColor: Colors.blue,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (!isDetailedMode)
                            TextField(
                              controller: meterPriceCtrl,
                              inputFormatters: [ThousandsFormatter()],
                              decoration: const InputDecoration(
                                labelText: 'سعر المتر المربع (ل.س)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.speed, color: Colors.blue),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: _onInputChanged,
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: histIronCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'الحديد',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: histCementCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'الإسمنت',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: histBlockCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'البلوك 15',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: histFormworkCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'الكوفراج',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: histAggregatesCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'المواد الحصوية',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: histWorkerCtrl,
                                        inputFormatters: [ThousandsFormatter()],
                                        decoration: const InputDecoration(
                                          labelText: 'أجرة العامل',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: _onInputChanged,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: amountController,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: InputDecoration(
                      labelText: isDollarPayment
                          ? 'المبلغ ${isDeposit ? "المدفوع" : "المسترد"} '
                              'بالدولار (USD)'
                          : 'المبلغ ${isDeposit ? "المدفوع" : "المسترد"} (ل.س)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        isDollarPayment ? Icons.monetization_on : Icons.payments,
                        color: isDollarPayment ? Colors.green : mainColor,
                      ),
                      filled: true,
                      fillColor: isDollarPayment
                          ? Colors.green.shade50
                          : (isDeposit ? Colors.white : Colors.red.shade50),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDollarPayment ? Colors.green : mainColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDollarPayment
                          ? Colors.green.shade900
                          : Colors.black87,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onInputChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountController,
                    decoration: InputDecoration(
                      labelText: isDeposit
                          ? 'نسبة الخصم / البونص المئوية'
                          : 'نسبة البونص المُراد استرجاعها',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixText: '%',
                      prefixIcon: Icon(Icons.percent, color: mainColor),
                      filled: true,
                      fillColor: isDeposit ? Colors.white : Colors.red.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onInputChanged,
                  ),
                  const SizedBox(height: 16),
                  if (enteredAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDeposit
                            ? Colors.blue.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDeposit
                              ? Colors.blue.shade200
                              : Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDollarPayment) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'يعادل بالليرة السورية:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormatters.formatWithCommas(sypEquivalentAmount)} '
                                    'ل.س',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            isDeposit
                                ? 'المبلغ النهائي (مع البونص):'
                                : 'الرقم الإجمالي الذي سيُخصم من الرصيد:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${isDeposit ? '' : '- '}'
                            '${NumberFormatters.formatWithCommas(effectiveAmount)} ل.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isDeposit
                                  ? Colors.blue.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                          if (calculatedMeterPrice > 0) ...[
                            const Divider(height: 24),
                            Text(
                              'سعر المتر المعتمد لعملية التحويل:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${NumberFormatters.formatWithCommas(calculatedMeterPrice)} ل.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isDeposit
                                  ? 'الأمتار المضافة لرصيد العميل:'
                                  : 'الأمتار المخصومة من رصيد العميل:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${isDeposit ? '+ ' : '- '}'
                              '${previewMeters.toStringAsFixed(3)} م²',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isDeposit
                                    ? Colors.green.shade700
                                    : Colors.red.shade800,
                              ),
                            ),
                          ] else ...[
                            const Divider(height: 24),
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'يرجى التأكد من إدخال تسعيرة المواد ليتمكن '
                                    'النظام من حساب الأمتار.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 18),
              label: Text(
                _isSaving
                    ? 'جاري الحفظ...'
                    : (isDeposit ? 'تأكيد وحفظ الدفعة' : 'تأكيد السحب'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _isSaving ||
                      !(enteredAmount > 0 &&
                          calculatedMeterPrice > 0 &&
                          (!isDollarPayment ||
                              (isDollarPayment &&
                                  (!isHistoricalPayment ||
                                      (isHistoricalPayment &&
                                          historicalDollarRate > 0)))))
                  ? null
                  : () async {
                      if (isHistoricalPayment) {
                        if (isDollarPayment &&
                            histDollarRateCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء إدخال السعر التاريخي!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!isDetailedMode && meterPriceCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء إدخال سعر المتر!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (isDetailedMode &&
                            (histIronCtrl.text.isEmpty ||
                                histCementCtrl.text.isEmpty ||
                                histWorkerCtrl.text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء إدخال أسعار المواد!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      setState(() => _isSaving = true);

                      try {
                        final finalAmountToSave = isDeposit
                            ? sypEquivalentAmount
                            : (sypEquivalentAmount * -1);

                        await context.read<PaymentsCubit>().addLedgerEntry(
                              contractId: widget.contractId,
                              amountPaid: finalAmountToSave,
                              discountPercentage: discountPct,
                              customDate: isHistoricalPayment
                                  ? selectedHistoricalDate
                                  : null,
                              customMeterPrice: isHistoricalPayment &&
                                      !isDetailedMode
                                  ? double.parse(
                                      meterPriceCtrl.text.replaceAll(',', ''),
                                    )
                                  : null,
                              histIron: isHistoricalPayment && isDetailedMode
                                  ? double.parse(
                                      histIronCtrl.text.replaceAll(',', ''),
                                    )
                                  : null,
                              histCement: isHistoricalPayment && isDetailedMode
                                  ? double.parse(
                                      histCementCtrl.text.replaceAll(',', ''),
                                    )
                                  : null,
                              histBlock: isHistoricalPayment && isDetailedMode
                                  ? double.parse(
                                      histBlockCtrl.text.replaceAll(',', ''),
                                    )
                                  : null,
                              histFormwork: isHistoricalPayment &&
                                      isDetailedMode
                                  ? double.parse(
                                      histFormworkCtrl.text
                                          .replaceAll(',', ''),
                                    )
                                  : null,
                              histAggregates: isHistoricalPayment &&
                                      isDetailedMode
                                  ? double.parse(
                                      histAggregatesCtrl.text
                                          .replaceAll(',', ''),
                                    )
                                  : null,
                              histWorker: isHistoricalPayment && isDetailedMode
                                  ? double.parse(
                                      histWorkerCtrl.text.replaceAll(',', ''),
                                    )
                                  : null,
                              histDollarRate:
                                  isHistoricalPayment && isDollarPayment
                                      ? historicalDollarRate
                                      : null,
                            );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(widget.parentContext)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                isDeposit
                                    ? 'تمت إضافة الدفعة بنجاح! ✅'
                                    : 'تم خصم المبلغ بنجاح! ✅',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } on Exception catch (e) {
                        if (mounted) {
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(widget.parentContext)
                              .showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            ),
          ],
        );
      },
    );
  }
}