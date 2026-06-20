// packages/local_storage_api/lib/src/tables/buildings.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';


@TableIndex(name: 'idx_buildings_sync', columns: {#isDeleted, #updatedAt})
class Buildings extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get name => text()(); 
  TextColumn get location => text().nullable()(); 
  TextColumn get floorCoefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get directionCoefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}