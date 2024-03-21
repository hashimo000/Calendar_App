import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

@DataClassName('Event') 
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(Constant(false))();
  TextColumn get comments => text().nullable()();
}

@DriftDatabase(tables: [Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
  Stream<List<Event>> watchEvents() {
    return (select(events)).watch();
  }
   Future<List<Event>> get allEvents => select(events).get();

  Future<int> addEvent(
      {required String title,  required DateTime startDateTime, required DateTime endDateTime, required bool isAllDay,required String comments,}) {
    return into(events).insert(
      EventsCompanion(
        title: Value(title),
        startDateTime: Value(startDateTime),
        endDateTime: Value(endDateTime),
        isAllDay: Value(false),
        comments: Value(comments),
      ),
    );
  }
  Future<int> updateEvents(
      { required Event event,required String title, required String comments,required DateTime startDateTime, required DateTime endDateTime, required bool isAllDay,}) {
    return (update(events)..where((tbl) => tbl.id.equals(event.id)))
        .write(
      EventsCompanion(
        title: Value(title),
        startDateTime: Value(startDateTime),
        endDateTime: Value(endDateTime),
        isAllDay: Value(false),
        comments: Value(comments),
      ),
    );
  }
   Future<void> deleteEvents(Event event) {
    return (delete(events)..where((tbl) => tbl.id.equals(event.id))).go();
  }
}


 
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFloder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFloder.path, 'db.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
