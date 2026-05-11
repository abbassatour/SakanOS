// lib/legal/cubit/legal_affairs_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract, Client, Apartment, Building;

part 'legal_affairs_state.dart';

class LegalAffairsCubit extends Cubit<LegalAffairsState> {
  LegalAffairsCubit(this._erpRepository) : super(const LegalAffairsState());

  final ErpRepository _erpRepository;

  Future<void> fetchData() async {
    emit(state.copyWith(status: LegalAffairsStatus.loading));
    try {
      final allContracts = await _erpRepository.getAllContracts();
      final clients = await _erpRepository.getClients();
      final apartments = await _erpRepository.getAllApartments();
      final buildings = await _erpRepository.getBuildings();

      final List<Contract> pendingLegal =[];
      final List<Contract> financialOnly = [];
      final List<Contract> ultimate =[];

      for (var c in allContracts) {
        if (c.isDeleted) continue; // تجاهل المحذوف

        // 🏆 1. الإغلاق التام: مغلق مالياً + تم الفراغ
        if (c.isCompleted && c.isTitleDeedTransferred) {
          ultimate.add(c);
        } 
        // ⚖️ 2. قيد المتابعة القانونية: مُسلّمة للمشتري + لم يتم الفراغ (حتى لو كانت مغلقة مالياً، المحامي يجب أن يراها)
        else if (c.isHandedOver && !c.isTitleDeedTransferred) {
          pendingLegal.add(c);
        } 
        // 💰 3. أرشيف مالي مبكر: دفع كامل المبلغ وأغلق العقد، لكن الشقة قيد الإنشاء ولم تُسلم بعد
        else if (c.isCompleted && !c.isTitleDeedTransferred && !c.isHandedOver) {
          financialOnly.add(c);
        }
      }

      // ترتيب زمني من الأحدث للأقدم
      pendingLegal.sort((a, b) => b.contractDate.compareTo(a.contractDate));
      financialOnly.sort((a, b) => b.contractDate.compareTo(a.contractDate));
      ultimate.sort((a, b) => b.contractDate.compareTo(a.contractDate));

      emit(state.copyWith(
        status: LegalAffairsStatus.success,
        pendingLegalTransfer: pendingLegal,
        financialArchive: financialOnly,
        ultimateArchive: ultimate,
        clients: clients,
        apartments: apartments,
        buildings: buildings,
      ));
    } catch (e) {
      emit(state.copyWith(status: LegalAffairsStatus.failure, errorMessage: 'فشل تحميل البيانات: $e'));
    }
  }
}