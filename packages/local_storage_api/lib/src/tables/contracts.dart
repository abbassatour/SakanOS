// packages/local_storage_api/lib/src/tables/contracts.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'clients.dart';
import 'apartments.dart';

@TableIndex(
  name: 'idx_contracts_sync',
  columns: {#isDeleted, #updatedAt, #clientId},
)
class Contracts extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get apartmentId => text().nullable().references(Apartments, #id)();
  TextColumn get apartmentDetails =>
      text().withDefault(const Constant('أسهم/غير مخصص'))();
  TextColumn get contractType =>
      text().withDefault(const Constant('لاحق التخصص'))();
  RealColumn get totalArea => real()();
  RealColumn get baseMeterPriceAtSigning => real()();
  BoolColumn get isPenaltyActive =>
      boolean().withDefault(const Constant(false))();
  RealColumn get penaltyPercentage => real().withDefault(const Constant(0.0))();
  IntColumn get penaltyIntervalMonths =>
      integer().withDefault(const Constant(1))();
  RealColumn get downPayment => real().withDefault(const Constant(0.0))();
  BoolColumn get isHandedOver => boolean().withDefault(const Constant(false))();
  DateTimeColumn get agreedHandoverDate => dateTime().nullable()();
  DateTimeColumn get actualHandoverDate => dateTime().nullable()();
  IntColumn get gracePeriodMonths => integer().withDefault(const Constant(0))();
  TextColumn get handoverNotes => text().nullable()();
  IntColumn get installmentsCount =>
      integer().withDefault(const Constant(48))();
  TextColumn get coefficients => text().withDefault(const Constant('{}'))();
  TextColumn get guarantorName => text()();
  TextColumn get contractFileUrl => text().nullable()();
  RealColumn get agreedMonthlyAmount =>
      real().withDefault(const Constant(0.0))();
  TextColumn get userId => text()();
  DateTimeColumn get contractDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get lastActionDate => dateTime().nullable()();
  TextColumn get lastActionNote => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
