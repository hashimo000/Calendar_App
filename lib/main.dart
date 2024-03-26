import 'package:flutter/material.dart';
import 'package:calendar/Calendar/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:calendar/database.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(openConnection());
  runApp(ProviderScope(child: MyApp(database: database)));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja'),
      ],
      locale: Locale('ja'),
      home: Scaffold(
        appBar: AppBar(
          title: Text('カレンダービュー'),
          backgroundColor: Colors.blueAccent,
        ),
        body: CalendarView(database: database),
      ),
    );
  }
}
