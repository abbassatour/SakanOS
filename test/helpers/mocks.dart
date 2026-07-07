// test/helpers/mocks.dart
import 'package:mocktail/mocktail.dart';
import 'package:erp_repository/erp_repository.dart';

// 🌟 Mock مركزي لمستودع البيانات للتحكم بردوده أثناء الاختبارات
class MockErpRepository extends Mock implements ErpRepository {}
