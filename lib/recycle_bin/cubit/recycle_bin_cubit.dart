// lib/recycle_bin/cubit/recycle_bin_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

part 'recycle_bin_state.dart';

class RecycleBinCubit extends Cubit<RecycleBinState> {
  RecycleBinCubit(this._erpRepository) : super(const RecycleBinState());

  final ErpRepository _erpRepository;

  /// جلب كافة البيانات المحذوفة في النظام مع بياناتها المرجعية
  Future<void> loadAllDeletedData() async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      // 1. جلب البيانات المحذوفة
      final delBuildings = await _erpRepository.getDeletedBuildings();
      final delApartments = await _erpRepository.getDeletedApartments();
      final delClients = await _erpRepository.getDeletedClients();
      final delContracts = await _erpRepository.getDeletedContracts();
      final delPayments = await _erpRepository.getDeletedLedgerEntries();

      // 2. 🌟 جلب البيانات المرجعية (الفعالة)
      final activeBuildings = await _erpRepository.getBuildings();
      final activeClients = await _erpRepository.getClients();
      final activeContracts = await _erpRepository.getAllContracts();

      // 3. 🌟 دمج الفعال والمحذوف معاً ليكون المرجع شاملاً لأي عنصر نبحث عنه
      final allClients = [...activeClients, ...delClients];
      final allContracts = [...activeContracts, ...delContracts];
      final allBuildings =[...activeBuildings, ...delBuildings];

      // 4. 🌟 جلب المستخدمين وصنع قاموس الأسماء (لمعرفة من الذي حذف)
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
        
        // 🌟 تمرير المراجع
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
  // ♻️ دوال الاستعادة (Restore)
  // ==========================================
  Future<void> restoreBuilding(String id) async {
    await _erpRepository.restoreBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> restoreApartment(String id) async {
    await _erpRepository.restoreApartment(id);
    await loadAllDeletedData();
  }

  Future<void> restoreClient(String id) async {
    await _erpRepository.restoreClient(id);
    await loadAllDeletedData();
  }

  Future<void> restoreContract(String id) async {
    await _erpRepository.restoreContract(id);
    await loadAllDeletedData();
  }

  Future<void> restorePayment(String id) async {
    await _erpRepository.restoreLedgerEntry(id);
    await loadAllDeletedData();
  }

  // ==========================================
  // 💥 دوال الحذف النهائي (Hard Delete)
  // ==========================================
  Future<void> hardDeleteBuilding(String id) async {
    await _erpRepository.forceHardDeleteBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteApartment(String id) async {
    await _erpRepository.forceHardDeleteApartment(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteClient(String id) async {
    await _erpRepository.forceHardDeleteClient(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteContract(String id) async {
    await _erpRepository.forceHardDeleteContract(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeletePayment(String id) async {
    await _erpRepository.forceHardDeleteLedgerEntry(id);
    await loadAllDeletedData();
  }
}