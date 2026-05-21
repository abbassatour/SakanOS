// lib/payments/cubit/payments_cubit.dart
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:local_storage_api/local_storage_api.dart'
    show
        PaymentsLedgerCompanion,
        PaymentsLedgerData,
        Contract,
        Client,
        Apartment,
        Building,
        MaterialPricesHistoryCompanion,
        MaterialPricesHistoryData,
        DollarPricesHistoryCompanion; 

import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 🛡️ محرك التقريب المالي (محدث)
  // ==========================================

  // نستخدم التقريب فقط للقيم التي ستُعرض للمستخدم كـ (نص) في اللقطات
  double _roundTo10(double val) => (val / 10).round() * 10.0;
  
  // دقة الأمتار ممتازة (6 خانات) ونبقي عليها
  double _roundConvertedMeters(double val) => double.parse(val.toStringAsFixed(6));

  // تقريب النسب المئوية
  double _roundPercent(double val) => double.parse(val.toStringAsFixed(2));

  // ==========================================
  // 1. التهيئة وجلب البيانات الأساسية
  // ==========================================
  Future<void> fetchInitialData() async {
    if (state.status == PaymentsStatus.initial) {
      emit(state.copyWith(status: PaymentsStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      final apartments = await _erpRepository.getAllApartments();
      final buildings = await _erpRepository.getBuildings();

      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
        status: PaymentsStatus.success,
        clients: clients,
        contracts: contracts,
        apartments: apartments,
        buildings: buildings,
        userNamesMap: namesMap,
      ));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId, status: PaymentsStatus.loading));
    try {
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 2. تسجيل دفعة جديدة (مع التحصين المالي الحقيقي 🛡️)
  // ==========================================
  Future<void> addLedgerEntry({
    required String contractId,
    required double amountPaid, // نأخذ المبلغ كما أدخله المستخدم بالضبط
    double discountPercentage = 0,
    String? scheduleId,
    DateTime? customDate,
    double? customMeterPrice,
    double? histIron,
    double? histCement,
    double? histBlock,
    double? histFormwork,
    double? histAggregates,
    double? histWorker,
    double? histDollarRate,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

      // 🌟 حفظ سعر الدولار القديم في سجل الدولار
      if (customDate != null && histDollarRate != null) {
        try {
          final historicalDollar = DollarPricesHistoryCompanion.insert(
            exchangeRate: histDollarRate,
            effectiveDate: Value(customDate.toUtc()),
            userId: userId,
          );
          await _erpRepository.saveDollarPrice(historicalDollar);
        } catch (e) {
          print('⚠️ تحذير: فشل حفظ تسعيرة الدولار التاريخية: $e');
        }
      }

      Map<String, double> contractCoefficients = {};
      if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
        final Map<String, dynamic> decodedMap = jsonDecode(contract.coefficients);
        decodedMap.forEach((key, value) {
          contractCoefficients[key.toString()] = (value as num).toDouble();
        });
      }

      final double safeAreaForCalculation = contract.totalArea > 0 ? contract.totalArea : 1.0;
      final paymentDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

      double rawMeterPriceToUse = 0.0; // 🌟 السر هنا: السعر الخام الدقيق
      String pricesSnapshotJson = '{}';

      // 🧠 حساب سعر المتر (نحتفظ بالدقة الكاملة)
      if (customDate != null && customMeterPrice != null && histIron == null) {
        rawMeterPriceToUse = customMeterPrice; // إدخال يدوي مباشر نأخذه كما هو
        pricesSnapshotJson = jsonEncode({
          'note': 'إدخال تاريخي سريع',
          'manual_meter_price': _roundTo10(rawMeterPriceToUse), // نقربه فقط في الـ JSON للعرض
          'dollar_rate_used': histDollarRate
        });
      } else if (customDate != null && histIron != null) {
        // 🛡️ حفظ الأسعار التاريخية
        final targetPrices = MaterialPricesHistoryData(
          id: 'dummy',
          effectiveDate: paymentDateToSave,
          ironPrice: histIron, // 🌟 لا تقرب المدخلات هنا لتجنب تراكم الخطأ
          cementPrice: histCement!,
          block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!,
          aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          isSynced: false,
        );

        // هنا استخدمنا البيانات الخام
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(paymentDateToSave),
          ironPrice: histIron,
          cementPrice: histCement,
          block15Price: histBlock,
          formworkAndPouringWages: histFormwork,
          aggregateMaterialsPrice: histAggregates,
          ordinaryWorkerWage: histWorker,
          userId: userId,
        );
        await _erpRepository.savePrices(historicalPrices);

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation,
          currentPrices: targetPrices,
          coefficients: contractCoefficients,
        );

        // 🌟 نطلب السعر الخام من الآلة الحاسبة
        rawMeterPriceToUse = calculations['pricePerSqmRaw'] ?? calculations['pricePerSqm']!;
        
        pricesSnapshotJson = jsonEncode({
          'iron': histIron,
          'cement': histCement,
          'block': histBlock,
          'formwork': histFormwork,
          'aggregates': histAggregates,
          'worker': histWorker,
          'dollar_rate_used': histDollarRate
        });
      } else {
        final currentPrices = await _erpRepository.getLatestPrices();
        if (currentPrices == null) throw Exception('يرجى إضافة أسعار المواد أولاً في الإعدادات.');

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation,
          currentPrices: currentPrices,
          coefficients: contractCoefficients,
        );

        rawMeterPriceToUse = calculations['pricePerSqmRaw'] ?? calculations['pricePerSqm']!;
        
        pricesSnapshotJson = jsonEncode({
          'iron': currentPrices.ironPrice,
          'cement': currentPrices.cementPrice,
          'block': currentPrices.block15Price,
          'formwork': currentPrices.formworkAndPouringWages,
          'aggregates': currentPrices.aggregateMaterialsPrice,
          'worker': currentPrices.ordinaryWorkerWage,
        });
      }

      // -------------------------------------------------------------------
      // 🛡️ الحساب الدقيق للأمتار (المحرك الرياضي الحقيقي)
      // -------------------------------------------------------------------
      
      // 1. لا نقرب المبلغ المدفوع أبداً
      // 2. لا نقرب نسبة الخصم أبداً
      final double effectiveValueRaw = amountPaid + (amountPaid * (discountPercentage / 100));
      
      // 3. نقسم القيمة الدقيقة على السعر الدقيق
      final double convertedMeters = _roundConvertedMeters(effectiveValueRaw / rawMeterPriceToUse);

      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(),
        paymentDate: paymentDateToSave,
        amountPaid: amountPaid, // نحفظ المبلغ الدقيق
        meterPriceAtPayment: rawMeterPriceToUse, // نحفظ السعر الدقيق للمتر ليتم القسمة عليه مستقبلاً لو احتجنا
        convertedMeters: convertedMeters, // الأمتار المحسوبة بدقة
        pricesSnapshot: Value(pricesSnapshotJson),
        fees: Value(discountPercentage),
        userId: userId,
      );

      await _erpRepository.addLedgerEntry(newEntry);
      
      if (scheduleId != null) {
        final currentSchedules = await _erpRepository.getContractSchedule(contractId);
        final targetScheduleIndex = currentSchedules.indexWhere((s) => s.id == scheduleId);

        if (targetScheduleIndex != -1) {
          final targetSchedule = currentSchedules[targetScheduleIndex];
          final nextDueDate = DateTime.utc(
              targetSchedule.dueDate.year, targetSchedule.dueDate.month + 1, targetSchedule.dueDate.day);

          await _erpRepository.handleRollingCheckpoint(
            contractId: contractId,
            scheduleId: scheduleId,
            actionType: 'paid',
            nextDueDate: nextDueDate,
          );
        }
      }

      await selectContract(contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 3. تعديل دفعة قديمة (التصحيح الدقيق 🛡️)
  // ==========================================
  Future<void> editOldLedgerEntry({
    required PaymentsLedgerData entryToEdit,
    required double newAmountPaid,
    required double newDiscountPercentage,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      // 🛡️ استخدام القيم الخام (Raw) بدون تقريب مبكر
      final double effectiveValueRaw = newAmountPaid + (newAmountPaid * (newDiscountPercentage / 100));
      
      // 🛡️ القسمة تتم على السعر الدقيق المحفوظ مسبقاً في الدفعة
      final double newConvertedMeters = _roundConvertedMeters(effectiveValueRaw / entryToEdit.meterPriceAtPayment);

      await _erpRepository.updateLedgerEntryAmount(
        entryId: entryToEdit.id,
        newAmount: newAmountPaid,
        newDiscount: newDiscountPercentage,
        newConvertedMeters: newConvertedMeters,
      );

      await selectContract(entryToEdit.contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل تعديل الدفعة: $e'));
    }
  }

  // ==========================================
  // 4. حذف "آخر دفعة فقط" 
  // ==========================================
  Future<void> softDeleteLastEntry(PaymentsLedgerData entryToDelete) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final allEntriesForContract = await _erpRepository.getContractLedger(entryToDelete.contractId);

      if (allEntriesForContract.isEmpty || allEntriesForContract.first.id != entryToDelete.id) {
        throw Exception(
            'تحذير مالي: لا يمكن حذف دفعة قديمة، يمكنك فقط تعديل قيمتها بصلاحيات الإدارة. يسمح بحذف آخر دفعة فقط.');
      }

      await _erpRepository.softDeleteLedgerEntry(entryToDelete.id);

      await selectContract(entryToDelete.contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // بقية الدوال (المحذوفات والواتساب) 
  // ==========================================
  Future<void> fetchDeletedEntries() async {
    try {
      final deleted = await _erpRepository.getDeletedLedgerEntries();
      emit(state.copyWith(deletedLedgerEntries: deleted));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> restoreLedgerEntry(PaymentsLedgerData entry) async {
    try {
      await _erpRepository.restoreLedgerEntry(entry.id);
      await fetchDeletedEntries();
      await selectContract(entry.contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> hardDeleteLedgerEntry(String entryId) async {
    try {
      await _erpRepository.forceHardDeleteLedgerEntry(entryId);
      await fetchDeletedEntries();
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await _erpRepository.syncPendingData();
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل في تحديث حالة الواتساب: $e'));
    }
  }
}