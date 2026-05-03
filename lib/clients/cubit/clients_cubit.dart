//lib\clients\cubit\clients_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ClientsCompanion;
import 'package:drift/drift.dart' show Value;

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit(this._erpRepository) : super(const ClientsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء (النشطين غير المحذوفين)
  Future<void> fetchClients() async {
    if (state.status == ClientsStatus.initial) emit(state.copyWith(status: ClientsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      
      // 🌟 السحر هنا: جلب المستخدمين وصنع قاموس للأسماء
      final allUsers = await _erpRepository.getAllUsers();
      final Map<String, String> namesMap = {
        for (var user in allUsers) user.id: user.fullName ?? 'مدير النظام'
      };

      emit(state.copyWith(
        status: ClientsStatus.success, 
        clients: clients,
        userNamesMap: namesMap, // 🌟 تمرير القاموس للواجهة
      ));
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة عميل جديد
  Future<void> addClient({required String name, required String phone, String? nationalId}) async {
    try {
      final newClient = ClientsCompanion.insert(
        name: name,
        phone: phone,
        nationalId: Value(nationalId),
        userId: '', // تأكد من تمرير הـ User ID الصحيح إذا لزم الأمر
      );
      
      await _erpRepository.addClient(newClient);
      await fetchClients(); // تحديث الشاشة
      
    } catch (e) {
      // 🌟 تم إزالة التحقق من الرقم المكرر لأنه أصبح مسموحاً
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: 'حدث خطأ أثناء إضافة العميل: $e'));
    }
  }

  /// 🌟 تعديل بيانات العميل
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
      
    } catch (e) {
      // 🌟 تم إزالة التحقق من الرقم المكرر
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: 'حدث خطأ أثناء تعديل بيانات العميل: $e'));
    }
  }

  // 🌟 جلب قائمة المحذوفات
  Future<void> fetchDeletedClients() async {
    try {
      final deleted = await _erpRepository.getDeletedClients();
      emit(state.copyWith(deletedClients: deleted));
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 استعادة عميل
  Future<void> restoreClient(String clientId) async {
    try {
      await _erpRepository.restoreClient(clientId);
      await fetchDeletedClients(); // تحديث شاشة المحذوفات
      await fetchClients(); // تحديث القائمة الرئيسية
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 حذف نهائي يدوي
  Future<void> forceHardDelete(String clientId) async {
    try {
      await _erpRepository.forceHardDeleteClient(clientId);
      await fetchDeletedClients(); // تحديث شاشة المحذوفات
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      // 1. جلب عقود هذا العميل للتحقق
      final clientContracts = await _erpRepository.getContractsForClient(clientId);
      
      // 2. الفحص الأمني قبل الحذف
      if (clientContracts.isNotEmpty) {
        emit(state.copyWith(
          status: ClientsStatus.failure, 
          errorMessage: 'تحذير أمني: لا يمكن حذف العميل لأن لديه عقود مسجلة. الرجاء إلغاء عقوده أولاً لكي تعود الشقق للكتالوج.'
        ));
        return;
      }

      // 3. إذا لم يكن لديه عقود، قم بالحذف بآمان
      await _erpRepository.deleteClient(clientId);
      await fetchClients(); 
      
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }
}