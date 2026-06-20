// مسار الملف: lib/clients/cubit/clients_cubit.dart
// المسؤولية: إدارة المنطق الخاص بالعملاء (جلب، إضافة، تعديل، وحذف العملاء) والاتصال مع المستودع.

import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client, ClientsCompanion;

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit({
    required ErpRepository erpRepository,
  })  : _erpRepository = erpRepository,
        super(const ClientsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء (النشطين غير المحذوفين)
  Future<void> fetchClients() async {
    if (state.status == ClientsStatus.initial) {
      emit(state.copyWith(status: ClientsStatus.loading));
    }
    try {
      final clients = await _erpRepository.getClients();

      // جلب المستخدمين وصنع قاموس للأسماء
      final allUsers = await _erpRepository.getAllUsers();
      final namesMap = <String, String>{
        for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
      };

      emit(
        state.copyWith(
          status: ClientsStatus.success,
          clients: clients,
          userNamesMap: namesMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// إضافة عميل جديد
  Future<void> addClient({
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    try {
      final newClient = ClientsCompanion.insert(
        name: name,
        phone: phone,
        nationalId: Value(nationalId),
        userId: '', // تأكد من تمرير الـ User ID الصحيح إذا لزم الأمر في المستقبل
      );

      await _erpRepository.addClient(newClient);
      await fetchClients(); // تحديث الشاشة
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: 'حدث خطأ أثناء إضافة العميل: $e',
        ),
      );
    }
  }

  /// تعديل بيانات العميل
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
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: 'حدث خطأ أثناء تعديل بيانات العميل: $e',
        ),
      );
    }
  }

  /// جلب قائمة المحذوفات
  Future<void> fetchDeletedClients() async {
    try {
      final deleted = await _erpRepository.getDeletedClients();
      emit(state.copyWith(deletedClients: deleted));
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// استعادة عميل
  Future<void> restoreClient(String clientId) async {
    try {
      await _erpRepository.restoreClient(clientId);
      await fetchDeletedClients(); // تحديث شاشة المحذوفات
      await fetchClients(); // تحديث القائمة الرئيسية
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// حذف نهائي يدوي
  Future<void> forceHardDelete(String clientId) async {
    try {
      await _erpRepository.forceHardDeleteClient(clientId);
      await fetchDeletedClients(); // تحديث شاشة المحذوفات
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// حذف العميل للـ (Soft Delete)
  Future<void> deleteClient(String clientId) async {
    try {
      // 1. جلب عقود هذا العميل للتحقق
      final clientContracts = await _erpRepository.getContractsForClient(clientId);

      // 2. الفحص الأمني قبل الحذف
      if (clientContracts.isNotEmpty) {
        emit(
          state.copyWith(
            status: ClientsStatus.failure,
            errorMessage:
                'تحذير أمني: لا يمكن حذف العميل لأن لديه عقود مسجلة. الرجاء إلغاء عقوده أولاً لكي تعود الشقق للكتالوج.',
          ),
        );
        return;
      }

      // 3. إذا لم يكن لديه عقود، قم بالحذف بأمان
      await _erpRepository.deleteClient(clientId);
      await fetchClients();
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}