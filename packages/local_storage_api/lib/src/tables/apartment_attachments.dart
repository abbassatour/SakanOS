// packages/local_storage_api/lib/src/tables/apartment_attachments.dart
import 'package:drift/drift.dart';
import '../secure_time.dart';
import 'package:uuid/uuid.dart';
import 'apartments.dart';

@TableIndex(
  name: 'idx_apartment_attachments_sync',
  columns: {#isDeleted, #updatedAt, #apartmentId},
)
class ApartmentAttachments extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();

  TextColumn get apartmentId => text().references(Apartments, #id)();
  TextColumn get fileUrl => text()();
  TextColumn get fileName => text().nullable()();
  TextColumn get fileType => text().nullable()();
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
