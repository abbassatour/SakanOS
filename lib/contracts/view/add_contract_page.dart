// lib/contracts/view/add_contract_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import '../../core/utils/calculator_helper.dart';
import '../../core/utils/formatters.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';
import '../cubit/contracts_cubit.dart';
import 'dialogs/verify_pin_dialog.dart';

import 'widgets/add_contract/historical_section.dart';
import 'widgets/add_contract/basic_info_section.dart';
import 'widgets/add_contract/auto_coefficients_section.dart';
import 'widgets/add_contract/shared_coefficients_section.dart';
import 'widgets/add_contract/property_section.dart';
import 'widgets/add_contract/financial_section.dart';

class AddContractPage extends StatefulWidget {
  const AddContractPage({super.key});

  @override
  State<AddContractPage> createState() => _AddContractPageState();
}

class _AddContractPageState extends State<AddContractPage> {
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

  // 🌟[الإضافة الجديدة]: متغيرات الاستلام
  DateTime? agreedHandoverDate; 
  final gracePeriodCtrl = TextEditingController(text: '0');

  // معاملات إضافية للتجهيزات المشتركة
  final blockCoeffCtrl = TextEditingController(text: '0');
  final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
  final marbleStairsCoeffCtrl = TextEditingController(text: '0');
  final marbleFinsCoeffCtrl = TextEditingController(text: '0');
  final plumbingCoeffCtrl = TextEditingController(text: '0');
  final chimneysCoeffCtrl = TextEditingController(text: '0');

  // معاملات التاريخ
  final histIronCtrl = TextEditingController();
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  Map<String, double> autoImportedCoefficients = {};
  bool isHistoricalContract = false;
  DateTime selectedHistoricalDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<BuildingsCubit>().loadData();
    final clients = context.read<ContractsCubit>().state.clients;
    if (clients.isNotEmpty) selectedClientId = clients.first.id;
  }

  @override
  void dispose() {
    areaController.dispose(); priceController.dispose(); monthsController.dispose();
    durationCoefficientCtrl.dispose(); guarantorController.dispose(); monthlyAmountCtrl.dispose();
    downPaymentCtrl.dispose(); 
    gracePeriodCtrl.dispose(); // 🌟 تنظيف متحكم فترة السماح
    blockCoeffCtrl.dispose(); coloredPlasterCoeffCtrl.dispose(); marbleStairsCoeffCtrl.dispose();
    marbleFinsCoeffCtrl.dispose(); plumbingCoeffCtrl.dispose(); chimneysCoeffCtrl.dispose();
    histIronCtrl.dispose(); histCementCtrl.dispose(); histBlockCtrl.dispose();
    histFormworkCtrl.dispose(); histAggregatesCtrl.dispose(); histWorkerCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // 🛡️ دوال الحماية 
  // ==========================================
  double _safeParseDouble(TextEditingController ctrl) {
    if (ctrl.text.trim().isEmpty) return 0.0;
    return double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0.0;
  }

  int _safeParseInt(TextEditingController ctrl, {int defaultValue = 0}) {
    if (ctrl.text.trim().isEmpty) return defaultValue;
    return int.tryParse(ctrl.text.replaceAll(',', '')) ?? defaultValue;
  }

  // --- دوال المنطق ---
  void _onApartmentSelected(String? aptId, List<dynamic> availableApartments, List<dynamic> buildings) {
    setState(() {
      selectedApartmentId = aptId;
      if (aptId != null) {
        final apt = availableApartments.firstWhere((a) => a.id == aptId);
        final bld = buildings.firstWhere((b) => b.id == apt.buildingId);
        areaController.text = apt.area.toString();
        autoImportedCoefficients.clear();
        try {
          final Map<String, dynamic> bldGeneralMap = jsonDecode(bld.directionCoefficients);
          bldGeneralMap.forEach((k, v) {
            if (k != 'شمالي' && k != 'جنوبي' && k != 'شرقي' && k != 'غربي' && k != 'المصعد') {
              autoImportedCoefficients[k] = (v as num).toDouble();
            }
          });
          
          final Map<String, dynamic> aptMap = jsonDecode(apt.customCoefficients);
          aptMap.forEach((k, v) {
            if (!k.startsWith('مساحة') && !k.contains('(متر)') && !k.contains('(م2)')) {
              autoImportedCoefficients[k] = (v as num).toDouble();
            }
          });
        } catch (e) { 
          debugPrint('خطأ في قراءة المعاملات: $e'); 
        }
      }
    });
  }

  Map<String, double> _buildFinalCoefficients(bool isAllocated) {
    Map<String, double> finalCoeffs = {};
    if (!isAllocated) return finalCoeffs; 

    autoImportedCoefficients.forEach((key, value) => finalCoeffs[key] = value / 100.0);

    double durVal = _safeParseDouble(durationCoefficientCtrl);
    if (durVal != 0.0) finalCoeffs['نسبة التقسيط'] = durVal / 100.0;

    void addSharedCoeff(String key, TextEditingController ctrl) {
      double val = _safeParseDouble(ctrl);
      if (val != 0.0) finalCoeffs[key] = val / 100.0;
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
    bool isAllocated = selectedContractType == 'متخصص';

    if (isAllocated && areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('البيانات غير مكتملة! أدخل المساحة.'), backgroundColor: Colors.red));
      return;
    }

    MaterialPricesHistoryData targetPrices;
    if (isHistoricalContract) {
      if (_safeParseDouble(histIronCtrl) == 0 || _safeParseDouble(histCementCtrl) == 0 || _safeParseDouble(histWorkerCtrl) == 0) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة أسعار المواد التاريخية الأساسية بشكل صحيح!'), backgroundColor: Colors.red));
         return;
      }
      
      targetPrices = MaterialPricesHistoryData(
        id: 'dummy', effectiveDate: selectedHistoricalDate, userId: 'dummy', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false, isSynced: false,
        ironPrice: _safeParseDouble(histIronCtrl), 
        cementPrice: _safeParseDouble(histCementCtrl),
        block15Price: _safeParseDouble(histBlockCtrl), 
        formworkAndPouringWages: _safeParseDouble(histFormworkCtrl),
        aggregateMaterialsPrice: _safeParseDouble(histAggregatesCtrl), 
        ordinaryWorkerWage: _safeParseDouble(histWorkerCtrl),
      );
    } else {
      if (currentPrices == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ضبط أسعار المواد في الإعدادات أولاً.'), backgroundColor: Colors.red));
        return;
      }
      targetPrices = currentPrices;
    }

    Map<String, double> finalCoeffs = _buildFinalCoefficients(isAllocated);

    double dummyAreaForCalculation = isAllocated ? _safeParseDouble(areaController) : 1.0;
    if (dummyAreaForCalculation == 0.0) dummyAreaForCalculation = 1.0; 

    final calculations = CalculatorHelper.calculateContractValues(
      area: dummyAreaForCalculation,
      currentPrices: targetPrices,
      coefficients: finalCoeffs, 
    );
    priceController.text = NumberFormatters.formatWithCommas(calculations['pricePerSqm']!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isHistoricalContract ? 'تم الحساب بناءً على المواد التاريخية ✅' : 'تم الحساب بناءً على أسعار اليوم ✅'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('توقيع عقد جديد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.teal.shade600, centerTitle: true),
      bottomNavigationBar: _buildBottomBar(context),
      
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          return BlocBuilder<BuildingsCubit, BuildingsState>(
            builder: (context, buildingsState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  if (state.clients.isEmpty) return const Center(child: Text('يرجى إضافة عميل أولاً.', style: TextStyle(fontSize: 18)));

                  bool isAllocated = selectedContractType == 'متخصص'; 
                  final availableApartments = buildingsState.apartments.where((apt) => apt.buildingId == selectedBuildingId && apt.status == 'available').toList();

                  return Center(
                    child: SizedBox(
                      width: 800,
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children:[
                          HistoricalSection(
                            isHistorical: isHistoricalContract,
                            selectedDate: selectedHistoricalDate,
                            histIronCtrl: histIronCtrl, histCementCtrl: histCementCtrl, histBlockCtrl: histBlockCtrl,
                            histFormworkCtrl: histFormworkCtrl, histAggregatesCtrl: histAggregatesCtrl, histWorkerCtrl: histWorkerCtrl,
                            onToggle: (val) async {
                              if (val) {
                                if (await showVerifyPinDialog(context)) {
                                  final pickedDate = await showDatePicker(context: context, initialDate: selectedHistoricalDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                                  setState(() { isHistoricalContract = true; if (pickedDate != null) selectedHistoricalDate = pickedDate; });
                                }
                              } else {
                                setState(() { isHistoricalContract = false; priceController.clear(); });
                              }
                            },
                            onDateTap: () async {
                              final pickedDate = await showDatePicker(context: context, initialDate: selectedHistoricalDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                              if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          BasicInfoSection(
                            clients: state.clients,
                            selectedClientId: selectedClientId,
                            guarantorController: guarantorController,
                            selectedContractType: selectedContractType,
                            onClientChanged: (val) => setState(() => selectedClientId = val),
                            onTypeChanged: (val) {
                              setState(() {
                                selectedContractType = val ?? 'متخصص';
                                if (!isAllocated) { 
                                  autoImportedCoefficients.clear(); 
                                  selectedBuildingId = null; 
                                  selectedApartmentId = null; 
                                  areaController.clear(); 
                                  agreedHandoverDate = null; // تفريغ التاريخ عند تغيير النوع
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
                            onBuildingChanged: (val) => setState(() { selectedBuildingId = val; selectedApartmentId = null; areaController.clear(); autoImportedCoefficients.clear(); }),
                            onApartmentChanged: (val) => _onApartmentSelected(val, availableApartments, buildingsState.buildings),
                          ),
                          
                          // ==========================================
                          // 🌟[القسم الجديد]: تفاصيل التسليم
                          // ==========================================
                          if (isAllocated) ...[
                            const SizedBox(height: 16),
                            Container(
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
                                    children:[
                                      Icon(Icons.key, color: Colors.blue.shade700),
                                      const SizedBox(width: 8),
                                      Text('تفاصيل تسليم الشقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade800)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children:[
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now().add(const Duration(days: 365)), // افتراضياً بعد سنة
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2050),
                                              helpText: 'حدد الموعد المتفق عليه لتسليم الشقة',
                                            );
                                            if (date != null) setState(() => agreedHandoverDate = date);
                                          },
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'الموعد المتفق عليه للتسليم *',
                                              border: const OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: const Icon(Icons.edit_calendar, color: Colors.blue),
                                              errorText: agreedHandoverDate == null ? 'مطلوب للإحصائيات' : null,
                                            ),
                                            child: Text(
                                              agreedHandoverDate != null 
                                                  ? '${agreedHandoverDate!.year}/${agreedHandoverDate!.month}/${agreedHandoverDate!.day}'
                                                  : 'اضغط لاختيار التاريخ',
                                              style: TextStyle(
                                                color: agreedHandoverDate != null ? Colors.black : Colors.red, 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: gracePeriodCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'فترة السماح',
                                            suffixText: 'أشهر',
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                            prefixIcon: Icon(Icons.hourglass_empty, color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          if (isAllocated)
                            AutoCoefficientsSection(coefficients: autoImportedCoefficients),

                          if (isAllocated)
                            SharedCoefficientsSection(
                              blockCoeffCtrl: blockCoeffCtrl, coloredPlasterCoeffCtrl: coloredPlasterCoeffCtrl,
                              marbleStairsCoeffCtrl: marbleStairsCoeffCtrl, marbleFinsCoeffCtrl: marbleFinsCoeffCtrl,
                              plumbingCoeffCtrl: plumbingCoeffCtrl, chimneysCoeffCtrl: chimneysCoeffCtrl,
                            ),
                          
                          FinancialSection(
                            isAllocated: isAllocated,
                            isHistoricalContract: isHistoricalContract,
                            areaController: areaController,
                            monthsController: monthsController,
                            durationCoefficientCtrl: durationCoefficientCtrl,
                            priceController: priceController,
                            monthlyAmountCtrl: monthlyAmountCtrl,
                            downPaymentCtrl: downPaymentCtrl, 
                            onCalculate: () => _calculatePrice(settingsState.currentPrices),
                          ),
                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  );
                }
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow:[BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء والتراجع', style: TextStyle(fontSize: 16, color: Colors.grey))),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)),
            icon: const Icon(Icons.check_circle),
            label: const Text('اعتماد وتوقيع العقد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: _saveContract,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🚀 دالة الإرسال والحفظ للـ Backend
  // ==========================================
  Future<void> _saveContract() async {
    bool isAllocated = selectedContractType == 'متخصص'; 
    
    if (isAllocated && selectedApartmentId == null) return _showError('يرجى اختيار شقة من الكتالوج!');
    if (isAllocated && areaController.text.isEmpty) return _showError('يرجى تعبئة المساحة!');
    
    // 🌟 حماية إضافية: إجبار المستخدم على اختيار تاريخ التسليم إذا كان العقد متخصصاً
    if (isAllocated && agreedHandoverDate == null) return _showError('يرجى تحديد الموعد المتفق عليه لتسليم الشقة!');
    
    if (priceController.text.isEmpty) return _showError('يرجى حساب السعر أولاً!');
    if (monthlyAmountCtrl.text.isEmpty) return _showError('يرجى إدخال المبلغ المتفق عليه شهرياً!');

    Map<String, double> finalCoeffs = _buildFinalCoefficients(isAllocated);

    String generatedDetails = '';
    if (isAllocated) {
      final allApartments = context.read<BuildingsCubit>().state.apartments;
      final buildings = context.read<BuildingsCubit>().state.buildings;
      final apt = allApartments.firstWhere((a) => a.id == selectedApartmentId);
      final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
      generatedDetails = 'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
    } else {
      generatedDetails = 'محفظة استثمارية (عقد لاحق التخصص)';
    }

    final double agreedAmount = _safeParseDouble(monthlyAmountCtrl);
    if (agreedAmount <= 0) return _showError('المبلغ الشهري يجب أن يكون أكبر من صفر!');

    final double finalArea = isAllocated ? _safeParseDouble(areaController) : 0.0;
    final int finalMonths = isAllocated ? _safeParseInt(monthsController, defaultValue: 48) : 48; 
    final double finalDownPayment = _safeParseDouble(downPaymentCtrl);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الحفظ وتوقيع العقد... ⏳'), backgroundColor: Colors.teal));
    
    await context.read<ContractsCubit>().addContract(
      clientId: selectedClientId!, 
      contractType: selectedContractType, 
      details: generatedDetails, 
      apartmentId: isAllocated ? selectedApartmentId : null,
      area: finalArea, 
      basePrice: _safeParseDouble(priceController), 
      downPayment: finalDownPayment, 
      installmentsCount: finalMonths, 
      guarantorName: guarantorController.text.trim(),
      agreedMonthlyAmount: agreedAmount, 
      coefficients: finalCoeffs, 
      customDate: isHistoricalContract ? selectedHistoricalDate : null, 
      
      // 🌟 إرسال الحقول الجديدة للـ Cubit
      agreedHandoverDate: isAllocated ? agreedHandoverDate : null,
      gracePeriodMonths: isAllocated ? _safeParseInt(gracePeriodCtrl, defaultValue: 0) : null,

      histIron: isHistoricalContract ? _safeParseDouble(histIronCtrl) : null, 
      histCement: isHistoricalContract ? _safeParseDouble(histCementCtrl) : null,
      histBlock: isHistoricalContract ? _safeParseDouble(histBlockCtrl) : null,
      histFormwork: isHistoricalContract ? _safeParseDouble(histFormworkCtrl) : null,
      histAggregates: isHistoricalContract ? _safeParseDouble(histAggregatesCtrl) : null,
      histWorker: isHistoricalContract ? _safeParseDouble(histWorkerCtrl) : null,
    );

    if (mounted) { 
      Navigator.pop(context); 
      _showSuccess('تم توقيع العقد بنجاح! ✅'); 
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}