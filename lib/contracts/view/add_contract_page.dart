// lib/contracts/view/add_contract_page.dart
// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: depend_on_referenced_packages, reason: Needed for calculation models
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building, MaterialPricesHistoryData;

import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';
import 'package:our_home_erp_app/contracts/contracts.dart';
import 'package:our_home_erp_app/contracts/widgets/widgets.dart';
import 'package:our_home_erp_app/core/utils/calculator_helper.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/settings/cubit/settings_cubit.dart';

class AddContractPage extends StatefulWidget {
  const AddContractPage({super.key});

  @override
  State<AddContractPage> createState() => _AddContractPageState();
}

class _AddContractPageState extends State<AddContractPage> {
  bool _isSaving = false;
  String? selectedClientId;
  String selectedContractType = 'متخصص';
  String? selectedBuildingId;
  String? selectedApartmentId;

  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final monthsController = TextEditingController(text: '48');
  final durationCoefficientCtrl = TextEditingController(text: '0');
  final guarantorController = TextEditingController();
  final monthlyAmountCtrl = TextEditingController();
  final downPaymentCtrl = TextEditingController(text: '0');

  DateTime? agreedHandoverDate;
  final gracePeriodCtrl = TextEditingController(text: '0');

  bool isPenaltyActive = false;
  final penaltyPctCtrl = TextEditingController(text: '2');
  final penaltyIntervalCtrl = TextEditingController(text: '1');

  final blockCoeffCtrl = TextEditingController(text: '0');
  final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
  final marbleStairsCoeffCtrl = TextEditingController(text: '0');
  final marbleFinsCoeffCtrl = TextEditingController(text: '0');
  final plumbingCoeffCtrl = TextEditingController(text: '0');
  final chimneysCoeffCtrl = TextEditingController(text: '0');

  final histIronCtrl = TextEditingController();
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  bool isDollarContract = false;
  final histDollarRateCtrl = TextEditingController();

  Map<String, double> autoImportedCoefficients = {};
  bool isHistoricalContract = false;
  DateTime selectedHistoricalDate = DateTime.now();

  double _rawCalculatedPricePerSqm = 0;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<BuildingsCubit>().loadData());
    final clients = context.read<ContractsCubit>().state.clients;
    if (clients.isNotEmpty) selectedClientId = clients.first.id;
  }

  @override
  void dispose() {
    areaController.dispose();
    priceController.dispose();
    monthsController.dispose();
    durationCoefficientCtrl.dispose();
    guarantorController.dispose();
    monthlyAmountCtrl.dispose();
    downPaymentCtrl.dispose();
    gracePeriodCtrl.dispose();
    penaltyPctCtrl.dispose();
    penaltyIntervalCtrl.dispose();
    blockCoeffCtrl.dispose();
    coloredPlasterCoeffCtrl.dispose();
    marbleStairsCoeffCtrl.dispose();
    marbleFinsCoeffCtrl.dispose();
    plumbingCoeffCtrl.dispose();
    chimneysCoeffCtrl.dispose();
    histIronCtrl.dispose();
    histCementCtrl.dispose();
    histBlockCtrl.dispose();
    histFormworkCtrl.dispose();
    histAggregatesCtrl.dispose();
    histWorkerCtrl.dispose();
    histDollarRateCtrl.dispose();
    super.dispose();
  }

  double _safeParseDouble(TextEditingController ctrl) {
    if (ctrl.text.trim().isEmpty) return 0;
    return double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;
  }

  int _safeParseInt(TextEditingController ctrl, {int defaultValue = 0}) {
    if (ctrl.text.trim().isEmpty) return defaultValue;
    return int.tryParse(ctrl.text.replaceAll(',', '')) ?? defaultValue;
  }

  void _onApartmentSelected(
    String? aptId,
    List<Apartment> availableApartments,
    List<Building> buildings,
  ) {
    setState(() {
      selectedApartmentId = aptId;
      if (aptId == null) return;

      final apt = availableApartments.firstWhere((a) => a.id == aptId);
      final bld = buildings.firstWhere((b) => b.id == apt.buildingId);

      areaController.text = apt.area.toString();
      autoImportedCoefficients.clear();

      try {
        final bldMap = jsonDecode(
          bld.directionCoefficients,
        ) as Map<String, dynamic>;

        for (final entry in bldMap.entries) {
          final k = entry.key;
          if (k != 'شمالي' &&
              k != 'جنوبي' &&
              k != 'شرقي' &&
              k != 'غربي' &&
              k != 'المصعد') {
            autoImportedCoefficients[k] = (entry.value as num).toDouble();
          }
        }

        final aptMap = jsonDecode(
          apt.customCoefficients,
        ) as Map<String, dynamic>;

        for (final entry in aptMap.entries) {
          final k = entry.key;
          if (!k.startsWith('مساحة') &&
              !k.contains('(متر)') &&
              !k.contains('(م2)')) {
            autoImportedCoefficients[k] = (entry.value as num).toDouble();
          }
        }
      } on Object catch (e) {
        debugPrint('خطأ في قراءة المعاملات: $e');
      }
    });
  }

  Map<String, double> _buildFinalCoefficients(bool isAllocated) {
    final finalCoeffs = <String, double>{};
    if (!isAllocated) return finalCoeffs;

    for (final entry in autoImportedCoefficients.entries) {
      finalCoeffs[entry.key] = entry.value / 100.0;
    }

    final durVal = _safeParseDouble(durationCoefficientCtrl);
    if (durVal != 0) finalCoeffs['نسبة التقسيط'] = durVal / 100.0;

    void addSharedCoeff(String key, TextEditingController ctrl) {
      final val = _safeParseDouble(ctrl);
      if (val != 0) finalCoeffs[key] = val / 100.0;
    }

    addSharedCoeff('بلوك معزول', blockCoeffCtrl);
    addSharedCoeff('طينة ملونة', coloredPlasterCoeffCtrl);
    addSharedCoeff('أدراج رخام', marbleStairsCoeffCtrl);
    addSharedCoeff('زعانف رخام', marbleFinsCoeffCtrl);
    addSharedCoeff('تمديد صحي', plumbingCoeffCtrl);
    addSharedCoeff('مداخن', chimneysCoeffCtrl);

    return finalCoeffs;
  }

  void _calculatePrice(MaterialPricesHistoryData? currentPrices) {
    final isAllocated = selectedContractType == 'متخصص';

    if (isAllocated && areaController.text.isEmpty) {
      _showError('البيانات غير مكتملة! أدخل المساحة.');
      return;
    }

    MaterialPricesHistoryData targetPrices;
    if (isHistoricalContract) {
      if (_safeParseDouble(histIronCtrl) == 0 ||
          _safeParseDouble(histCementCtrl) == 0 ||
          _safeParseDouble(histWorkerCtrl) == 0) {
        _showError('الرجاء تعبئة أسعار المواد التاريخية الأساسية بشكل صحيح!');
        return;
      }
      targetPrices = MaterialPricesHistoryData(
        id: 'dummy',
        effectiveDate: selectedHistoricalDate,
        userId: 'dummy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        isSynced: false,
        ironPrice: _safeParseDouble(histIronCtrl),
        cementPrice: _safeParseDouble(histCementCtrl),
        block15Price: _safeParseDouble(histBlockCtrl),
        formworkAndPouringWages: _safeParseDouble(histFormworkCtrl),
        aggregateMaterialsPrice: _safeParseDouble(histAggregatesCtrl),
        ordinaryWorkerWage: _safeParseDouble(histWorkerCtrl),
      );
    } else {
      if (currentPrices == null) {
        _showError('يرجى ضبط أسعار المواد في الإعدادات أولاً.');
        return;
      }
      targetPrices = currentPrices;
    }

    final finalCoeffs = _buildFinalCoefficients(isAllocated);
    var dummyArea = isAllocated ? _safeParseDouble(areaController) : 1.0;
    if (dummyArea == 0) dummyArea = 1.0;

    final calculations = CalculatorHelper.calculateContractValues(
      area: dummyArea,
      currentPrices: targetPrices,
      coefficients: finalCoeffs,
    );

    _rawCalculatedPricePerSqm =
        calculations['pricePerSqmRaw'] ?? calculations['pricePerSqm']!;

    priceController.text =
        NumberFormatters.formatWithCommas(calculations['pricePerSqm']!);

    _showSuccess(
      isHistoricalContract
          ? 'تم الحساب بناءً على المواد التاريخية ✅'
          : 'تم الحساب بناءً على أسعار اليوم ✅',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'توقيع عقد جديد',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade600,
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          return BlocBuilder<BuildingsCubit, BuildingsState>(
            builder: (context, buildingsState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  if (state.clients.isEmpty) {
                    return const Center(
                      child: Text(
                        'يرجى إضافة عميل أولاً.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final isAllocated = selectedContractType == 'متخصص';
                  final availableApartments = buildingsState.apartments
                      .where(
                        (apt) =>
                            apt.buildingId == selectedBuildingId &&
                            apt.status == 'available',
                      )
                      .toList();

                  return Center(
                    child: SizedBox(
                      width: 800,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          HistoricalSection(
                            isHistorical: isHistoricalContract,
                            selectedDate: selectedHistoricalDate,
                            histIronCtrl: histIronCtrl,
                            histCementCtrl: histCementCtrl,
                            histBlockCtrl: histBlockCtrl,
                            histFormworkCtrl: histFormworkCtrl,
                            histAggregatesCtrl: histAggregatesCtrl,
                            histWorkerCtrl: histWorkerCtrl,
                            onToggle: (val) async {
                              if (val) {
                                final isAuth =
                                    await showVerifyPinDialog(context);
                                if (isAuth && context.mounted) {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedHistoricalDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  setState(() {
                                    isHistoricalContract = true;
                                    if (pickedDate != null) {
                                      selectedHistoricalDate = pickedDate;
                                    }
                                  });
                                }
                              } else {
                                setState(() {
                                  isHistoricalContract = false;
                                  priceController.clear();
                                  _rawCalculatedPricePerSqm = 0;
                                });
                              }
                            },
                            onDateTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedHistoricalDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(
                                  () => selectedHistoricalDate = pickedDate,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          BasicInfoSection(
                            clients: state.clients,
                            selectedClientId: selectedClientId,
                            guarantorController: guarantorController,
                            selectedContractType: selectedContractType,
                            onClientChanged: (val) {
                              setState(() => selectedClientId = val);
                            },
                            onTypeChanged: (val) {
                              setState(() {
                                selectedContractType = val ?? 'متخصص';
                                if (!isAllocated) {
                                  autoImportedCoefficients.clear();
                                  selectedBuildingId = null;
                                  selectedApartmentId = null;
                                  areaController.clear();
                                  agreedHandoverDate = null;
                                  isPenaltyActive = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          PropertySection(
                            isAllocated: isAllocated,
                            buildings: buildingsState.buildings,
                            availableApartments: availableApartments,
                            selectedBuildingId: selectedBuildingId,
                            selectedApartmentId: selectedApartmentId,
                            onBuildingChanged: (val) {
                              setState(() {
                                selectedBuildingId = val;
                                selectedApartmentId = null;
                                areaController.clear();
                                autoImportedCoefficients.clear();
                              });
                            },
                            onApartmentChanged: (val) => _onApartmentSelected(
                              val,
                              availableApartments,
                              buildingsState.buildings,
                            ),
                          ),
                          if (isAllocated) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.key,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تفاصيل تسليم الشقة',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: now.add(
                                                const Duration(days: 365),
                                              ),
                                              firstDate: now,
                                              lastDate: DateTime(2050),
                                              helpText: 'حدد الموعد للتسليم',
                                            );
                                            if (date != null) {
                                              setState(() {
                                                agreedHandoverDate = date;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'تاريخ التسليم *',
                                              border:
                                                  const OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: const Icon(
                                                Icons.edit_calendar,
                                                color: Colors.blue,
                                              ),
                                              errorText:
                                                  agreedHandoverDate == null
                                                      ? 'مطلوب للإحصائيات'
                                                      : null,
                                            ),
                                            child: Text(
                                              agreedHandoverDate != null
                                                  ? '${agreedHandoverDate!.year}/'
                                                      '${agreedHandoverDate!.month}/'
                                                      '${agreedHandoverDate!.day}'
                                                  : 'اضغط لاختيار التاريخ',
                                              style: TextStyle(
                                                color:
                                                    agreedHandoverDate != null
                                                        ? Colors.black
                                                        : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: gracePeriodCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'فترة السماح',
                                            suffixText: 'أشهر',
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            prefixIcon: Icon(
                                              Icons.hourglass_empty,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(color: Colors.blueGrey),
                                  ),
                                  SwitchListTile(
                                    title: const Text(
                                      'تفعيل غرامة التأخير (بعد الاستلام)',
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'يتم فرض نسبة مئوية تتراكم مع الزمن '
                                      'في حال بقاء ذمم مالية.',
                                    ),
                                    value: isPenaltyActive,
                                    activeThumbColor: Colors.deepOrange,
                                    onChanged: (val) {
                                      setState(() => isPenaltyActive = val);
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (isPenaltyActive) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: penaltyPctCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'نسبة الغرامة',
                                              suffixText: '%',
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: Icon(
                                                Icons.percent,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: penaltyIntervalCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'تُطبق كل',
                                              suffixText: 'أشهر',
                                              border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: Icon(
                                                Icons.update,
                                                color: Colors.deepOrange,
                                              ),
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
                          const SizedBox(height: 16),
                          if (isAllocated)
                            AutoCoefficientsSection(
                              coefficients: autoImportedCoefficients,
                            ),
                          if (isAllocated)
                            SharedCoefficientsSection(
                              blockCoeffCtrl: blockCoeffCtrl,
                              coloredPlasterCoeffCtrl: coloredPlasterCoeffCtrl,
                              marbleStairsCoeffCtrl: marbleStairsCoeffCtrl,
                              marbleFinsCoeffCtrl: marbleFinsCoeffCtrl,
                              plumbingCoeffCtrl: plumbingCoeffCtrl,
                              chimneysCoeffCtrl: chimneysCoeffCtrl,
                            ),
                          FinancialSection(
                            isAllocated: isAllocated,
                            isHistoricalContract: isHistoricalContract,
                            isDollarContract: isDollarContract,
                            histDollarRateCtrl: histDollarRateCtrl,
                            currentDollarRate:
                                settingsState.currentDollarPrice?.exchangeRate,
                            onDollarToggle: (val) {
                              setState(() {
                                isDollarContract = val;
                                downPaymentCtrl.clear();
                                monthlyAmountCtrl.clear();
                              });
                            },
                            onInputChanged: (_) => setState(() {}),
                            areaController: areaController,
                            monthsController: monthsController,
                            durationCoefficientCtrl: durationCoefficientCtrl,
                            priceController: priceController,
                            monthlyAmountCtrl: monthlyAmountCtrl,
                            downPaymentCtrl: downPaymentCtrl,
                            onCalculate: () {
                              _calculatePrice(settingsState.currentPrices);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text(
              'إلغاء والتراجع',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              _isSaving ? 'جاري الحفظ...' : 'اعتماد وتوقيع العقد',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: _isSaving ? null : _saveContract,
          ),
        ],
      ),
    );
  }

  Future<void> _saveContract() async {
    if (_isSaving) return;

    final isAllocated = selectedContractType == 'متخصص';

    if (isAllocated && selectedApartmentId == null) {
      return _showError('يرجى اختيار شقة من الكتالوج!');
    }
    if (isAllocated && areaController.text.isEmpty) {
      return _showError('يرجى تعبئة المساحة!');
    }
    if (isAllocated && agreedHandoverDate == null) {
      return _showError('يرجى تحديد الموعد المتفق عليه لتسليم الشقة!');
    }

    if (isAllocated && isPenaltyActive) {
      if (_safeParseDouble(penaltyPctCtrl) <= 0) {
        return _showError('نسبة الغرامة يجب أن تكون أكبر من صفر!');
      }
      if (_safeParseInt(penaltyIntervalCtrl) <= 0) {
        return _showError('مدة تطبيق الغرامة غير صالحة!');
      }
    }

    if (priceController.text.isEmpty) {
      return _showError('يرجى حساب السعر أولاً!');
    }
    if (monthlyAmountCtrl.text.isEmpty) {
      return _showError('يرجى إدخال المبلغ المتفق عليه شهرياً!');
    }

    if (isDollarContract &&
        isHistoricalContract &&
        histDollarRateCtrl.text.isEmpty) {
      return _showError('الرجاء إدخال سعر صرف الدولار القديم!');
    }

    var exchangeRate = 1.0;
    if (isDollarContract) {
      if (isHistoricalContract) {
        exchangeRate = _safeParseDouble(histDollarRateCtrl);
      } else {
        final currentDollar =
            context.read<SettingsCubit>().state.currentDollarPrice;
        if (currentDollar == null) {
          return _showError('سعر الدولار غير متوفر! يرجى إضافته.');
        }
        exchangeRate = currentDollar.exchangeRate;
      }
    }

    final agreedAmountSYP = _safeParseDouble(monthlyAmountCtrl) * exchangeRate;
    final finalDownPaymentSYP =
        _safeParseDouble(downPaymentCtrl) * exchangeRate;

    if (agreedAmountSYP <= 0) {
      return _showError('المبلغ الشهري يجب أن يكون أكبر من صفر!');
    }

    final uiDisplayedPrice = _safeParseDouble(priceController);
    var finalBasePriceToSend = uiDisplayedPrice;

    if (_rawCalculatedPricePerSqm > 0 &&
        (uiDisplayedPrice - _rawCalculatedPricePerSqm).abs() < 20) {
      finalBasePriceToSend = _rawCalculatedPricePerSqm;
    }

    setState(() => _isSaving = true);

    try {
      final finalCoeffs = _buildFinalCoefficients(isAllocated);

      var generatedDetails = '';
      if (isAllocated) {
        final allApartments = context.read<BuildingsCubit>().state.apartments;
        final buildings = context.read<BuildingsCubit>().state.buildings;
        final apt =
            allApartments.firstWhere((a) => a.id == selectedApartmentId);
        final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
        generatedDetails =
            'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | '
            'طابق: ${apt.floorName}';
      } else {
        generatedDetails = 'محفظة استثمارية (عقد لاحق التخصص)';
      }

      final finalArea = isAllocated ? _safeParseDouble(areaController) : 0.0;
      final finalMonths =
          isAllocated ? _safeParseInt(monthsController, defaultValue: 48) : 48;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري الحفظ وتوقيع العقد... ⏳'),
          backgroundColor: Colors.teal,
        ),
      );

      final applyPenalty = isAllocated && isPenaltyActive;
      final histDollar =
          (isHistoricalContract && isDollarContract) ? exchangeRate : null;

      await context.read<ContractsCubit>().addContract(
            clientId: selectedClientId!,
            contractType: selectedContractType,
            details: generatedDetails,
            apartmentId: isAllocated ? selectedApartmentId : null,
            area: finalArea,
            basePrice: finalBasePriceToSend,
            downPayment: finalDownPaymentSYP,
            installmentsCount: finalMonths,
            guarantorName: guarantorController.text.trim(),
            agreedMonthlyAmount: agreedAmountSYP,
            coefficients: finalCoeffs,
            customDate: isHistoricalContract ? selectedHistoricalDate : null,
            agreedHandoverDate: isAllocated ? agreedHandoverDate : null,
            gracePeriodMonths:
                isAllocated ? _safeParseInt(gracePeriodCtrl) : null,
            isPenaltyActive: applyPenalty,
            penaltyPercentage:
                applyPenalty ? _safeParseDouble(penaltyPctCtrl) : 0.0,
            penaltyIntervalMonths: applyPenalty
                ? _safeParseInt(penaltyIntervalCtrl, defaultValue: 1)
                : 1,
            histIron:
                isHistoricalContract ? _safeParseDouble(histIronCtrl) : null,
            histCement:
                isHistoricalContract ? _safeParseDouble(histCementCtrl) : null,
            histBlock:
                isHistoricalContract ? _safeParseDouble(histBlockCtrl) : null,
            histFormwork: isHistoricalContract
                ? _safeParseDouble(histFormworkCtrl)
                : null,
            histAggregates: isHistoricalContract
                ? _safeParseDouble(histAggregatesCtrl)
                : null,
            histWorker:
                isHistoricalContract ? _safeParseDouble(histWorkerCtrl) : null,
            histDollarRate: histDollar,
          );

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('تم توقيع العقد بنجاح! ✅');
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('حدث خطأ أثناء الحفظ: $e');
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }
}

