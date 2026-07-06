// packages/local_storage_api/lib/src/tables/apartments.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'buildings.dart';

@TableIndex(
  name: 'idx_apartments_sync',
  columns: {#isDeleted, #updatedAt, #buildingId},
)
class Apartments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get buildingId => text().references(Buildings, #id)();
  TextColumn get unitType => text().withDefault(const Constant('apartment'))();
  TextColumn get apartmentNumber => text()();
  RealColumn get area => real()();
  TextColumn get floorName => text()();
  TextColumn get directionName => text()();
  TextColumn get customCoefficients =>
      text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('available'))();
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
