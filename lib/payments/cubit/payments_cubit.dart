// lib/payments/cubit/payments_cubit.dart

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

import 'package:our_home_erp_app/core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  double _roundTo10(double val) => (val / 10).round() * 10.0;

  double _roundConvertedMeters(double val) =>
      double.parse(val.toStringAsFixed(6));

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
      final namesMap = <String, String>{
        for (final user in allUsers)
          user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          status: PaymentsStatus.success,
          clients: clients,
          contracts: contracts,
          apartments: apartments,
          buildings: buildings,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(
      state.copyWith(
        selectedContractId: contractId,
        status: PaymentsStatus.loading,
      ),
    );
    try {
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(
        state.copyWith(
          status: PaymentsStatus.success,
          ledgerEntries: ledgerEntries,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

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
    double? histDollarRate,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex =
          state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final contractCoefficients = <String, double>{};
      if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
        final decodedMap =
            jsonDecode(contract.coefficients) as Map<String, dynamic>;
        decodedMap.forEach((key, dynamic value) {
          contractCoefficients[key] = (value as num).toDouble();
        });
      }

      final safeAreaForCalculation =
          contract.totalArea > 0 ? contract.totalArea : 1.0;
      final paymentDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

      var rawMeterPriceToUse = 0.0;
      var pricesSnapshotJson = '{}';

      if (customDate != null && customMeterPrice != null && histIron == null) {
        rawMeterPriceToUse = customMeterPrice;
        pricesSnapshotJson = jsonEncode({
          'note': 'إدخال تاريخي سريع',
          'manual_meter_price': _roundTo10(rawMeterPriceToUse),
          'dollar_rate_used': histDollarRate,
        });
      } else if (customDate != null && histIron != null) {
        final targetPrices = MaterialPricesHistoryData(
          id: 'dummy',
          effectiveDate: paymentDateToSave,
          ironPrice: histIron,
          cementPrice: histCement!,
          block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!,
          aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!,
          userId: '',
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

        rawMeterPriceToUse =
            calculations['pricePerSqmRaw'] ?? calculations['pricePerSqm']!;

        pricesSnapshotJson = jsonEncode({
          'iron': histIron,
          'cement': histCement,
          'block': histBlock,
          'formwork': histFormwork,
          'aggregates': histAggregates,
          'worker': histWorker,
          'dollar_rate_used': histDollarRate,
        });
      } else {
        final currentPrices = await _erpRepository.getLatestPrices();
        if (currentPrices == null) {
          throw Exception('يرجى إضافة أسعار المواد أولاً في الإعدادات.');
        }

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeAreaForCalculation,
          currentPrices: currentPrices,
          coefficients: contractCoefficients,
        );

        rawMeterPriceToUse =
            calculations['pricePerSqmRaw'] ?? calculations['pricePerSqm']!;

        pricesSnapshotJson = jsonEncode({
          'iron': currentPrices.ironPrice,
          'cement': currentPrices.cementPrice,
          'block': currentPrices.block15Price,
          'formwork': currentPrices.formworkAndPouringWages,
          'aggregates': currentPrices.aggregateMaterialsPrice,
          'worker': currentPrices.ordinaryWorkerWage,
        });
      }

      final effectiveValueRaw =
          amountPaid + (amountPaid * (discountPercentage / 100));
      final convertedMeters =
          _roundConvertedMeters(effectiveValueRaw / rawMeterPriceToUse);

      await _erpRepository.addLedgerEntry(
        contractId: contractId,
        amountPaid: amountPaid,
        meterPriceAtPayment: rawMeterPriceToUse,
        convertedMeters: convertedMeters,
        pricesSnapshotJson: pricesSnapshotJson,
        discountPercentage: discountPercentage,
        scheduleId: scheduleId,
        customDate: customDate,
        histDollarRate: histDollarRate,
        histIron: histIron,
        histCement: histCement,
        histBlock: histBlock,
        histFormwork: histFormwork,
        histAggregates: histAggregates,
        histWorker: histWorker,
      );

      await selectContract(contractId);

      unawaited(
        _erpRepository.forceSyncWithCloud().catchError((Object e) {
          // ignore: avoid_print
          print('Sync Error: $e');
          return '';
        }),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> editOldLedgerEntry({
    required PaymentsLedgerData entryToEdit,
    required double newAmountPaid,
    required double newDiscountPercentage,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final effectiveValueRaw =
          newAmountPaid + (newAmountPaid * (newDiscountPercentage / 100));
      final newConvertedMeters = _roundConvertedMeters(
        effectiveValueRaw / entryToEdit.meterPriceAtPayment,
      );

      await _erpRepository.updateLedgerEntryAmount(
        entryId: entryToEdit.id,
        newAmount: newAmountPaid,
        newDiscount: newDiscountPercentage,
        newConvertedMeters: newConvertedMeters,
      );

      await selectContract(entryToEdit.contractId);

      unawaited(
        _erpRepository.forceSyncWithCloud().catchError((Object e) {
          // ignore: avoid_print
          print('Sync Error: $e');
          return '';
        }),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: 'فشل تعديل الدفعة: $e',
        ),
      );
    }
  }

  Future<void> softDeleteLastEntry(PaymentsLedgerData entryToDelete) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final allEntriesForContract =
          await _erpRepository.getContractLedger(entryToDelete.contractId);

      if (allEntriesForContract.isEmpty ||
          allEntriesForContract.first.id != entryToDelete.id) {
        throw Exception(
          'تحذير مالي: لا يمكن حذف دفعة قديمة، يمكنك فقط تعديل قيمتها بصلاحيات '
          'الإدارة. يسمح بحذف آخر دفعة فقط.',
        );
      }

      await _erpRepository.softDeleteLedgerEntry(entryToDelete.id);

      await selectContract(entryToDelete.contractId);

      unawaited(
        _erpRepository.forceSyncWithCloud().catchError((Object e) {
          // ignore: avoid_print
          print('Sync Error: $e');
          return '';
        }),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchDeletedEntries() async {
    try {
      final deleted = await _erpRepository.getDeletedLedgerEntries();
      emit(state.copyWith(deletedLedgerEntries: deleted));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreLedgerEntry(PaymentsLedgerData entry) async {
    try {
      await _erpRepository.restoreLedgerEntry(entry.id);
      await fetchDeletedEntries();
      await selectContract(entry.contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeleteLedgerEntry(String entryId) async {
    try {
      await _erpRepository.forceHardDeleteLedgerEntry(entryId);
      await fetchDeletedEntries();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await selectContract(contractId);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: PaymentsStatus.failure,
          errorMessage: 'فشل في تحديث حالة الواتساب: $e',
        ),
      );
    }
  }
}