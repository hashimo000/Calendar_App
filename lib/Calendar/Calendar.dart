import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/holiday.dart';
import 'package:calendar/Calendar/addPage.dart';
class CalendarView extends ConsumerWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      itemCount: 10000, // 必要に応じて適切な数値を設定
      controller: PageController(initialPage: 5000),
      itemBuilder: (context, index) {
        DateTime now = DateTime.now();
        DateTime firstOfMonth = DateTime(now.year, now.month + index - 5000, 1);
        return CalendarPage(key: ValueKey(firstOfMonth), firstDayOfMonth: firstOfMonth);
      },
    );
  }
}

class CalendarPage extends ConsumerWidget {
  final DateTime firstDayOfMonth;
  const CalendarPage({Key? key, required this.firstDayOfMonth}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    List<String> weekDay = ["月", "火", "水", "木", "金", "土", "日"];

    // 月の最初の日が何曜日かを取得(1: 月曜日, 7: 日曜日)
    int weekDayOfFirstDay = firstDayOfMonth.weekday;
    int lastDay = DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0).day;

    // カレンダーの日付ウィジェットを生成
    List<Widget> getDayWidgets() {
      List<Widget> dayWidgets = [];
      
      // 月の最初の日の曜日に応じて空のボックスを追加する。最初の日が水曜日の場合、月曜日と火曜日のボックスを追加
      for (int i = 0; i < weekDayOfFirstDay-1; i++) {
        dayWidgets.add(Container());
      }
      // 1日から月の最終日までの日付を追加
for (int i = 1; i <= lastDay; i++) {
  DateTime date = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, i);
  String dateString = DateFormat('yyyy-MM-dd').format(date);
  Color textColor = Colors.black; // デフォルトのテキスト色

  // 土曜日は青色、日曜日は赤色
  if (date.weekday == DateTime.sunday) {
    textColor = Colors.red;
  } else if (date.weekday == DateTime.saturday) {
    textColor = Colors.blue;
  }
  
  // 祝日データがあれば赤色にする
  if (holidayData.containsKey(dateString)) {
    textColor = Colors.red;
  }

 dayWidgets.add(GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                child: Row(
                  children: [
                    Text(dateString),
                    FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: 
                      (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return AddPage();
                          }),
                        );
                      }
                      )
                  ],),
              ),

              content: Container(
                width: 400,
                height: 500,
                child: Consumer(
                  builder: (context, ref, child) {
                 final title = ref.watch(eventTitleProvider);
                final dateTimeStart = ref.watch(eventDateTimeStartProvider);
                final dateTimeEnd = ref.watch(eventDateTimeEndProvider);
                //時間を無視して日付のみを取得、これで初日も反映される
                DateTime dateOnlyTimeStart = DateTime(dateTimeStart.year, dateTimeStart.month, dateTimeStart.day);
                // イベント日かどうかの判定
               bool isEventDay = ((dateTimeStart.isBefore(date) && dateTimeEnd.isAfter(date)) || date.isAtSameMomentAs(dateOnlyTimeStart));
               // 条件に応じたテキストの表示
               String displayText = isEventDay ? 'タイトル: $title\n日時: ${DateFormat('yyyy/MM/dd').format(dateTimeStart)} - ${DateFormat('yyyy/MM/dd').format(dateTimeEnd)}' : '予定がありません';

                return Text(displayText, style: TextStyle(fontSize: 20));
                 },
                )
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          '$i',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
      ),
    ));
  }
      return dayWidgets;
    }

    return Scaffold(

      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat("yyyy年MM月").format(firstDayOfMonth),
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
