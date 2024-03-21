import 'package:drift/drift.dart';

part 'database.g.dart';

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(Constant(false))();
  TextColumn get comments => text().nullable()();
}
