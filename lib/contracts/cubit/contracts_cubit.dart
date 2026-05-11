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

  // ==========================================
  // 1. جلب البيانات الأساسية
  // ==========================================
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

  // ==========================================
  // 2. جلب العقود المحذوفة
  // ==========================================
  Future<void> fetchDeletedContracts() async {
    try {
      final deleted = await _erpRepository.getDeletedContracts();
      emit(state.copyWith(deletedContracts: deleted));
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 3. إضافة عقد جديد (مع كافة الميزات الحديثة)
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
    
    // 🌟 متغيرات التسليم المتفق عليها 
    DateTime? agreedHandoverDate, 
    int? gracePeriodMonths,
    
    // 🌟 متغيرات الغرامة المرنة
    bool isPenaltyActive = false,
    double penaltyPercentage = 0.0,
    int penaltyIntervalMonths = 1,

    // متغيرات الأسعار التاريخية
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

      // أ. تسجيل التسعيرة التاريخية إن وجدت
      if (customDate != null && histIron != null) {
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(contractDateToSave), 
          ironPrice: histIron, cementPrice: histCement!, block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!, aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!, userId: userId, 
        );
        await _erpRepository.savePrices(historicalPrices);
      }

      // ب. توليد ID العقد
      final String newContractId = const Uuid().v7();

      // ج. إنشاء العقد
      final newContract = ContractsCompanion.insert(
        id: Value(newContractId),
        clientId: clientId,
        apartmentId: Value(apartmentId), 
        contractType: Value(contractType),
        apartmentDetails: Value(details), 
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        downPayment: Value(downPayment), 
        
        agreedHandoverDate: agreedHandoverDate != null ? Value(agreedHandoverDate.toUtc()) : const Value.absent(),
        gracePeriodMonths: Value(gracePeriodMonths ?? 0),
        
        // 🌟 حفظ متغيرات الغرامة في قاعدة البيانات
        isPenaltyActive: Value(isPenaltyActive),
        penaltyPercentage: Value(penaltyPercentage),
        penaltyIntervalMonths: Value(penaltyIntervalMonths),
        
        installmentsCount: Value(installmentsCount), 
        agreedMonthlyAmount: Value(agreedMonthlyAmount), 
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: contractDateToSave, 
        guarantorName: guarantorName, 
        userId: userId, 
      );
      
      await _erpRepository.addContract(newContract);

      // د. السحر المحاسبي: إدخال الدفعة الأولى في الأقساط
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
      
      // هـ. تحديث حالة الشقة إلى مباعة
      if (apartmentId != null && apartmentId.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(apartmentId, 'sold');
      }

      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 4. إرفاق ملف العقد
  // ==========================================
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

  // ==========================================
  // 5. الحذف الوهمي للعقد (ينقله لسلة المحذوفات)
  // ==========================================
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

  // ==========================================
  // 6. استعادة العقد من سلة المحذوفات
  // ==========================================
  Future<void> restoreContract(Contract contract) async {
    try {
      await _erpRepository.restoreContract(contract.id);
      
      if (contract.apartmentId != null && contract.apartmentId!.isNotEmpty) {
        // 🌟 [اللمسة السحرية]: نتحقق، هل كان العقد مُسلّماً قبل حذفه؟
        final targetStatus = contract.isHandedOver ? 'delivered' : 'sold';
        await _erpRepository.changeApartmentStatus(contract.apartmentId!, targetStatus);
      }
      
      await fetchDeletedContracts(); 
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 7. الحذف النهائي للعقد (تدمير)
  // ==========================================
  Future<void> forceHardDelete(String contractId) async {
    try {
      await _erpRepository.forceHardDeleteContract(contractId);
      await fetchDeletedContracts(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 8. تعديل العقد (أضفنا متغيرات الغرامة هنا أيضاً)
  // ==========================================
  Future<void> updateContract({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
    required double agreedMonthlyAmount, 
    required DateTime contractDate,
    // 🌟 متغيرات الغرامة لتعديلها لاحقاً
    required bool isPenaltyActive,
    required double penaltyPercentage,
    required int penaltyIntervalMonths,
  }) async {
    try {
      await _erpRepository.updateContract(
        id: id,
        apartmentDetails: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
        agreedMonthlyAmount: agreedMonthlyAmount, 
        contractDate: contractDate, 
        isPenaltyActive: isPenaltyActive,
        penaltyPercentage: penaltyPercentage,
        penaltyIntervalMonths: penaltyIntervalMonths,
      );
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'حدث خطأ أثناء تعديل العقد: $e'));
    }
  }

  // ==========================================
  // 9. تسجيل تسليم الشقة الفعلي (Handover)
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
  // 10. التراجع عن تسليم الشقة
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

  // ==========================================
  // 11. 🔒 إغلاق/أرشفة العقد أو إعادة فتحه
  // ==========================================
  Future<void> toggleContractCompletion({required String contractId, required bool isCompleted}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.toggleContractCompletion(
        contractId: contractId,
        isCompleted: isCompleted,
      );
      
      await fetchData(); // تحديث الواجهة فوراً
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل تغيير حالة العقد: $e'));
    }
  }
  



  // ==========================================
  // 12. ✍️ توثيق توقيع براءة الذمة الأولية والتجهيزات المشتركة
  // ==========================================
  Future<void> signInitialClearance({
    required String contractId,
    required bool isSigned,
    String? notes,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      // 🌟 تم نقل الجهد للـ Repository ليصبح الكيوبت نظيفاً
      await _erpRepository.signInitialClearance(
        contractId: contractId,
        isSigned: isSigned,
        notes: notes,
      );
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل توثيق براءة الذمة: $e'));
    }
  }

  // ==========================================
  // 13. 🏛️ توثيق نقل الملكية (الفراغ والطابو)
  // ==========================================
  Future<void> transferTitleDeed({
    required String contractId,
    required bool isTransferred,
    DateTime? transferDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.transferTitleDeed(
        contractId: contractId,
        isTransferred: isTransferred,
        transferDate: transferDate,
        notes: notes,
      );
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل توثيق نقل الملكية: $e'));
    }
  }
}