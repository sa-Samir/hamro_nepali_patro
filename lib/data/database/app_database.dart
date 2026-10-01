import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get bsYear => integer()();
  IntColumn get bsMonth => integer()();
  IntColumn get bsDay => integer()();

  /// Name of a `RepeatRule` value.
  TextColumn get repeat => text().withDefault(const Constant('none'))();
  BoolColumn get remind => boolean().withDefault(const Constant(true))();

  /// Comma separated days-before list, e.g. "0,1".
  TextColumn get reminderOffsets => text().withDefault(const Constant('0'))();
  IntColumn get reminderMinutes => integer().withDefault(const Constant(480))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'patro'));

  @override
  int get schemaVersion => 1;
}
