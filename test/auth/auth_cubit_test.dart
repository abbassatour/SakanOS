// test/auth/auth_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';

import '../helpers/mocks.dart';

void main() {
  group('Auth - Security & State Management', () {
    late MockErpRepository mockErpRepository;

    setUp(() {
      mockErpRepository = MockErpRepository();
    });

    // =========================================================
    // 🛡️ 1. اختبارات AuthState (Pure Logic)
    // =========================================================
    group('AuthState.hasPermission', () {
      test('returns true for any permission if user is System Admin', () {
        const state = AuthState(
          status: AuthStatus.authenticated,
          isSystemAdmin: true,
          permissions: [],
        );
        expect(state.hasPermission('any_random_permission'), isTrue);
      });

      test('returns true if non-admin user has the exact permission', () {
        const state = AuthState(
          status: AuthStatus.authenticated,
          isSystemAdmin: false,
          permissions: ['clients.view', 'payments.add'],
        );
        expect(state.hasPermission('payments.add'), isTrue);
      });

      test('returns false if non-admin user lacks the permission', () {
        const state = AuthState(
          status: AuthStatus.authenticated,
          isSystemAdmin: false,
          permissions: ['clients.view'],
        );
        expect(state.hasPermission('payments.delete'), isFalse);
      });
    });

    // =========================================================
    // 🧠 2. اختبارات AuthCubit (Initialization via Constructor)
    // =========================================================
    group('AuthCubit - checkSession (On Init)', () {
      test('emits unauthenticated immediately if no user ID', () {
        // Arrange
        when(() => mockErpRepository.currentUserId).thenReturn(null);

        // Act
        final cubit = AuthCubit(mockErpRepository);

        // Assert (يتم الفحص فوراً لأن العملية متزامنة بالكامل)
        expect(cubit.state.status, AuthStatus.unauthenticated);
      });

      test('emits error if user is inactive (isActive = false)', () async {
        // Arrange
        when(() => mockErpRepository.currentUserId).thenReturn('user_123');
        when(() => mockErpRepository.getLocalUserById('user_123')).thenAnswer(
          (_) async => LocalUser(
            id: 'user_123',
            email: 'test@erp.com',
            isActive: false, // 🔴 حساب موقوف
            extraPermissionsJson: '[]',
            revokedPermissionsJson: '[]',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
            isSynced: true,
          ),
        );

        // Act
        final cubit = AuthCubit(mockErpRepository);

        // ننتظر قليلاً للسماح لدالة checkSession (التي بداخلها await) بالانتهاء
        await Future.delayed(Duration.zero);

        // Assert
        expect(cubit.state.status, AuthStatus.error);
        expect(
          cubit.state.errorMessage,
          'هذا الحساب تم إيقافه من قبل الإدارة.',
        );
      });

      test(
        'emits authenticated with perfectly merged permissions (Role + Extra - Revoked)',
        () async {
          // Arrange
          final mockRole = AppRole(
            id: 'role_1',
            name: 'موظف مبيعات',
            permissionsJson: '["clients.view", "clients.delete"]',
            isSystemRole: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
            isSynced: true,
          );

          final mockUser = LocalUser(
            id: 'user_123',
            email: 'test@erp.com',
            fullName: 'أحمد',
            roleId: 'role_1',
            extraPermissionsJson: '["payments.add"]', // ➕
            revokedPermissionsJson: '["clients.delete"]', // ➖
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isDeleted: false,
            isSynced: true,
          );

          when(() => mockErpRepository.currentUserId).thenReturn('user_123');
          when(
            () => mockErpRepository.getLocalUserById('user_123'),
          ).thenAnswer((_) async => mockUser);
          when(
            () => mockErpRepository.getRoleById('role_1'),
          ).thenAnswer((_) async => mockRole);

          // Act
          final cubit = AuthCubit(mockErpRepository);
          await Future.delayed(Duration.zero);

          // Assert
          expect(cubit.state.status, AuthStatus.authenticated);
          expect(cubit.state.userId, 'user_123');
          expect(cubit.state.userName, 'أحمد');
          expect(cubit.state.roleName, 'موظف مبيعات');

          // 🎯 النتيجة المتوقعة: (عرض العملاء + إضافة دفعات). حذف العملاء تم سحبها!
          expect(
            cubit.state.permissions,
            containsAll(['clients.view', 'payments.add']),
          );
          expect(cubit.state.permissions.contains('clients.delete'), isFalse);
        },
      );
    });

    // =========================================================
    // 🚪 3. اختبارات AuthCubit (Logout Action)
    // =========================================================
    group('AuthCubit - Actions', () {
      blocTest<AuthCubit, AuthState>(
        'emits [loading, unauthenticated] when logout is called',
        build: () {
          when(() => mockErpRepository.currentUserId).thenReturn(null);
          when(() => mockErpRepository.signOut()).thenAnswer((_) async {});
          return AuthCubit(mockErpRepository);
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockErpRepository.signOut()).called(1);
        },
      );
    });
  });
}
