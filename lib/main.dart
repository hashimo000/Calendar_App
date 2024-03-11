import 'package:flutter/material.dart';
import 'package:calendar/Calendar/calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(const ProviderScope(child: MyApp()),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('カレンダービュー'),
        backgroundColor: Colors.blueAccent,
      ),
      body: CalendarView(),
    ),
  );
}}