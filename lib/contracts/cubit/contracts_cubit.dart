// lib/contracts/cubit/contracts_cubit.dart
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show
        ContractsCompanion,
        Contract,
        Client,
        MaterialPricesHistoryCompanion,
        PaymentsLedgerCompanion,
        DollarPricesHistoryCompanion; 
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 🛡️ محرك التقريب والتحصين المالي 
  // ==========================================
  
  // 💰 تقريب المبالغ المالية الكلية للورق (وليس للمواد)
  double _roundTo10(double val) => (val / 10).round() * 10.0;

  double _roundArea(double val) => double.parse(val.toStringAsFixed(4));
  double _roundConvertedMeters(double val) => double.parse(val.toStringAsFixed(6));
  double _roundPercent(double val) => double.parse(val.toStringAsFixed(2));

  // ==========================================
  // 1. جلب البيانات الأساسية
  // ==========================================
  Future<void> fetchData() async {
    if (state.status == ContractsStatus.initial) {
      emit(state.copyWith(status: ContractsStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts();

      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
        status: ContractsStatus.success,
        clients: clients,
        contracts: allContracts,
        userNamesMap: namesMap,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 2. جلب العقود المحذوفة
  // ==========================================
  Future<void> fetchDeletedContracts() async {
    try {
      final deleted = await _erpRepository.getDeletedContracts();
      emit(state.copyWith(deletedContracts: deleted));
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 3. إضافة عقد جديد (مع الدرع المالي المطلق 🛡️)
  // ==========================================
  Future<void> addContract({
    required String clientId,
    required String contractType,
    required String details,
    required String? apartmentId,
    required double area,
    required double basePrice, 
    required double downPayment, 
    required int installmentsCount,
    required String guarantorName,
    required double agreedMonthlyAmount,
    Map<String, double> coefficients = const {},
    DateTime? customDate,
    DateTime? agreedHandoverDate,
    int? gracePeriodMonths,
    bool isPenaltyActive = false,
    double penaltyPercentage = 0.0,
    int penaltyIntervalMonths = 1,
    double? histIron,
    double? histCement,
    double? histBlock,
    double? histFormwork,
    double? histAggregates,
    double? histWorker,
    double? histDollarRate, 
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) {
        throw Exception('يجب تسجيل الدخول أولاً لإنشاء العقود.');
      }

      final contractDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

      // حفظ سعر الدولار القديم
      if (customDate != null && histDollarRate != null) {
        try {
          final historicalDollar = DollarPricesHistoryCompanion.insert(
            exchangeRate: histDollarRate,
            effectiveDate: Value(contractDateToSave),
            userId: userId,
          );
          await _erpRepository.saveDollarPrice(historicalDollar);
        } catch (e) {
          print('⚠️ تحذير: فشل حفظ تسعيرة الدولار التاريخية: $e');
        }
      }

      // 🌟 التعديل: حفظ الأسعار التاريخية للمواد كما هي "خام" (بدون أي تقريب) 
      if (customDate != null && histIron != null) {
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(contractDateToSave),
          ironPrice: histIron, 
          cementPrice: histCement!,
          block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!,
          aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!,
          userId: userId,
        );
        await _erpRepository.savePrices(historicalPrices);
      }

      final String newContractId = const Uuid().v7();

      // تقريب بيانات "نص العقد" لتطابق الورق
      final double safeArea = _roundArea(area);
      final double safeBasePriceForContract = _roundTo10(basePrice); 
      final double safeDownPaymentForContract = _roundTo10(downPayment); 
      final double safeMonthlyAmount = _roundTo10(agreedMonthlyAmount);
      final double safePenaltyPct = _roundPercent(penaltyPercentage);

      final newContract = ContractsCompanion.insert(
        id: Value(newContractId),
        clientId: clientId,
        apartmentId: Value(apartmentId),
        contractType: Value(contractType),
        apartmentDetails: Value(details),
        totalArea: safeArea,
        baseMeterPriceAtSigning: safeBasePriceForContract, 
        downPayment: Value(safeDownPaymentForContract), 
        agreedHandoverDate: agreedHandoverDate != null
            ? Value(agreedHandoverDate.toUtc())
            : const Value.absent(),
        gracePeriodMonths: Value(gracePeriodMonths ?? 0),
        isPenaltyActive: Value(isPenaltyActive),
        penaltyPercentage: Value(safePenaltyPct),
        penaltyIntervalMonths: Value(penaltyIntervalMonths),
        installmentsCount: Value(installmentsCount),
        agreedMonthlyAmount: Value(safeMonthlyAmount),
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: contractDateToSave,
        guarantorName: guarantorName,
        userId: userId,
      );

      await _erpRepository.addContract(newContract);

      // حساب أمتار الدفعة الأولى بدقة متناهية (Raw / Raw)
      if (downPayment > 0) { 
        double rawConverted = basePrice > 0 ? (downPayment / basePrice) : 0;
        
        // 🌟 [الدرع المالي]: بناء لقطة الأسعار بشكل دقيق يطابق ما يحدث في الدفعات (PaymentsCubit)
        Map<String, dynamic> snapshotData = {'note': 'الدفعة الأولى عند توقيع العقد'};
        
        if (histDollarRate != null) {
          snapshotData['dollar_rate_used'] = histDollarRate;
        }

        // 🌟 حفظ أسعار المواد داخل اللقطة
        if (customDate != null && histIron != null) {
          // 1. إذا كان العقد تاريخياً وتم إدخال المواد يدوياً
          snapshotData['iron'] = histIron;
          snapshotData['cement'] = histCement;
          snapshotData['block'] = histBlock;
          snapshotData['formwork'] = histFormwork;
          snapshotData['aggregates'] = histAggregates;
          snapshotData['worker'] = histWorker;
        } else {
          // 2. إذا كان العقد بتاريخ اليوم، نجلب أحدث أسعار من الإعدادات
          final currentPrices = await _erpRepository.getLatestPrices();
          if (currentPrices != null) {
            snapshotData['iron'] = currentPrices.ironPrice;
            snapshotData['cement'] = currentPrices.cementPrice;
            snapshotData['block'] = currentPrices.block15Price;
            snapshotData['formwork'] = currentPrices.formworkAndPouringWages;
            snapshotData['aggregates'] = currentPrices.aggregateMaterialsPrice;
            snapshotData['worker'] = currentPrices.ordinaryWorkerWage;
          }
        }

        final downPaymentEntry = PaymentsLedgerCompanion.insert(
          contractId: newContractId,
          paymentDate: contractDateToSave,
          amountPaid: downPayment, // خام
          meterPriceAtPayment: basePrice, // خام
          convertedMeters: _roundConvertedMeters(rawConverted), // دقة 6 خانات
          pricesSnapshot: Value(jsonEncode(snapshotData)), // 🌟 يتم حفظها كاملة الآن
          userId: userId,
        );
        
        await _erpRepository.addLedgerEntry(downPaymentEntry);
      }

      if (apartmentId != null && apartmentId.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(apartmentId, 'sold');
      }

      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 4. إرفاق ملف العقد
  // ==========================================
  Future<void> attachContractFile(
      {required String contractId,
      required String filePath,
      required String extension}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final file = File(filePath);
      await _erpRepository.attachFileToContract(contractId, file, extension);
      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إرفاق الملف: $e'));
    }
  }

  // ==========================================
  // 5. الحذف الوهمي للعقد
  // ==========================================
  Future<void> deleteContract(String id) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contractToCancel = state.contracts.firstWhere((c) => c.id == id);
      await _erpRepository.deleteContract(id);

      if (contractToCancel.apartmentId != null &&
          contractToCancel.apartmentId!.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(
            contractToCancel.apartmentId!, 'available');
      }
      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 6. استعادة العقد من سلة المحذوفات
  // ==========================================
  Future<void> restoreContract(Contract contract) async {
    try {
      await _erpRepository.restoreContract(contract.id);

      if (contract.apartmentId != null && contract.apartmentId!.isNotEmpty) {
        final targetStatus = contract.isHandedOver ? 'delivered' : 'sold';
        await _erpRepository.changeApartmentStatus(
            contract.apartmentId!, targetStatus);
      }

      await fetchDeletedContracts();
      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 7. الحذف النهائي للعقد
  // ==========================================
  Future<void> forceHardDelete(String contractId) async {
    try {
      await _erpRepository.forceHardDeleteContract(contractId);
      await fetchDeletedContracts();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 8. تعديل العقد 
  // ==========================================
  Future<void> updateContract({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
    required double agreedMonthlyAmount,
    required DateTime contractDate,
    required bool isPenaltyActive,
    required double penaltyPercentage,
    required int penaltyIntervalMonths,
  }) async {
    try {
      final double safeMonthlyAmount = _roundTo10(agreedMonthlyAmount);
      final double safePenaltyPct = _roundPercent(penaltyPercentage);

      await _erpRepository.updateContract(
        id: id,
        apartmentDetails: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
        agreedMonthlyAmount: safeMonthlyAmount,
        contractDate: contractDate,
        isPenaltyActive: isPenaltyActive,
        penaltyPercentage: safePenaltyPct,
        penaltyIntervalMonths: penaltyIntervalMonths,
      );
      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'حدث خطأ أثناء تعديل العقد: $e'));
    }
  }

  // ==========================================
  // 9. تسجيل تسليم الشقة الفعلي
  // ==========================================
  Future<void> markContractAsHandedOver({
    required String contractId,
    required DateTime actualHandoverDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.markContractAsHandedOver(
        contractId: contractId,
        apartmentId: state.contracts.firstWhere((c) => c.id == contractId).apartmentId,
        actualHandoverDate: actualHandoverDate,
        notes: notes,
      );

      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل عملية تسليم الشقة: $e'));
    }
  }

  // ==========================================
  // 10. التراجع عن تسليم الشقة
  // ==========================================
  Future<void> cancelContractHandover({required String contractId}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.cancelContractHandover(
        contractId: contractId,
        apartmentId: state.contracts.firstWhere((c) => c.id == contractId).apartmentId,
      );

      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إلغاء التسليم: $e'));
    }
  }

  // ==========================================
  // 11. 🔒 إغلاق/أرشفة العقد
  // ==========================================
  Future<void> toggleContractCompletion(
      {required String contractId, required bool isCompleted}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.toggleContractCompletion(
        contractId: contractId,
        isCompleted: isCompleted,
      );

      await fetchData();
    } catch (e) {
      emit(state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل تغيير حالة العقد: $e'));
    }
  }
}