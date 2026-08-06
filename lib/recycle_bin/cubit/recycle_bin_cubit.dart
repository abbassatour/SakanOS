// lib/recycle_bin/cubit/recycle_bin_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

part 'recycle_bin_state.dart';

class RecycleBinCubit extends Cubit<RecycleBinState> {
  RecycleBinCubit(this._erpRepository) : super(const RecycleBinState());

  final ErpRepository _erpRepository;

  Future<void> loadAllDeletedData() async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final delBuildings = await _erpRepository.getDeletedBuildings();
      final delApartments = await _erpRepository.getDeletedApartments();
      final delClients = await _erpRepository.getDeletedClients();
      final delContracts = await _erpRepository.getDeletedContracts();
      final delPayments = await _erpRepository.getDeletedLedgerEntries();

      final activeBuildings = await _erpRepository.getBuildings();
      final activeClients = await _erpRepository.getClients();
      final activeContracts = await _erpRepository.getAllContracts();

      final allClients = [...activeClients, ...delClients];
      final allContracts = [...activeContracts, ...delContracts];
      final allBuildings = [...activeBuildings, ...delBuildings];

      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          status: RecycleBinStatus.success,
          deletedBuildings: delBuildings,
          deletedApartments: delApartments,
          deletedClients: delClients,
          deletedContracts: delContracts,
          deletedPayments: delPayments,
          referenceClients: allClients,
          referenceContracts: allContracts,
          referenceBuildings: allBuildings,
          userNamesMap: namesMap,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreBuilding(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      await _erpRepository.restoreBuilding(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreApartment(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final apt = state.deletedApartments.firstWhere((a) => a.id == id);
      final building = state.referenceBuildings.firstWhere(
        (b) => b.id == apt.buildingId,
      );

      if (building.isDeleted) {
        emit(
          state.copyWith(
            status: RecycleBinStatus.failure,
            errorMessage:
                'recycleErrorRestoreAptBuildingDeleted:${building.name}',
          ),
        );
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }

      await _erpRepository.restoreApartment(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreClient(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      await _erpRepository.restoreClient(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> restoreContract(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final contract = state.deletedContracts.firstWhere((c) => c.id == id);

      final client = state.referenceClients.firstWhere(
        (c) => c.id == contract.clientId,
      );
      if (client.isDeleted) {
        emit(
          state.copyWith(
            status: RecycleBinStatus.failure,
            errorMessage:
                'recycleErrorRestoreContractClientDeleted:${client.name}',
          ),
        );
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }

      if (contract.apartmentId != null) {
        final isApartmentDeleted = state.deletedApartments.any(
          (a) => a.id == contract.apartmentId,
        );
        if (isApartmentDeleted) {
          emit(
            state.copyWith(
              status: RecycleBinStatus.failure,
              errorMessage: 'recycleErrorRestoreContractAptDeleted',
            ),
          );
          emit(state.copyWith(status: RecycleBinStatus.success));
          return;
        }
      }

      await _erpRepository.restoreContract(
        id,
        contract.apartmentId,
        contract.isHandedOver,
      );

      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      emit(state.copyWith(status: RecycleBinStatus.success));
    }
  }

  Future<void> restorePayment(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final payment = state.deletedPayments.firstWhere((p) => p.id == id);
      final contract = state.referenceContracts.firstWhere(
        (c) => c.id == payment.contractId,
      );

      if (contract.isDeleted) {
        emit(
          state.copyWith(
            status: RecycleBinStatus.failure,
            errorMessage: 'recycleErrorRestorePaymentContractDeleted',
          ),
        );
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }

      await _erpRepository.restoreLedgerEntry(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeleteBuilding(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      await _erpRepository.forceHardDeleteBuilding(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeleteApartment(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final isLinkedToContract = state.referenceContracts.any(
        (c) => c.apartmentId == id,
      );
      if (isLinkedToContract) {
        emit(
          state.copyWith(
            status: RecycleBinStatus.failure,
            errorMessage: 'recycleErrorHardDeleteAptHasContract',
          ),
        );
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }

      await _erpRepository.forceHardDeleteApartment(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeleteClient(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final hasContracts = state.referenceContracts.any(
        (c) => c.clientId == id,
      );
      if (hasContracts) {
        emit(
          state.copyWith(
            status: RecycleBinStatus.failure,
            errorMessage: 'recycleErrorHardDeleteClientHasContracts',
          ),
        );
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }

      await _erpRepository.forceHardDeleteClient(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeleteContract(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      await _erpRepository.forceHardDeleteContract(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> hardDeletePayment(String id) async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      await _erpRepository.forceHardDeleteLedgerEntry(id);
      await loadAllDeletedData();
    } catch (e) {
      emit(
        state.copyWith(
          status: RecycleBinStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
