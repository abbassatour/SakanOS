// lib/payments/widgets/dialogs/add_payment_dialog.dart

import 'dart:async';
import 'dart:convert';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/core/utils/calculator_helper.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/amount_input_section.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/currency_section.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/historical_section.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/live_preview_section.dart';
import 'package:our_home_erp_app/payments/widgets/add_payment_sections/payment_type_section.dart';
import 'package:our_home_erp_app/payments/widgets/dialogs/verify_pin_dialog.dart';
import 'package:our_home_erp_app/settings/cubit/settings_cubit.dart';

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
  // Controllers
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
            } on Exception catch (_) {
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
                  PaymentTypeSection(
                    isDeposit: isDeposit,
                    onDepositTapped: () => setState(() => isDeposit = true),
                    onWithdrawTapped: () async {
                      final authorized = await showVerifyPinDialog(
                        context: widget.parentContext,
                      );
                      if (!mounted) return;
                      if (!widget.parentContext.mounted) return;
                      if (authorized) {
                        setState(() => isDeposit = false);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CurrencySection(
                    isDollarPayment: isDollarPayment,
                    isHistoricalPayment: isHistoricalPayment,
                    currentDollarRate: currentDollar?.exchangeRate,
                    onToggle: (val) {
                      setState(() {
                        isDollarPayment = val;
                        amountController.clear();
                      });
                    },
                  ),
                  HistoricalSection(
                    isHistoricalPayment: isHistoricalPayment,
                    selectedHistoricalDate: selectedHistoricalDate,
                    isDollarPayment: isDollarPayment,
                    isDetailedMode: isDetailedMode,
                    histDollarRateCtrl: histDollarRateCtrl,
                    meterPriceCtrl: meterPriceCtrl,
                    histIronCtrl: histIronCtrl,
                    histCementCtrl: histCementCtrl,
                    histBlockCtrl: histBlockCtrl,
                    histFormworkCtrl: histFormworkCtrl,
                    histAggregatesCtrl: histAggregatesCtrl,
                    histWorkerCtrl: histWorkerCtrl,
                    onHistoricalToggle: (val) async {
                      if (val) {
                        final authorized = await showVerifyPinDialog(
                          context: widget.parentContext,
                        );
                        if (!mounted) return;
                        if (authorized) {
                          setState(() => isHistoricalPayment = true);
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedHistoricalDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (!mounted) return;
                          if (pickedDate != null) {
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
                    onDateSelected: (date) => setState(
                      () => selectedHistoricalDate = date,
                    ),
                    onDetailedModeToggle: (val) => setState(
                      () => isDetailedMode = val,
                    ),
                    onInputChanged: _onInputChanged,
                  ),
                  const SizedBox(height: 12),
                  AmountInputSection(
                    isDollarPayment: isDollarPayment,
                    isDeposit: isDeposit,
                    mainColor: mainColor,
                    amountController: amountController,
                    discountController: discountController,
                    onInputChanged: _onInputChanged,
                  ),
                  const SizedBox(height: 16),
                  LivePreviewSection(
                    enteredAmount: enteredAmount,
                    isDeposit: isDeposit,
                    isDollarPayment: isDollarPayment,
                    sypEquivalentAmount: sypEquivalentAmount,
                    effectiveAmount: effectiveAmount,
                    calculatedMeterPrice: calculatedMeterPrice,
                    previewMeters: previewMeters,
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
                          _showErrorSnackBar('الرجاء إدخال السعر التاريخي!');
                          return;
                        }
                        if (!isDetailedMode && meterPriceCtrl.text.isEmpty) {
                          _showErrorSnackBar('الرجاء إدخال سعر المتر!');
                          return;
                        }
                        if (isDetailedMode &&
                            (histIronCtrl.text.isEmpty ||
                                histCementCtrl.text.isEmpty ||
                                histWorkerCtrl.text.isEmpty)) {
                          _showErrorSnackBar('الرجاء إدخال أسعار المواد!');
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

                        if (!mounted) return;
                        if (!widget.parentContext.mounted) return;

                        Navigator.pop(context);
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              isDeposit
                                  ? 'تمت إضافة الدفعة بنجاح! ✅'
                                  : 'تم خصم المبلغ بنجاح! ✅',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } on Exception catch (e) {
                        if (!mounted) return;
                        setState(() => _isSaving = false);

                        if (!widget.parentContext.mounted) return;
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
            ),
          ],
        );
      },
    );
  }
}