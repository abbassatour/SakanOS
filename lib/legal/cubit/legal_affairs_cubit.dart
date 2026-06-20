// lib/legal/cubit/legal_affairs_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Client, Contract, LegalAction, LegalActionAttachment;

part 'legal_affairs_state.dart';

class LegalAffairsCubit extends Cubit<LegalAffairsState> {
  LegalAffairsCubit(this._erpRepository) : super(const LegalAffairsState());

  final ErpRepository _erpRepository;

  Future<void> fetchData() async {
    if (state.status == LegalAffairsStatus.initial) {
      emit(state.copyWith(status: LegalAffairsStatus.loading));
    }

    try {
      final allClients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts();

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers)
          user.id: user.fullName ?? 'مدير النظام',
      };

      final allActions = await _erpRepository.getAllLegalActions();
      final allAttachments =
          await _erpRepository.getAllLegalActionAttachments();

      final attachmentsMap = <String, List<LegalActionAttachment>>{};
      for (final attachment in allAttachments) {
        if (!attachmentsMap.containsKey(attachment.legalActionId)) {
          attachmentsMap[attachment.legalActionId] = [];
        }
        attachmentsMap[attachment.legalActionId]!.add(attachment);
      }

      allActions.sort((a, b) => b.actionDate.compareTo(a.actionDate));

      emit(
        state.copyWith(
          status: LegalAffairsStatus.success,
          actions: allActions,
          attachmentsMap: attachmentsMap,
          contracts: allContracts,
          clients: allClients,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: 'خطأ في جلب بيانات الأرشيف: $e',
        ),
      );
    }
  }

  Future<void> updateLegalAction({
    required String actionId,
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.updateLegalAction(
        actionId: actionId,
        contractId: contractId,
        actionType: actionType,
        actionDate: actionDate,
        notes: notes,
      );
      await fetchData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: 'خطأ في التعديل: $e',
        ),
      );
    }
  }

  Future<void> addLegalAction({
    required String contractId,
    required String actionType,
    required DateTime actionDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.addLegalAction(
        contractId: contractId,
        actionType: actionType,
        actionDate: actionDate,
        notes: notes,
      );

      await fetchData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteLegalAction(String actionId) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.deleteLegalAction(actionId);
      await fetchData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

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
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: 'فشل إرفاق الملف: $e',
        ),
      );
    }
  }

  Future<void> deleteAttachment(String attachmentId) async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      await _erpRepository.deleteLegalActionAttachment(attachmentId);
      await fetchData();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LegalAffairsStatus.failure,
          errorMessage: 'فشل حذف المرفق: $e',
        ),
      );
    }
  }
}