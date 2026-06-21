// lib/clients/cubit/clients_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit({
    required ErpRepository erpRepository,
  })  : _erpRepository = erpRepository,
        super(const ClientsState());

  final ErpRepository _erpRepository;

  Future<void> fetchClients() async {
    if (state.status == ClientsStatus.initial) {
      emit(state.copyWith(status: ClientsStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();
      final allUsers = await _erpRepository.getAllUsers();

      final namesMap = <String, String>{
        for (final user in allUsers)
          user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          status: ClientsStatus.success,
          clients: clients,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addClient({
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    try {
      // 🌟 السحر النظيف: تمرير النصوص فقط! 
      await _erpRepository.addClient(
        name: name,
        phone: phone,
        nationalId: nationalId,
      );

      await fetchClients();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: 'حدث خطأ أثناء إضافة العميل: $e',
        ),
      );
    }
  }

  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    try {
      await _erpRepository.updateClient(
        id: id,
        name: name,
        phone: phone,
        nationalId: nationalId,
      );

      await fetchClients();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: 'حدث خطأ أثناء تعديل بيانات العميل: $e',
        ),
      );
    }
  }

  Future<void> fetchDeletedClients() async {
    try {
      final deleted = await _erpRepository.getDeletedClients();
      emit(state.copyWith(deletedClients: deleted));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreClient(String clientId) async {
    try {
      await _erpRepository.restoreClient(clientId);
      await fetchDeletedClients();
      await fetchClients();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> forceHardDelete(String clientId) async {
    try {
      await _erpRepository.forceHardDeleteClient(clientId);
      await fetchDeletedClients();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      final clientContracts = await _erpRepository.getContractsForClient(
        clientId,
      );

      if (clientContracts.isNotEmpty) {
        emit(
          state.copyWith(
            status: ClientsStatus.failure,
            errorMessage: 'تحذير أمني: لا يمكن حذف العميل لأن لديه عقود مسجلة. '
                'الرجاء إلغاء عقوده أولاً لكي تعود الشقق للكتالوج.',
          ),
        );
        return;
      }

      await _erpRepository.deleteClient(clientId);
      await fetchClients();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
