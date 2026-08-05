// lib/contracts/view/add_contract_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  // 🌟 1. متغيرات التحكم بالخطوات (Stepper)
  int _currentStep = 0;

  bool _isSaving = false;
  String? selectedClientId;
  String selectedContractType = 'متخصص';
  String? selectedBuildingId;
  String? selectedApartmentId;

  final detailsController =
      TextEditingController(); // 🌟 تم إضافة هذا المتغير للوصف
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
    detailsController.dispose();
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

  // ==========================================
  // 🛡️ 2. أنظمة التحقق لكل خطوة (Step Validation)
  // ==========================================

  bool _validateStep1() {
    if (selectedClientId == null) {
      _showError('يرجى اختيار العميل (الفريق الثاني) أولاً.');
      return false;
    }
    if (isHistoricalContract) {
      if (_safeParseDouble(histIronCtrl) == 0 ||
          _safeParseDouble(histCementCtrl) == 0 ||
          _safeParseDouble(histWorkerCtrl) == 0) {
        _showError('الرجاء تعبئة أسعار المواد التاريخية الأساسية.');
        return false;
      }
    }
    return true;
  }

  bool _validateStep2() {
    final isAllocated = selectedContractType == 'متخصص';
    if (!isAllocated)
      return true; // لا يتطلب الشروط التالية إذا كان لاحق التخصص

    if (selectedApartmentId == null) {
      _showError('يرجى اختيار شقة من الكتالوج!');
      return false;
    }
    if (areaController.text.isEmpty) {
      _showError('المساحة غير متوفرة! يرجى التأكد من بيانات الشقة.');
      return false;
    }
    if (agreedHandoverDate == null) {
      _showError('يرجى تحديد الموعد المتفق عليه لتسليم الشقة!');
      return false;
    }
    if (isPenaltyActive) {
      if (_safeParseDouble(penaltyPctCtrl) <= 0) {
        _showError('نسبة الغرامة يجب أن تكون أكبر من صفر!');
        return false;
      }
      if (_safeParseInt(penaltyIntervalCtrl) <= 0) {
        _showError('مدة تطبيق الغرامة غير صالحة!');
        return false;
      }
    }
    return true;
  }

  bool _validateStep3() {
    if (priceController.text.isEmpty) {
      _showError('يرجى حساب سعر المتر أولاً بالضغط على زر "حساب سعر المتر"!');
      return false;
    }
    if (monthlyAmountCtrl.text.isEmpty) {
      _showError('يرجى إدخال القسط الشهري المتفق عليه!');
      return false;
    }
    if (isDollarContract &&
        isHistoricalContract &&
        histDollarRateCtrl.text.isEmpty) {
      _showError('الرجاء إدخال سعر صرف الدولار القديم!');
      return false;
    }
    return true;
  }

  // ==========================================
  // الدوال الهندسية والمالية
  // ==========================================

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
        final bldMap =
            jsonDecode(bld.directionCoefficients) as Map<String, dynamic>;
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
        final aptMap =
            jsonDecode(apt.customCoefficients) as Map<String, dynamic>;
        for (final entry in aptMap.entries) {
          final k = entry.key;
          if (!k.startsWith('مساحة') &&
              !k.contains('(متر)') &&
              !k.contains('(م2)')) {
            autoImportedCoefficients[k] = (entry.value as num).toDouble();
          }
        }
      } catch (e, stackTrace) {
        log('خطأ في قراءة المعاملات', error: e, stackTrace: stackTrace);
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

    MaterialPricesHistoryData targetPrices;
    if (isHistoricalContract) {
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
    priceController.text = NumberFormatters.formatWithCommas(
      calculations['pricePerSqm']!,
    );

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
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          return BlocBuilder<BuildingsCubit, BuildingsState>(
            builder: (context, buildingsState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  if (state.clients.isEmpty) {
                    return const Center(
                      child: Text(
                        'يرجى إضافة عميل أولاً من قسم العملاء.',
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

                  // ==========================================
                  // 🌟 3. تصميم واجهة الـ Stepper الجديدة
                  // ==========================================
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.teal.shade700,
                      ),
                    ),
                    child: Stepper(
                      type: StepperType
                          .horizontal, // أفقي ليتناسب مع شاشة الكمبيوتر
                      currentStep: _currentStep,
                      elevation: 0,
                      physics:
                          const ClampingScrollPhysics(), // لمنع التمرير الداخلي المزدوج
                      onStepTapped: (step) {
                        // السماح بالعودة للخلف فقط بدون تخطي الشروط للأمام
                        if (step < _currentStep) {
                          setState(() => _currentStep = step);
                        }
                      },
                      onStepContinue: () {
                        // التحقق قبل السماح بالانتقال للخطوة التالية
                        if (_currentStep == 0) {
                          if (_validateStep1()) setState(() => _currentStep++);
                        } else if (_currentStep == 1) {
                          if (_validateStep2()) setState(() => _currentStep++);
                        } else if (_currentStep == 2) {
                          if (_validateStep3())
                            _saveContract(); // الخطوة الأخيرة تقوم بالحفظ
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          Navigator.pop(
                            context,
                          ); // العودة للصفحة السابقة إذا كان في أول خطوة
                        }
                      },
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                            final isLastStep = _currentStep == 2;
                            return Container(
                              margin: const EdgeInsets.only(
                                top: 32,
                                bottom: 20,
                              ),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : details.onStepContinue,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            isLastStep
                                                ? Icons.check_circle
                                                : Icons.arrow_forward,
                                          ),
                                    label: Text(
                                      isLastStep
                                          ? 'اعتماد وتوقيع العقد'
                                          : 'التالي',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLastStep
                                          ? Colors.teal.shade700
                                          : Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (_currentStep > 0)
                                    OutlinedButton(
                                      onPressed: _isSaving
                                          ? null
                                          : details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text(
                                        'السابق',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                      steps: [
                        // --- الخطوة 1: البيانات الأساسية ---
                        Step(
                          title: const Text(
                            'البيانات الأساسية',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0
                              ? StepState.complete
                              : StepState.indexed,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    final isAuth = await showVerifyPinDialog(
                                      context,
                                    );
                                    if (isAuth && context.mounted) {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: selectedHistoricalDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      setState(() {
                                        isHistoricalContract = true;
                                        if (pickedDate != null)
                                          selectedHistoricalDate = pickedDate;
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
                                  if (pickedDate != null)
                                    setState(
                                      () => selectedHistoricalDate = pickedDate,
                                    );
                                },
                              ),
                              const SizedBox(height: 16),
                              BasicInfoSection(
                                clients: state.clients,
                                selectedClientId: selectedClientId,
                                guarantorController: guarantorController,
                                selectedContractType: selectedContractType,
                                onClientChanged: (val) =>
                                    setState(() => selectedClientId = val),
                                onTypeChanged: (val) {
                                  setState(() {
                                    selectedContractType = val ?? 'متخصص';
                                    if (selectedContractType != 'متخصص') {
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
                              // حقل الوصف الذي كان مفقوداً في النسخة الأصلية
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: TextField(
                                    controller: detailsController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'وصف العقد وملاحظات إضافية (اختياري)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Icons.edit_note,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- الخطوة 2: العقار والمواصفات ---
                        Step(
                          title: const Text(
                            'العقار والمواصفات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1
                              ? StepState.complete
                              : StepState.indexed,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                onApartmentChanged: (val) =>
                                    _onApartmentSelected(
                                      val,
                                      availableApartments,
                                      buildingsState.buildings,
                                    ),
                              ),
                              if (isAllocated) ...[
                                const SizedBox(height: 16),
                                _buildHandoverSection(), // قمنا بفصل قسم التسليم في دالة مساعدة لترتيب الكود
                                const SizedBox(height: 16),
                                AutoCoefficientsSection(
                                  coefficients: autoImportedCoefficients,
                                ),
                                SharedCoefficientsSection(
                                  blockCoeffCtrl: blockCoeffCtrl,
                                  coloredPlasterCoeffCtrl:
                                      coloredPlasterCoeffCtrl,
                                  marbleStairsCoeffCtrl: marbleStairsCoeffCtrl,
                                  marbleFinsCoeffCtrl: marbleFinsCoeffCtrl,
                                  plumbingCoeffCtrl: plumbingCoeffCtrl,
                                  chimneysCoeffCtrl: chimneysCoeffCtrl,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // --- الخطوة 3: الحساب المالي ---
                        Step(
                          title: const Text(
                            'الحساب المالي والاعتماد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          isActive: _currentStep >= 2,
                          state: _currentStep == 2
                              ? StepState.editing
                              : StepState.indexed,
                          content: FinancialSection(
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
                            onCalculate: () =>
                                _calculatePrice(settingsState.currentPrices),
                          ),
                        ),
                      ],
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

  // 🌟 فصل كود قسم التسليم لتنظيف الـ build
  Widget _buildHandoverSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'تفاصيل التسليم والشروط الجزائية',
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
                      initialDate: now.add(const Duration(days: 365)),
                      firstDate: now,
                      lastDate: DateTime(2050),
                      helpText: 'حدد الموعد للتسليم',
                    );
                    if (date != null) setState(() => agreedHandoverDate = date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'تاريخ التسليم المتوقع *',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.edit_calendar,
                        color: Colors.blue,
                      ),
                      errorText: agreedHandoverDate == null
                          ? 'مطلوب للمتابعة'
                          : null,
                    ),
                    child: Text(
                      agreedHandoverDate != null
                          ? '${agreedHandoverDate!.year}/${agreedHandoverDate!.month}/${agreedHandoverDate!.day}'
                          : 'اضغط لاختيار التاريخ',
                      style: TextStyle(
                        color: agreedHandoverDate != null
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
                    labelText: 'فترة السماح للمطور (أشهر)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.hourglass_empty, color: Colors.blue),
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
              'تفعيل غرامة التأخير (تُطبق على العميل بعد استلام المفتاح)',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: isPenaltyActive,
            activeThumbColor: Colors.deepOrange,
            onChanged: (val) => setState(() => isPenaltyActive = val),
            contentPadding: EdgeInsets.zero,
          ),
          if (isPenaltyActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: penaltyPctCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'نسبة الغرامة %',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.percent, color: Colors.deepOrange),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: penaltyIntervalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'تُطبق كل (أشهر)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.update, color: Colors.deepOrange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // دالة الحفظ النهائية (يتم استدعاؤها في الخطوة 3)
  // ==========================================
  Future<void> _saveContract() async {
    if (_isSaving) return;

    // تم التأكد مسبقاً من جميع الشروط بفضل الـ validation الخاص بالـ steps

    var exchangeRate = 1.0;
    if (isDollarContract) {
      if (isHistoricalContract) {
        exchangeRate = _safeParseDouble(histDollarRateCtrl);
      } else {
        final currentDollar = context
            .read<SettingsCubit>()
            .state
            .currentDollarPrice;
        if (currentDollar == null) {
          _showError('سعر الدولار غير متوفر! يرجى إضافته في الإعدادات.');
          return;
        }
        exchangeRate = currentDollar.exchangeRate;
      }
    }

    final agreedAmountSYP = _safeParseDouble(monthlyAmountCtrl) * exchangeRate;
    final finalDownPaymentSYP =
        _safeParseDouble(downPaymentCtrl) * exchangeRate;

    if (agreedAmountSYP <= 0) {
      _showError('المبلغ الشهري المتفق عليه يجب أن يكون أكبر من صفر!');
      return;
    }

    final uiDisplayedPrice = _safeParseDouble(priceController);
    var finalBasePriceToSend = uiDisplayedPrice;

    // امتصاص فجوات التقريب الطفيفة جداً
    if (_rawCalculatedPricePerSqm > 0 &&
        (uiDisplayedPrice - _rawCalculatedPricePerSqm).abs() < 20) {
      finalBasePriceToSend = _rawCalculatedPricePerSqm;
    }

    setState(() => _isSaving = true);

    try {
      final isAllocated = selectedContractType == 'متخصص';
      final finalCoeffs = _buildFinalCoefficients(isAllocated);

      var generatedDetails = detailsController.text.trim();
      if (isAllocated) {
        final allApartments = context.read<BuildingsCubit>().state.apartments;
        final buildings = context.read<BuildingsCubit>().state.buildings;
        final apt = allApartments.firstWhere(
          (a) => a.id == selectedApartmentId,
        );
        final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);

        final autoDetails =
            'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
        generatedDetails = generatedDetails.isEmpty
            ? autoDetails
            : '$autoDetails\nملاحظات: $generatedDetails';
      } else {
        generatedDetails = generatedDetails.isEmpty
            ? 'محفظة استثمارية (عقد لاحق التخصص)'
            : 'محفظة استثمارية\nملاحظات: $generatedDetails';
      }

      final finalArea = isAllocated ? _safeParseDouble(areaController) : 0.0;
      final finalMonths = isAllocated
          ? _safeParseInt(monthsController, defaultValue: 48)
          : 48;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري إنشاء العقد وحفظ الجداول الزمنية... ⏳'),
          backgroundColor: Colors.teal,
        ),
      );

      final applyPenalty = isAllocated && isPenaltyActive;
      final histDollar = (isHistoricalContract && isDollarContract)
          ? exchangeRate
          : null;

      await context.read<ContractsCubit>().addContract(
        clientId: selectedClientId!,
        contractType: selectedContractType,
        details: generatedDetails,
        apartmentId: isAllocated ? selectedApartmentId : null,
        area: finalArea,
        basePrice: finalBasePriceToSend,
        downPayment: finalDownPaymentSYP,
        installmentsCount: finalMonths,
        guarantorName: guarantorController.text.trim().isEmpty
            ? 'بدون كفيل'
            : guarantorController.text.trim(),
        agreedMonthlyAmount: agreedAmountSYP,
        coefficients: finalCoeffs,
        customDate: isHistoricalContract ? selectedHistoricalDate : null,
        agreedHandoverDate: isAllocated ? agreedHandoverDate : null,
        gracePeriodMonths: isAllocated ? _safeParseInt(gracePeriodCtrl) : null,
        isPenaltyActive: applyPenalty,
        penaltyPercentage: applyPenalty
            ? _safeParseDouble(penaltyPctCtrl)
            : 0.0,
        penaltyIntervalMonths: applyPenalty
            ? _safeParseInt(penaltyIntervalCtrl, defaultValue: 1)
            : 1,
        histIron: isHistoricalContract ? _safeParseDouble(histIronCtrl) : null,
        histCement: isHistoricalContract
            ? _safeParseDouble(histCementCtrl)
            : null,
        histBlock: isHistoricalContract
            ? _safeParseDouble(histBlockCtrl)
            : null,
        histFormwork: isHistoricalContract
            ? _safeParseDouble(histFormworkCtrl)
            : null,
        histAggregates: isHistoricalContract
            ? _safeParseDouble(histAggregatesCtrl)
            : null,
        histWorker: isHistoricalContract
            ? _safeParseDouble(histWorkerCtrl)
            : null,
        histDollarRate: histDollar,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('تم توقيع العقد بنجاح وتم توليد جدول الأقساط! 🎉');
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _isSaving = false);
        log('حدث خطأ أثناء توقيع العقد', error: e, stackTrace: stackTrace);
        _showError('حدث خطأ أثناء الحفظ: $e');
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
}
