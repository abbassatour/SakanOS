// lib/recycle_bin/cubit/recycle_bin_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

part 'recycle_bin_state.dart';

class RecycleBinCubit extends Cubit<RecycleBinState> {
  RecycleBinCubit(this._erpRepository) : super(const RecycleBinState());

  final ErpRepository _erpRepository;

  /// جلب كافة البيانات المحذوفة والفعالة (كـ مراجع)
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

      final allClients =[...activeClients, ...delClients];
      final allContracts = [...activeContracts, ...delContracts];
      final allBuildings =[...activeBuildings, ...delBuildings];

      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
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
      ));
    } catch (e) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // ♻️ حماية دوال الاستعادة (Restore Safeguards)
  // ==========================================

  Future<void> restoreBuilding(String id) async {
    // المحضر هو الأب الأكبر، مسموح استعادته دائماً
    await _erpRepository.restoreBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> restoreApartment(String id) async {
    // 🛡️ حماية الاستعادة: هل المحضر محذوف؟
    final apt = state.deletedApartments.firstWhere((a) => a.id == id);
    final building = state.referenceBuildings.firstWhere((b) => b.id == apt.buildingId);
    
    if (building.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكنك استعادة هذه الشقة لأن محضرها التابعة له (${building.name}) لا يزال محذوفاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success)); 
      return;
    }

    await _erpRepository.restoreApartment(id);
    await loadAllDeletedData();
  }

  Future<void> restoreClient(String id) async {
    // العميل هو أب، مسموح استعادته دائماً
    await _erpRepository.restoreClient(id);
    await loadAllDeletedData();
  }

  Future<void> restoreContract(String id) async {
    final contract = state.deletedContracts.firstWhere((c) => c.id == id);
    
    // 🛡️ حماية الاستعادة 1: هل العميل محذوف؟
    final client = state.referenceClients.firstWhere((c) => c.id == contract.clientId);
    if (client.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ العميل (${client.name}) الخاص بهذا العقد لا يزال محذوفاً. الرجاء استعادته أولاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    // 🛡️ حماية الاستعادة 2: هل الشقة محذوفة؟
    if (contract.apartmentId != null) {
      final isApartmentDeleted = state.deletedApartments.any((a) => a.id == contract.apartmentId);
      if (isApartmentDeleted) {
        emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ الوحدة العقارية المرتبطة بهذا العقد لا تزال محذوفة. الرجاء استعادتها أولاً.'));
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }
    }

    await _erpRepository.restoreContract(id);
    await loadAllDeletedData();
  }

  Future<void> restorePayment(String id) async {
    // 🛡️ حماية الاستعادة: هل العقد محذوف؟
    final payment = state.deletedPayments.firstWhere((p) => p.id == id);
    final contract = state.referenceContracts.firstWhere((c) => c.id == payment.contractId);

    if (contract.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكنك استعادة هذه الدفعة لأن عقدها لا يزال محذوفاً. الرجاء استعادة العقد أولاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    await _erpRepository.restoreLedgerEntry(id);
    await loadAllDeletedData();
  }

  // ==========================================
  // 💥 حماية دوال التدمير النهائي (Hard Delete Safeguards)
  // ==========================================
  
  Future<void> hardDeleteBuilding(String id) async {
    // آمنة: القاعدة تقوم بحذف الشقق التابعة له آلياً (Cascade Delete).
    await _erpRepository.forceHardDeleteBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteApartment(String id) async {
    // 🛡️ حماية التدمير: هل الشقة مرتبطة بعقد؟
    final isLinkedToContract = state.referenceContracts.any((c) => c.apartmentId == id);
    if (isLinkedToContract) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكن تدمير هذه الوحدة لأنها مرتبطة بعقد بيع (سواء فعال أو محذوف). يجب تدمير العقد أولاً!'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    await _erpRepository.forceHardDeleteApartment(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteClient(String id) async {
    // 🛡️ حماية التدمير الأهم: هل العميل لديه عقود؟
    final hasContracts = state.referenceContracts.any((c) => c.clientId == id);
    if (hasContracts) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكن تدمير هذا العميل لارتباطه بعقود في النظام. الرجاء تدمير عقوده أولاً ليُسمح لك بذلك.'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    await _erpRepository.forceHardDeleteClient(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteContract(String id) async {
    // آمنة: القاعدة تقوم بحذف الدفعات والأقساط التابعة له آلياً (Cascade Delete).
    await _erpRepository.forceHardDeleteContract(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeletePayment(String id) async {
    await _erpRepository.forceHardDeleteLedgerEntry(id);
    await loadAllDeletedData();
  }
}