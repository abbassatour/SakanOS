// test/helpers/mocks.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';

// 🌟 Mock لمستودع البيانات
class MockErpRepository extends Mock implements ErpRepository {}

// 🌟 Mocks لإدارة الحالة (Cubits) لكي نخدع الواجهة بأن البيانات جاهزة
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockPaymentsCubit extends MockCubit<PaymentsState>
    implements PaymentsCubit {}
