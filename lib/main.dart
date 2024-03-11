import 'package:flutter/material.dart';
import 'package:calendar/Calendar/Calendar.dart';
void main() {
  runApp((MyApp()),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  CalendarPage(),
    );
  }}