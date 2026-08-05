// lib/contracts/cubit/contracts_cubit.dart
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  Future<void> fetchData() async {
    if (state.status == ContractsStatus.initial) {
      emit(state.copyWith(status: ContractsStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      // 🌟 جلب المرفقات وتوزيعها
      final allAttachments = await _erpRepository.getAllContractAttachments();
      final attachmentsMap = <String, List<ContractAttachment>>{};
      for (final att in allAttachments) {
        attachmentsMap.putIfAbsent(att.contractId, () => []).add(att);
      }

      emit(
        state.copyWith(
          status: ContractsStatus.success,
          clients: clients,
          contracts: allContracts,
          userNamesMap: namesMap,
          attachmentsMap: attachmentsMap, // 🌟 حفظ المرفقات في الـ State
        ),
      );
    } catch (e, stackTrace) {
      log('خطأ في جلب بيانات العقود', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchDeletedContracts() async {
    try {
      final deleted = await _erpRepository.getDeletedContracts();
      emit(state.copyWith(deletedContracts: deleted));
    } catch (e, stackTrace) {
      log('خطأ في جلب العقود المحذوفة', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
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
      await _erpRepository.addContract(
        clientId: clientId,
        contractType: contractType,
        details: details,
        apartmentId: apartmentId,
        area: area,
        basePrice: basePrice,
        downPayment: downPayment,
        installmentsCount: installmentsCount,
        guarantorName: guarantorName,
        agreedMonthlyAmount: agreedMonthlyAmount,
        coefficients: coefficients,
        customDate: customDate,
        agreedHandoverDate: agreedHandoverDate,
        gracePeriodMonths: gracePeriodMonths,
        isPenaltyActive: isPenaltyActive,
        penaltyPercentage: penaltyPercentage,
        penaltyIntervalMonths: penaltyIntervalMonths,
        histIron: histIron,
        histCement: histCement,
        histBlock: histBlock,
        histFormwork: histFormwork,
        histAggregates: histAggregates,
        histWorker: histWorker,
        histDollarRate: histDollarRate,
      );

      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في إنشاء عقد جديد', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================
  // 📎 دوال إدارة المرفقات المتعددة (النظام الجديد)
  // ==========================================

  Future<void> attachFileToContractGallery({
    required String contractId,
    required String filePath,
    required String extension,
    required String originalFileName,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final file = File(filePath);

      await _erpRepository.attachFileToContractGallery(
        contractId: contractId,
        file: file,
        extension: extension,
        originalFileName: originalFileName,
      );

      await fetchData(); // تحديث الواجهة بعد الرفع
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إرفاق الملف: $e',
        ),
      );
    }
  }

  Future<void> deleteContractAttachment(String attachmentId) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.deleteContractAttachment(attachmentId);
      await fetchData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل حذف المرفق: $e',
        ),
      );
    }
  }

  Future<String?> getSecureAttachmentUrl(String storedPath) async {
    try {
      // 🌟 نطلب الرابط الآمن من السلة الجديدة contract_attachments
      return await _erpRepository.resolveFileUrl(
        'contract_attachments',
        storedPath,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إنشاء الرابط الآمن: $e',
        ),
      );
      return null;
    }
  }

  Future<void> deleteContract(String id) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contractToCancel = state.contracts.firstWhere((c) => c.id == id);

      await _erpRepository.deleteContract(id, contractToCancel.apartmentId);

      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في حذف العقد', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreContract(Contract contract) async {
    try {
      await _erpRepository.restoreContract(
        contract.id,
        contract.apartmentId,
        contract.isHandedOver,
      );

      await fetchDeletedContracts();
      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في استعادة العقد', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> forceHardDelete(String contractId) async {
    try {
      await _erpRepository.forceHardDeleteContract(contractId);
      await fetchDeletedContracts();
    } catch (e, stackTrace) {
      log('خطأ في تدمير العقد نهائياً', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

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
      await _erpRepository.updateContract(
        id: id,
        details: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
        agreedMonthlyAmount: agreedMonthlyAmount,
        contractDate: contractDate,
        isPenaltyActive: isPenaltyActive,
        penaltyPercentage: penaltyPercentage,
        penaltyIntervalMonths: penaltyIntervalMonths,
      );
      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في تعديل العقد', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'حدث خطأ أثناء تعديل العقد: $e',
        ),
      );
    }
  }

  Future<void> markContractAsHandedOver({
    required String contractId,
    required DateTime actualHandoverDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == contractId);

      await _erpRepository.markContractAsHandedOver(
        contractId: contractId,
        apartmentId: contract.apartmentId,
        actualHandoverDate: actualHandoverDate,
        notes: notes,
      );

      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في تسليم الشقة', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل عملية تسليم الشقة: $e',
        ),
      );
    }
  }

  Future<void> cancelContractHandover({required String contractId}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == contractId);

      await _erpRepository.cancelContractHandover(
        contractId: contractId,
        apartmentId: contract.apartmentId,
      );

      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في إلغاء استلام الشقة', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إلغاء التسليم: $e',
        ),
      );
    }
  }

  Future<void> toggleContractCompletion({
    required String contractId,
    required bool isCompleted,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.toggleContractCompletion(
        contractId: contractId,
        isCompleted: isCompleted,
      );

      await fetchData();
    } catch (e, stackTrace) {
      log('خطأ في إغلاق العقد/أرشفته', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل تغيير حالة العقد: $e',
        ),
      );
    }
  }

  Future<String?> getSecureContractUrl(String storedPath) async {
    try {
      return await _erpRepository.resolveFileUrl('erp_contracts', storedPath);
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractsStatus.failure,
          errorMessage: 'فشل إنشاء الرابط الآمن: $e',
        ),
      );
      return null;
    }
  }
}
