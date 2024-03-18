import 'package:flutter/material.dart';
import 'package:calendar/Calendar/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() {
  runApp(const ProviderScope(child: MyApp()),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
Widget build(BuildContext context) {
  return MaterialApp(
    localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate, // Ensure this is spelled correctly
    GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja'),
      ],
    home: Scaffold(
      appBar: AppBar(
        title: Text('カレンダービュー'),
        backgroundColor: Colors.blueAccent,
      ),
      body: CalendarView(),
    ),
  );
}}