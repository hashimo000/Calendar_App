import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/holiday.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:calendar/Calendar/editPage.dart';
class CalendarView extends ConsumerWidget {
  final PageController _pageController = PageController(initialPage: 5000);
  void goToSelectedMonth(DateTime selectedDate) {
  int monthsDifference = (selectedDate.year * 12 + selectedDate.month) - (DateTime.now().year * 12 + DateTime.now().month);
  int pageIndex = 5000 + monthsDifference;
  _pageController.jumpToPage(pageIndex);
}

void goToToday() {
  DateTime now = DateTime.now();
  DateTime firstOfCurrentMonth = DateTime(now.year, now.month, 1);
  // 現在の月との差分を正確に計算
  int monthsDifference = (now.year * 12 + now.month) - (firstOfCurrentMonth.year * 12 + firstOfCurrentMonth.month);
  int pageIndex = 5000 + monthsDifference;
  _pageController.jumpToPage(pageIndex);
}

  CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      itemCount: 10000, // 必要に応じて適切な数値を設定
      controller: _pageController,
      itemBuilder: (context, index) {
        DateTime now = DateTime.now();
        DateTime firstOfMonth = DateTime(now.year, now.month + index - 5000, 1);
        return CalendarPage(key: ValueKey(firstOfMonth),firstDayOfMonth: firstOfMonth,goToToday: goToToday,goToSelectedMonth: goToSelectedMonth, );
      },
    );
  }
}

class CalendarPage extends ConsumerWidget {
  final DateTime firstDayOfMonth;
   final Function goToToday;
     final Function(DateTime) goToSelectedMonth; // この行を追加
  const CalendarPage({Key? key, required this.firstDayOfMonth,required this.goToToday,required this.goToSelectedMonth}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime date = DateTime.now();
    List<String> weekDay = ["月", "火", "水", "木", "金", "土", "日"];
    // DateTimeから曜日のインデックスを取得（Dartでは1が月曜日なので、リストのインデックスに合わせて-1します）
    String weekDayName = weekDay[date.weekday - 1];

    // 日付と曜日を組み合わせた文字列を作成
    String dateStringTitle = '${date.year}/${date.month}/${date.day}(${weekDayName})';

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
BoxDecoration? boxDecoration;
  if (DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day) {
    // 本日の日付に対するデザイン
    boxDecoration = BoxDecoration(
      color: Colors.blue, // 背景色を青に設定
      shape: BoxShape.circle, // 丸形
      
    );
    textColor = Colors.white; // 本日のテキスト色を白に設定
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
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(dateStringTitle),
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.blue,    
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddPage()),
              );
            }
          )
        ],
      ),
      content: Container(
        width: 400,
        height: 500,
        child: ListView.builder(
          itemCount: eventsForSelectedDay.length,
          itemBuilder: (context, index) {
            final event = eventsForSelectedDay[index];
            return ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  event.isAllDay ? Text("終日", style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold)) :
                  Column(
                      children: <Widget>[
                          Text(DateFormat("HH:mm").format(event.startDateTime)), // 修正点: dateTimeStartをeventのプロパティに変更
                          Text(DateFormat("HH:mm").format(event.endDateTime)), // 修正点: dateTimeEndをeventのプロパティに変更
                      ],
                  ),
                  Expanded(
                    child: Text(event.title, style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              onTap: () { // ここでGestureDetectorをListTileのonTapに変更
              debugPrint(event.id.toString());
              debugPrint(event.title);
              debugPrint(event.startDateTime.toString());
              debugPrint(event.endDateTime.toString());
              debugPrint(event.comments);
              debugPrint(event.isAllDay.toString());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditPage(eventId: event.id),
                  ));
              },
            );
          },
        ),
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
        width: 10, // 丸の幅を設定
        height: 10, // 丸の高さを設定
        alignment: Alignment.center, // テキストを中央に配置
        decoration: boxDecoration, 
        child: Text(
          '$i',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor,fontSize: 14),
          
        ),
      ),
    ));
  }
      return dayWidgets;
    }

    return Scaffold(

      body: Column(
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: (){
                  goToToday(); 
                },
              child: Text('今日に移動')),
              GestureDetector(
  onTap: () async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDayOfMonth, // 初期値は現在表示している月
      firstDate: DateTime(2000), // 選択可能な最初の日付
      lastDate: DateTime(2101), // 選択可能な最後の日付
    );
    if (picked != null) {
      goToSelectedMonth(picked); // 選択された月に移動するメソッド
    }
  },
  child: Text(
    DateFormat("yyyy年MM月").format(firstDayOfMonth),
    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
)
            ],
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
