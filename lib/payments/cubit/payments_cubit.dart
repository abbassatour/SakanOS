// lib/payments/cubit/payments_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerCompanion, PaymentsLedgerData, Contract, Client, Apartment, Building, MaterialPricesHistoryCompanion, MaterialPricesHistoryData; 

import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 1. التهيئة وجلب البيانات الأساسية
  // ==========================================
  Future<void> fetchInitialData() async {
    if (state.status == PaymentsStatus.initial) emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      final apartments = await _erpRepository.getAllApartments();
      final buildings = await _erpRepository.getBuildings();
      
      // 🌟 السحر هنا: جلب المستخدمين وصنع قاموس للأسماء
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
        userNamesMap: namesMap, // 🌟 تمرير القاموس للواجهة
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

  // 🌟 (تم حذف دالة _syncScheduleWithLedger القديمة المسببة للمشكلة تماماً) 🌟

  // ==========================================
  // 2. 🌟 الدفع بنظام القيمة (Value-Based Payment) - التعديل الجوهري
  // ==========================================
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double discountPercentage = 0, 
    String? scheduleId, 
    DateTime? customDate, 
    double? customMeterPrice, 
    double? histIron, double? histCement, double? histBlock, 
    double? histFormwork, double? histAggregates, double? histWorker,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

      // قراءة الـ JSON بأمان تام
      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          final Map<String, dynamic> decodedMap = jsonDecode(contract.coefficients);
          decodedMap.forEach((key, value) {
            contractCoefficients[key.toString()] = (value as num).toDouble();
          });
        }
      } catch (e) {
        print('⚠️ تحذير: فشل في قراءة معاملات العقد: $e');
      }

      // حماية المساحة لكي لا نرسل صفر للحاسبة
      final double safeAreaForCalculation = contract.totalArea > 0 ? contract.totalArea : 1.0;
      final paymentDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();
      
      double meterPriceToUse = 0.0;
      String pricesSnapshotJson = '{}';

      // 🧠 حساب السعر:
      if (customDate != null && customMeterPrice != null && histIron == null) {
        meterPriceToUse = customMeterPrice;
        pricesSnapshotJson = jsonEncode({
          'note': 'إدخال تاريخي سريع',
          'manual_meter_price': customMeterPrice
        });
      } else if (customDate != null && histIron != null) {
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(paymentDateToSave), 
          ironPrice: histIron, cementPrice: histCement!, block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!, aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!, userId: userId,
        );
        
        await _erpRepository.savePrices(historicalPrices);

        final targetPrices = MaterialPricesHistoryData(
          id: 'dummy', effectiveDate: paymentDateToSave, ironPrice: histIron,
          cementPrice: histCement, block15Price: histBlock, formworkAndPouringWages: histFormwork,
          aggregateMaterialsPrice: histAggregates, ordinaryWorkerWage: histWorker,
          userId: userId, createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isDeleted: false, isSynced: false,
        );

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation, currentPrices: targetPrices, coefficients: contractCoefficients,
        );
        
        meterPriceToUse = calculations['pricePerSqm']!;
        pricesSnapshotJson = jsonEncode({
          'iron': histIron, 'cement': histCement, 'block': histBlock,
          'formwork': histFormwork, 'aggregates': histAggregates, 'worker': histWorker,
        });
      } else {
        final currentPrices = await _erpRepository.getLatestPrices();
        if (currentPrices == null) throw Exception('يرجى إضافة أسعار المواد أولاً في الإعدادات.');
        
        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation, currentPrices: currentPrices, coefficients: contractCoefficients,
        );
        
        meterPriceToUse = calculations['pricePerSqm']!;
        pricesSnapshotJson = jsonEncode({
          'iron': currentPrices.ironPrice, 'cement': currentPrices.cementPrice, 'block': currentPrices.block15Price,
          'formwork': currentPrices.formworkAndPouringWages, 'aggregates': currentPrices.aggregateMaterialsPrice,
          'worker': currentPrices.ordinaryWorkerWage,
        });
      }

      // حساب المبالغ والأمتار الفعلية المشتراة
      final double effectiveAmount = amountPaid + (amountPaid * (discountPercentage / 100));
      final double convertedMeters = effectiveAmount / meterPriceToUse;

      // 1. تسجيل الدفعة الحقيقية في الأقساط (بالمبلغ الكامل الذي دفعه)
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: paymentDateToSave, 
        amountPaid: amountPaid, 
        meterPriceAtPayment: meterPriceToUse, 
        convertedMeters: convertedMeters, 
        pricesSnapshot: Value(pricesSnapshotJson), 
        fees: Value(discountPercentage), 
        userId: userId,
      );
      
      await _erpRepository.addLedgerEntry(newEntry);
      
      // 🌟🌟🌟 التعديل الجوهري السحري (بديل الـ Loop المزعج) 🌟🌟🌟
      // إذا كان هناك قسط مرتبط بهذه الدفعة، نغلقه هو "فقط" ونولد الشهر القادم
      if (scheduleId != null) {
        // جلب جدول الاستحقاقات لمعرفة تاريخ القسط الذي ندفعه الآن
        final currentSchedules = await _erpRepository.getContractSchedule(contractId);
        final targetScheduleIndex = currentSchedules.indexWhere((s) => s.id == scheduleId);
        
        if (targetScheduleIndex != -1) {
          final targetSchedule = currentSchedules[targetScheduleIndex];
          
          // تحديد تاريخ القسط القادم (بعد شهر واحد بالضبط)
          final nextDueDate = DateTime.utc(
            targetSchedule.dueDate.year, 
            targetSchedule.dueDate.month + 1, 
            targetSchedule.dueDate.day
          );

          // إغلاق هذا القسط (باعتباره مسدداً) وتوليد نقطة المراقبة للشهر القادم
          await _erpRepository.handleRollingCheckpoint(
            contractId: contractId,
            scheduleId: scheduleId,
            actionType: 'paid',
            nextDueDate: nextDueDate,
          );
        }
      }
      
      // تحديث الواجهة
      await selectContract(contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));
      
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }


  // ==========================================
  // 3. ✏️ تعديل دفعة (بصلاحيات الإدارة) 
  // ==========================================
  Future<void> editOldLedgerEntry({
    required PaymentsLedgerData entryToEdit,
    required double newAmountPaid,
    required double newDiscountPercentage,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == entryToEdit.contractId);

      final double effectiveAmount = newAmountPaid + (newAmountPaid * (newDiscountPercentage / 100));
      final double newConvertedMeters = effectiveAmount / entryToEdit.meterPriceAtPayment;

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
  // 4. 🗑️ حذف "آخر دفعة فقط" (خطأ لحظي)
  // ==========================================
  Future<void> softDeleteLastEntry(PaymentsLedgerData entryToDelete) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final allEntriesForContract = await _erpRepository.getContractLedger(entryToDelete.contractId);
      
      if (allEntriesForContract.isEmpty || allEntriesForContract.first.id != entryToDelete.id) {
        throw Exception('تحذير مالي: لا يمكن حذف دفعة قديمة، يمكنك فقط تعديل قيمتها بصلاحيات الإدارة. يسمح بحذف آخر دفعة فقط.');
      }

      await _erpRepository.softDeleteLedgerEntry(entryToDelete.id);

      await selectContract(entryToDelete.contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));

    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 5. 🗑️ سلة المحذوفات (الإيصالات الملغاة)
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

  // ==========================================
  // واتساب
  // ==========================================
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