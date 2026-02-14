import 'package:drift/drift.dart';

/// Batch configurations and status.
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get name => text()();
  TextColumn get configJson => text()(); // Full BatchConfig as JSON
  TextColumn get status => text().withDefault(const Constant('created'))();
  // Status: created | running | paused | completed | failed | cancelled
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
