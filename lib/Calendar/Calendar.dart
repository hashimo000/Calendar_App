import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
class CalendarPage extends ConsumerWidget {
  const CalendarPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在の日付を取得
    DateTime now = DateTime.now();
    // 月の最初の日を取得,当然１だけど
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    // その月の最終日の数を取得
    int lastDay = DateTime(now.year, now.month + 1, 1).add(Duration(days: -1)).day;
    debugPrint((lastDay).toString());
   
    // 月の最終日を取得
    DateTime lastDayOfMonth = DateTime(now.year, now.month, lastDay);
    List<String> weekDay = ["月", "火", "水", "木", "金", "土", "日"];

    // 月の最初の日が何曜日かを取得します (1: 月曜日, 7: 日曜日)
    int weekDayOfFirstDay = firstDayOfMonth.weekday;
   
    // カレンダーの日付ウィジェットを生成
    List<Widget> getDayWidgets() {
      List<Widget> dayWidgets = [];
      
      // 月の最初の日の曜日に応じて空のボックスを追加する。最初の日が水曜日の場合、月曜日と火曜日のボックスを追加
      for (int i = 0; i < weekDayOfFirstDay-1; i++) {
        dayWidgets.add(Container());
      }
      // 1日から月の最終日までの日付を追加
for (int i = 1; i <= lastDay; i++) {
  DateTime date = DateTime(now.year, now.month, i);
  String dateString = DateFormat('yyyy-MM-dd').format(date);
  Color textColor = Colors.black; // デフォルトのテキスト色

  // 土曜日は青色、日曜日は赤色
  if (date.weekday == DateTime.sunday) {
    textColor = Colors.red;
  } else if (date.weekday == DateTime.saturday) {
    textColor = Colors.blue;
  }


  dayWidgets.add(Container(
    padding: const EdgeInsets.all(4.0),
    child: Text(
      '$i',
      textAlign: TextAlign.center,
      style: TextStyle(color: textColor),
    ),
  ));
}

     

      return dayWidgets;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('カレンダー'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat("yyyy年MM月").format(now),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      weekDay[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              children: getDayWidgets(),
            ),
          ),
        ],
      ),
    );
  }
}
