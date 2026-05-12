import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, LegalActionsCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

part 'legal_actions_state.dart';

class LegalActionsCubit extends Cubit<LegalActionsState> {
  LegalActionsCubit(this._erpRepository) : super(const LegalActionsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 1. جلب السجل القانوني لعقد معين
  // ==========================================
  Future<void> fetchLegalActions(String contractId) async {
    emit(state.copyWith(status: LegalActionsStatus.loading));
    try {
      final actions = await _erpRepository.getLegalActionsForContract(contractId);
      
      // جلب الأسماء لمعرفة من المحامي/الموظف الذي أضاف الإجراء
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مجهول'
      };

      emit(state.copyWith(
        status: LegalActionsStatus.success,
        actionsList: actions,
        userNamesMap: namesMap,
      ));
    } catch (e) {
      emit(state.copyWith(status: LegalActionsStatus.failure, errorMessage: e.toString()));
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
    String? attachmentUrl,
  }) async {
    emit(state.copyWith(status: LegalActionsStatus.loading));
    try {
      final newActionId = const Uuid().v7(); // 🌟 توليد ID فريد للإجراء

      final newAction = LegalActionsCompanion.insert(
        id: Value(newActionId),
        contractId: contractId,
        actionType: actionType,
        actionDate: actionDate.toUtc(), // 🌍 حماية الـ UTC
        notes: Value(notes),
        attachmentUrl: Value(attachmentUrl),
      );

      await _erpRepository.addLegalAction(newAction);
      
      // تحديث القائمة فوراً بعد الإضافة
      await fetchLegalActions(contractId);
    } catch (e) {
      emit(state.copyWith(status: LegalActionsStatus.failure, errorMessage: 'فشل إضافة الإجراء: $e'));
    }
  }

  // ==========================================
  // 3. حذف إجراء قانوني (للمدير)
  // ==========================================
  Future<void> deleteLegalAction({required String actionId, required String contractId}) async {
    emit(state.copyWith(status: LegalActionsStatus.loading));
    try {
      await _erpRepository.deleteLegalAction(actionId);
      
      // تحديث القائمة فوراً بعد الحذف
      await fetchLegalActions(contractId);
    } catch (e) {
      emit(state.copyWith(status: LegalActionsStatus.failure, errorMessage: 'فشل حذف الإجراء: $e'));
    }
  }
}