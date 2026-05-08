// lib/contracts/cubit/contracts_cubit.dart
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
// 🌟 أضفنا PaymentsLedgerCompanion لإنشاء الإيصال الآلي
import 'package:local_storage_api/local_storage_api.dart' show ContractsCompanion, Contract, Client, MaterialPricesHistoryCompanion, PaymentsLedgerCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart'; // 🌟 أضفنا مكتبة الـ UUID لتوليد المعرفات

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  Future<void> fetchData() async {
    if (state.status == ContractsStatus.initial) emit(state.copyWith(status: ContractsStatus.loading));
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
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> fetchDeletedContracts() async {
    try {
      final deleted = await _erpRepository.getDeletedContracts();
      emit(state.copyWith(deletedContracts: deleted));
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

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
    // 🌟 [التعديل الأول]: أضفنا حقول التسليم المتفق عليها عند توقيع العقد
    DateTime? agreedHandoverDate, 
    int? gracePeriodMonths,
    double? histIron,
    double? histCement,
    double? histBlock,
    double? histFormwork,
    double? histAggregates,
    double? histWorker,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading)); 
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً لإنشاء العقود.');

      final contractDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();

      // 1. تسجيل التسعيرة التاريخية إن وجدت
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

      // 2. توليد ID العقد
      final String newContractId = const Uuid().v7();

      // 3. إنشاء العقد
      final newContract = ContractsCompanion.insert(
        id: Value(newContractId),
        clientId: clientId,
        apartmentId: Value(apartmentId), 
        contractType: Value(contractType),
        apartmentDetails: Value(details), 
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        downPayment: Value(downPayment), 
        
        // 🌟 [التعديل الثاني]: تمرير الحقول الجديدة لقاعدة البيانات
        agreedHandoverDate: agreedHandoverDate != null ? Value(agreedHandoverDate.toUtc()) : const Value.absent(),
        gracePeriodMonths: Value(gracePeriodMonths ?? 0),
        
        installmentsCount: Value(installmentsCount), 
        agreedMonthlyAmount: Value(agreedMonthlyAmount), 
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: contractDateToSave, 
        guarantorName: guarantorName, 
        userId: userId, 
      );
      
      await _erpRepository.addContract(newContract);

      // 4. السحر المحاسبي: إدخال الدفعة الأولى في الأقساط
      if (downPayment > 0) {
        final downPaymentEntry = PaymentsLedgerCompanion.insert(
          contractId: newContractId, 
          paymentDate: contractDateToSave, 
          amountPaid: downPayment, 
          meterPriceAtPayment: basePrice, 
          convertedMeters: basePrice > 0 ? (downPayment / basePrice) : 0, 
          pricesSnapshot: const Value('{"note": "الدفعة الأولى عند توقيع العقد"}'),
          userId: userId,
        );
        await _erpRepository.addLedgerEntry(downPaymentEntry);
      }
      
      // 5. تحديث حالة الشقة إلى مباعة
      if (apartmentId != null && apartmentId.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(apartmentId, 'sold');
      }

      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> attachContractFile({required String contractId, required String filePath, required String extension}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final file = File(filePath);
      await _erpRepository.attachFileToContract(contractId, file, extension);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل إرفاق الملف: $e'));
    }
  }

  Future<void> deleteContract(String id) async { 
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contractToCancel = state.contracts.firstWhere((c) => c.id == id);
      await _erpRepository.deleteContract(id);

      if (contractToCancel.apartmentId != null && contractToCancel.apartmentId!.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(contractToCancel.apartmentId!, 'available');
      }
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> restoreContract(Contract contract) async {
    try {
      await _erpRepository.restoreContract(contract.id);
      if (contract.apartmentId != null && contract.apartmentId!.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(contract.apartmentId!, 'sold');
      }
      await fetchDeletedContracts(); 
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> forceHardDelete(String contractId) async {
    try {
      await _erpRepository.forceHardDeleteContract(contractId);
      await fetchDeletedContracts(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateContract({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
    required double agreedMonthlyAmount, 
    required DateTime contractDate, 
  }) async {
    try {
      await _erpRepository.updateContract(
        id: id,
        apartmentDetails: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
        agreedMonthlyAmount: agreedMonthlyAmount, 
        contractDate: contractDate, 
      );
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'حدث خطأ أثناء تعديل العقد: $e'));
    }
  }


  // ==========================================
  // 🔑 تسجيل تسليم الشقة الفعلي (Handover)
  // ==========================================
  Future<void> markContractAsHandedOver({
    required String contractId,
    required DateTime actualHandoverDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == contractId);
      
      // نرسل العقد والشقة بطلب واحد للـ Repository
      await _erpRepository.markContractAsHandedOver(
        contractId: contractId,
        apartmentId: contract.apartmentId, // 🌟 تمرير رقم الشقة
        actualHandoverDate: actualHandoverDate,
        notes: notes,
      );
      
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل عملية تسليم الشقة: $e'));
    }
  }

  // ==========================================
  // ⏪ التراجع عن تسليم الشقة
  // ==========================================
  Future<void> cancelContractHandover({required String contractId}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == contractId);
      
      await _erpRepository.cancelContractHandover(
        contractId: contractId,
        apartmentId: contract.apartmentId, // 🌟 تمرير رقم الشقة
      );
      
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل إلغاء التسليم: $e'));
    }
  }

}