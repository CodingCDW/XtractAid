import 'package:drift/drift.dart';

/// Project metadata.
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get path => text()(); // Absolute path to project folder
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
