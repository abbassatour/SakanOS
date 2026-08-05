// packages/local_storage_api/lib/src/tables/dollar_prices_history.dart
import 'package:drift/drift.dart';
import '../secure_time.dart';
import 'package:uuid/uuid.dart';

@TableIndex(
  name: 'idx_dollar_prices_sync',
  columns: {#isDeleted, #updatedAt, #effectiveDate},
)
class DollarPricesHistory extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  DateTimeColumn get effectiveDate =>
      dateTime().clientDefault(() => SecureTime.now())();
  RealColumn get exchangeRate => real()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
