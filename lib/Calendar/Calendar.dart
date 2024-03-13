import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/holiday.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:calendar/Calendar/editPage.dart';
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
            // 保存されたイベントリストを取得
    final eventList = ref.watch(eventListProvider);
    // 選択された日付に対応するイベントだけをフィルタリング
    final eventsForSelectedDay = eventList.where((event) {
      final startDay = DateTime(event.startDateTime.year, event.startDateTime.month, event.startDateTime.day);
      final endDay = DateTime(event.endDateTime.year, event.endDateTime.month, event.endDateTime.day);
      return date.isAtSameMomentAs(startDay) || (date.isAfter(startDay) && date.isBefore(endDay)) || date.isAtSameMomentAs(endDay);
    }).toList();

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
                
                final dateTimeStart = ref.watch(eventDateTimeStartProvider);
                final dateTimeEnd = ref.watch(eventDateTimeEndProvider);
            return GestureDetector(
                onTap: () {
                   Navigator.of(context).push(
                   MaterialPageRoute(builder: (context) => EditPage()),
                    );
                   },
                 child:ListView.builder(itemCount: eventsForSelectedDay.length,
          itemBuilder: (context, index) {
            
            final event = eventsForSelectedDay[index];
            return ListTile(
            
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:<Widget> [
          event.isAllDay? Text("終日",style: TextStyle(fontSize: 20, color: textColor,fontWeight: FontWeight.bold),)
          : Column(
        children: <Widget>[
          Text(DateFormat("HH:mm").format(dateTimeStart)),
          Text(DateFormat("HH:mm").format(dateTimeEnd)),
        ],
      ),
      Text(event.title,style: TextStyle(fontSize: 20, color: textColor,fontWeight: FontWeight.bold),),
            ],
            ),
            );
          },) 
                  );
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
