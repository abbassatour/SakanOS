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
        MaterialPricesHistoryData;

import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 🛡️ محرك التقريب والتحصين المالي (Financial Guarding)
  // ==========================================

  // 💰 تقريب المبالغ المالية لأقرب 10 ليرات
  double _roundTo10(double val) => (val / 10).round() * 10.0;

  // 🎯 تقريب الأمتار المحولة بدقة متناهية (6 خانات عشرية)
  double _roundConvertedMeters(double val) => double.parse(val.toStringAsFixed(6));

  // 📈 تقريب النسب المئوية (خانتين عشريتين)
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
  // 2. تسجيل دفعة جديدة (مع التحصين المالي 🛡️)
  // ==========================================
  Future<void> addLedgerEntry({
    required String contractId,
    required double amountPaid,
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
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

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

      final double safeAreaForCalculation = contract.totalArea > 0 ? contract.totalArea : 1.0;
      final paymentDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

      double meterPriceToUse = 0.0;
      String pricesSnapshotJson = '{}';

      // 🧠 حساب السعر المطبق مع التقريب لأقرب 10 ليرات
      if (customDate != null && customMeterPrice != null && histIron == null) {
        meterPriceToUse = _roundTo10(customMeterPrice);
        pricesSnapshotJson = jsonEncode({
          'note': 'إدخال تاريخي سريع',
          'manual_meter_price': meterPriceToUse
        });
      } else if (customDate != null && histIron != null) {
        // 🛡️ تقريب الأسعار التاريخية قبل الحفظ
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(paymentDateToSave),
          ironPrice: _roundTo10(histIron),
          cementPrice: _roundTo10(histCement!),
          block15Price: _roundTo10(histBlock!),
          formworkAndPouringWages: _roundTo10(histFormwork!),
          aggregateMaterialsPrice: _roundTo10(histAggregates!),
          ordinaryWorkerWage: _roundTo10(histWorker!),
          userId: userId,
        );

        await _erpRepository.savePrices(historicalPrices);

        final targetPrices = MaterialPricesHistoryData(
          id: 'dummy',
          effectiveDate: paymentDateToSave,
          ironPrice: _roundTo10(histIron),
          cementPrice: _roundTo10(histCement),
          block15Price: _roundTo10(histBlock),
          formworkAndPouringWages: _roundTo10(histFormwork),
          aggregateMaterialsPrice: _roundTo10(histAggregates),
          ordinaryWorkerWage: _roundTo10(histWorker),
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          isSynced: false,
        );

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation,
          currentPrices: targetPrices,
          coefficients: contractCoefficients,
        );

        meterPriceToUse = _roundTo10(calculations['pricePerSqm']!);
        pricesSnapshotJson = jsonEncode({
          'iron': _roundTo10(histIron),
          'cement': _roundTo10(histCement),
          'block': _roundTo10(histBlock),
          'formwork': _roundTo10(histFormwork),
          'aggregates': _roundTo10(histAggregates),
          'worker': _roundTo10(histWorker),
        });
      } else {
        final currentPrices = await _erpRepository.getLatestPrices();
        if (currentPrices == null) throw Exception('يرجى إضافة أسعار المواد أولاً في الإعدادات.');

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation,
          currentPrices: currentPrices,
          coefficients: contractCoefficients,
        );

        meterPriceToUse = _roundTo10(calculations['pricePerSqm']!);
        pricesSnapshotJson = jsonEncode({
          'iron': _roundTo10(currentPrices.ironPrice),
          'cement': _roundTo10(currentPrices.cementPrice),
          'block': _roundTo10(currentPrices.block15Price),
          'formwork': _roundTo10(currentPrices.formworkAndPouringWages),
          'aggregates': _roundTo10(currentPrices.aggregateMaterialsPrice),
          'worker': _roundTo10(currentPrices.ordinaryWorkerWage),
        });
      }

      // 🛡️ حساب القيمة الفعلية (بإضافة الخصم/الزيادة) مع تقريبها لأقرب 10
      final double safeAmountPaid = _roundTo10(amountPaid);
      final double safeDiscountPercent = _roundPercent(discountPercentage);
      
      final double effectiveValue = _roundTo10(safeAmountPaid + (safeAmountPaid * (safeDiscountPercent / 100)));
      
      // 🛡️ حساب الأمتار المحولة بدقة 6 خانات
      final double convertedMeters = _roundConvertedMeters(effectiveValue / meterPriceToUse);

      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(),
        paymentDate: paymentDateToSave,
        amountPaid: safeAmountPaid,
        meterPriceAtPayment: meterPriceToUse,
        convertedMeters: convertedMeters,
        pricesSnapshot: Value(pricesSnapshotJson),
        fees: Value(safeDiscountPercent),
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
  // 3. تعديل دفعة قديمة (مع التحصين المالي 🛡️)
  // ==========================================
  Future<void> editOldLedgerEntry({
    required PaymentsLedgerData entryToEdit,
    required double newAmountPaid,
    required double newDiscountPercentage,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      // 🛡️ تقريب المدخلات الجديدة
      final double safeNewAmount = _roundTo10(newAmountPaid);
      final double safeNewDiscount = _roundPercent(newDiscountPercentage);
      
      // 🛡️ إعادة حساب القيمة المضافة للأمتار
      final double effectiveValue = _roundTo10(safeNewAmount + (safeNewAmount * (safeNewDiscount / 100)));
      final double newConvertedMeters = _roundConvertedMeters(effectiveValue / entryToEdit.meterPriceAtPayment);

      await _erpRepository.updateLedgerEntryAmount(
        entryId: entryToEdit.id,
        newAmount: safeNewAmount,
        newDiscount: safeNewDiscount,
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
  // بقية الدوال (المحذوفات والواتساب) تبقى كما هي
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