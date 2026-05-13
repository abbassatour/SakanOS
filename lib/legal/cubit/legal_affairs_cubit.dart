// lib/legal/cubit/legal_affairs_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalActionsCompanion, LegalAction, LegalActionAttachment, Contract, Client;
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

part 'legal_affairs_state.dart';

class LegalAffairsCubit extends Cubit<LegalAffairsState> {
  LegalAffairsCubit(this._erpRepository) : super(const LegalAffairsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 1. جلب كل البيانات (التحميل الأولي)
  // ==========================================
  Future<void> fetchData() async {
    if (state.status == LegalAffairsStatus.initial) emit(state.copyWith(status: LegalAffairsStatus.loading));
    
    try {
      // 1. جلب البيانات المساعدة (للربط)
      final allClients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts();
      
      // جلب قاموس الموظفين
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      // 2. جلب كل الإجراءات القانونية والمرفقات من الـ Repo
      final allActions = await _erpRepository.getAllLegalActions();
      final allAttachments = await _erpRepository.getAllLegalActionAttachments();

      // 3. تصنيف المرفقات في Map لسهولة وصول الواجهة إليها (بدون فلترة متكررة)
      final Map<String, List<LegalActionAttachment>> attachmentsMap = {};
      for (var attachment in allAttachments) {
        if (!attachmentsMap.containsKey(attachment.legalActionId)) {
          attachmentsMap[attachment.legalActionId] =[];
        }
        attachmentsMap[attachment.legalActionId]!.add(attachment);
      }

      // ترتيب الإجراءات من الأحدث للأقدم
      allActions.sort((a, b) => b.actionDate.compareTo(a.actionDate));

      emit(state.copyWith(
        status: LegalAffairsStatus.success,
        actions: allActions,
        attachmentsMap: attachmentsMap,
        contracts: allContracts,
        clients: allClients,
        userNamesMap: namesMap,
      ));
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: 'خطأ في جلب بيانات الأرشيف: $e'));
    }
  }

  // ==========================================
  // تعديل إجراء قانوني موجود
  // ==========================================
  Future<void> updateLegalAction({
    required String actionId,
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      // نجهز الكائن للتحديث
      final updatedAction = LegalActionsCompanion(
        id: Value(actionId),
        contractId: Value(contractId),
        actionType: Value(actionType),
        actionDate: Value(actionDate.toUtc()),
        notes: Value(notes),
      );

      await _erpRepository.updateLegalAction(updatedAction);
      await fetchData(); // تحديث القائمة بعد التعديل
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: 'خطأ في التعديل: $e'));
    }
  }

  // ==========================================
  // 2. إضافة إجراء قانوني جديد
  // ==========================================
  Future<void> addLegalAction({
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

      final newAction = LegalActionsCompanion.insert(
        id: Value(const Uuid().v7()),
        contractId: contractId,
        actionType: actionType,
        actionDate: actionDate.toUtc(),
        notes: Value(notes),
        userId: userId,
      );

      await _erpRepository.addLegalAction(newAction);
      
      // تسجيل ملاحظة على العقد نفسه للإدارة
      await _erpRepository.markContractActionTaken(
        contractId: contractId, 
        note: 'تم اتخاذ إجراء قانوني: $actionType',
      );

      await fetchData(); // تحديث القائمة
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 3. الحذف الوهمي لإجراء قانوني
  // ==========================================
  Future<void> deleteLegalAction(String actionId) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.deleteLegalAction(actionId);
      await fetchData();
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 4. إرفاق ملف/صورة للإجراء القانوني
  // ==========================================
  Future<void> attachFileToAction({
    required String actionId,
    required String filePath,
    required String extension,
    required String originalFileName,
  }) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      final file = File(filePath);
      
      await _erpRepository.attachFileToLegalAction(
        actionId: actionId,
        file: file,
        extension: extension,
        originalFileName: originalFileName,
      );
      
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: 'فشل إرفاق الملف: $e'));
    }
  }

  // ==========================================
  // 5. حذف مرفق
  // ==========================================
  Future<void> deleteAttachment(String attachmentId) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.deleteLegalActionAttachment(attachmentId);
      await fetchData();
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: 'فشل حذف المرفق: $e'));
    }
  }
}