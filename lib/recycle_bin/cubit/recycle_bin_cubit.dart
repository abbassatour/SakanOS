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
  // ♻️ دوال الاستعادة (مع نظام الحماية الذكي)
  // ==========================================

  Future<void> restoreBuilding(String id) async {
    // المحضر هو "الأب الأكبر"، استعادته مسموحة دائماً وسيقوم الـ Repository باستعادة شققه آلياً
    await _erpRepository.restoreBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> restoreApartment(String id) async {
    // 🛡️ حماية: التحقق من أن المحضر غير محذوف
    final apt = state.deletedApartments.firstWhere((a) => a.id == id);
    final building = state.referenceBuildings.firstWhere((b) => b.id == apt.buildingId);
    
    if (building.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكنك استعادة هذه الشقة لأن المحضر التابعة له (${building.name}) لا يزال في سلة المحذوفات. الرجاء استعادة المحضر أولاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success)); // تصفير الحالة بعد عرض الخطأ
      return;
    }

    await _erpRepository.restoreApartment(id);
    await loadAllDeletedData();
  }

  Future<void> restoreClient(String id) async {
    // العميل هو "أب"، استعادته مسموحة دائماً
    await _erpRepository.restoreClient(id);
    await loadAllDeletedData();
  }

  Future<void> restoreContract(String id) async {
    // 🛡️ حماية: التحقق من العميل والشقة
    final contract = state.deletedContracts.firstWhere((c) => c.id == id);
    
    // 1. التحقق من العميل
    final client = state.referenceClients.firstWhere((c) => c.id == contract.clientId);
    if (client.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكنك استعادة هذا العقد لأن العميل (${client.name}) لا يزال محذوفاً. الرجاء استعادة العميل أولاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    // 2. التحقق من الشقة (إذا كان العقد مخصصاً لشقة)
    /* 
    ملاحظة: في مستودعك حالياً، استعادة العقد تقوم آلياً بتغيير حالة الشقة إلى "مباعة".
    لذلك يجب أن نتأكد من أن الشقة غير محذوفة أصلاً!
    */
    if (contract.apartmentId != null) {
      // هل الشقة من ضمن الشقق المحذوفة؟
      final isApartmentDeleted = state.deletedApartments.any((a) => a.id == contract.apartmentId);
      if (isApartmentDeleted) {
        emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ الشقة المرتبطة بهذا العقد موجودة في سلة المحذوفات. الرجاء استعادة الشقة أولاً قبل استعادة العقد.'));
        emit(state.copyWith(status: RecycleBinStatus.success));
        return;
      }
    }

    await _erpRepository.restoreContract(id);
    await loadAllDeletedData();
  }

  Future<void> restorePayment(String id) async {
    // 🛡️ حماية: التحقق من أن العقد غير محذوف
    final payment = state.deletedPayments.firstWhere((p) => p.id == id);
    final contract = state.referenceContracts.firstWhere((c) => c.id == payment.contractId);

    if (contract.isDeleted) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: '⛔ لا يمكنك استعادة هذه الدفعة لأن العقد الخاص بها لا يزال محذوفاً. الرجاء استعادة العقد أولاً.'));
      emit(state.copyWith(status: RecycleBinStatus.success));
      return;
    }

    await _erpRepository.restoreLedgerEntry(id);
    await loadAllDeletedData();
  }

  // ==========================================
  // 💥 دوال الحذف النهائي (Hard Delete)
  // ==========================================
  // ملاحظة: الحذف النهائي تم برمجته بشكل آمن في Repository حيث يحذف الأبناء أولاً (Cascade Delete).
  
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