import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/holiday.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:calendar/Calendar/editPage.dart';
import 'package:calendar/database.dart';

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
// イベントの日付リストを取得
Future<List<DateTime>> fetchEventsDates(WidgetRef ref) async {
  final database = ref.read(appDatabaseProvider);
  final events = await database.allEvents; // すべてのイベントを取得
  List<DateTime> eventDates = [];
  for (var event in events) {
    // イベントの開始日をリストに追加
    DateTime startDate = DateTime(event.startDateTime.year, event.startDateTime.month, event.startDateTime.day);
    print("イベント開始日: $startDate"); 
    eventDates.add(startDate);
  }
  return eventDates;
}

  CalendarView({Key? key ,required this.database}) : super(key: key);
  final AppDatabase database;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ページビルダーの中で、fetchEventsDatesを呼び出して、
    // 結果をCalendarPageに渡すようなロジックを追加するかもしれません。
    // 例えば、FutureBuilderを使用するなど。

    // CalendarPageのコンストラクタにイベントの日付リストを渡します。
    return FutureBuilder<List<DateTime>>(
      future: fetchEventsDates(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return PageView.builder(
            itemCount: 10000,
            controller: _pageController,
            itemBuilder: (context, index) {
              DateTime now = DateTime.now();
              DateTime firstOfMonth = DateTime(now.year, now.month + index - 5000, 1);
              // イベントの日付リストをCalendarPageに渡す
              return CalendarPage(
                key: ValueKey(firstOfMonth),
                firstDayOfMonth: firstOfMonth,
                goToToday: goToToday,
                goToSelectedMonth: goToSelectedMonth,
                eventsDates: snapshot.data!,
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CalendarPage extends ConsumerWidget {
  // CalendarPage ウィジェット内でイベントデータを取得
// 選択された日付をパラメータに追加
Future<List<Event>> _fetchEvents(WidgetRef ref, DateTime selectedDate) async {
  final database = ref.read(appDatabaseProvider); // データベースインスタンスを取得
  final events = await database.allEvents; // すべてのイベントを取得
  
  // 選択された日付に合致するイベントのみをフィルタリング
  final eventsForSelectedDay = events.where((event) {
    final startDay = DateTime(event.startDateTime.year, event.startDateTime.month, event.startDateTime.day);
    final endDay = DateTime(event.endDateTime.year, event.endDateTime.month, event.endDateTime.day);
    return selectedDate.isAtSameMomentAs(startDay) || 
           (selectedDate.isAfter(startDay) && selectedDate.isBefore(endDay)) || 
           selectedDate.isAtSameMomentAs(endDay);
  }).toList();

  return eventsForSelectedDay;
}
  final DateTime firstDayOfMonth;
   final Function goToToday;
     final Function(DateTime) goToSelectedMonth; 
      final List<DateTime> eventsDates;
  const CalendarPage({Key? key, required this.firstDayOfMonth,required this.goToToday,required this.goToSelectedMonth,this.eventsDates = const [],}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    List<String> weekDay = ["月", "火", "水", "木", "金", "土", "日"];
 
    // 月の最初の日が何曜日かを取得(1: 月曜日, 7: 日曜日)
    int lastDay = DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0).day;
    // カレンダーの日付ウィジェットを生成
    List<Widget> getDayWidgets() {
      List<Widget> dayWidgets = [];
     
    // 前月の最後の日を取得
  DateTime firstOfMonth = firstDayOfMonth;
  DateTime lastOfPrevMonth = DateTime(firstOfMonth.year, firstOfMonth.month, 0);
  int daysInPrevMonth = lastOfPrevMonth.day;

  // 前月の日付を追加
  for (int i = firstOfMonth.weekday - 1; i > 0; i--) {
    dayWidgets.add(
      Container(
        alignment: Alignment.center,
        child: Text(
          "${daysInPrevMonth - i + 1}",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
// 現在の月の日付を追加

for (int i = 1; i <= lastDay; i++) {
  DateTime date = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, i);
  Color textColor = Colors.black; // デフォルトのテキストの色
 // カレンダーの日付ウィジェットを生成する部分
  // イベントがあるかどうかを確認
bool hasEvent = eventsDates.any((eventDate) =>
  eventDate.year == date.year &&
  eventDate.month == date.month &&
  eventDate.day == date.day);
  
print("日付: $date, イベント有無: $hasEvent"); 
  // 土曜日は青色、日曜日は赤色
  if (date.weekday == DateTime.sunday) {
    textColor = Colors.red;
  } else if (date.weekday == DateTime.saturday) {
    textColor = Colors.blue;
  }
  
  // 祝日データがあれば赤色にするが祝日は黒で良いとのこと
  // if (holidayData.containsKey(dateString)) {
  //   textColor = Colors.red;
  // }
  // 土曜日、日曜日、または祝日かどうかを確認して色を色を決める
Color titleColor = Colors.black; // デフォルトの色
if (date.weekday == DateTime.sunday || holidayData.containsKey(DateFormat('yyyy-MM-dd').format(date))) {
  titleColor = Colors.red; // 日曜日または祝日の場合は赤色
} else if (date.weekday == DateTime.saturday) {
  titleColor = Colors.blue; // 土曜日の場合は青色
}
BoxDecoration? boxDecoration;
  if (DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day) {
    // 本日の日付のデザイン
    boxDecoration = BoxDecoration(
      color: Colors.blue, 
      shape: BoxShape.circle, 
      
    );
    textColor = Colors.white; // 本日のテキスト色を白に設定
  }

    // GestureDetectorを使用してタップ可能な日付ウィジェットを追加
    dayWidgets.add(
      GestureDetector(
        onTap: () {
          
        
        // タップされた日付に基づいて曜日名を取得
      String weekDayName = weekDay[date.weekday - 1];
      // タップされた日付を使用してタイトル文字列を生成
      String dateStringTitle = '${date.year}/${date.month}/${date.day}(${weekDayName})';
      // タップされた日付に対応するイベントリストを表示するダイアログを表示
        showDialog(
  context: context,
  builder: (BuildContext context) {
   
    return FutureBuilder<List<Event>>(
    future: _fetchEvents(ref,date), // データベースからイベントデータを取得
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); 
      } else if (snapshot.hasError) {
        return Text('エラーが発生しました');
      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        // データが取得でき、予定がある場合、イベントデータを表示するUIを構築
        final events = snapshot.data!;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
           RichText(
  text: TextSpan(
    style: TextStyle(fontSize: 20, color: Colors.black), // デフォルトのスタイル
    children: <TextSpan>[
      TextSpan(
        text: '${date.year}/${date.month}/${date.day}', // 日付部分
      ),
      TextSpan(
        text: '(${weekDayName})', // 曜日名部分
        style: TextStyle(
          color: date.weekday == DateTime.sunday
            ? Colors.red  // 日曜日は赤色
            : date.weekday == DateTime.saturday
              ? Colors.blue  // 土曜日は青色
              : Colors.black, // それ以外の曜日はデフォルトカラーを使用
        ),
      ),
    ],
  ),
)
,
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
  itemCount: events.length,
  itemBuilder: (context, index) {
    final event = events[index];
    return Card(
      margin: EdgeInsets.all(8), // カードの周りのマージンを設定
      child: ListTile(
        title: Row(
  crossAxisAlignment: CrossAxisAlignment.center, // 中央揃えにする
  children: <Widget>[
    event.isAllDay
        ? Text("終日", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: <Widget>[
              Text(DateFormat("HH:mm").format(event.startDateTime)),
              Text(DateFormat("HH:mm").format(event.endDateTime)),
            ],
          ),
    Container(
      height: 24, // 線の高さ
      width: 2, // 線の幅
      color: Colors.blue, // 線の色
      margin: EdgeInsets.symmetric(horizontal: 8), // 左右のマージン
    ),
    Expanded(
      child: Text(event.title, style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
    ),
  ],
),
        onTap: () { 
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
      ),
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
      }else {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          RichText(
  text: TextSpan(
    style: TextStyle(fontSize: 20, color: Colors.black), // デフォルトのスタイル
    children: <TextSpan>[
      TextSpan(
        text: '${date.year}/${date.month}/${date.day}', // 日付部分
      ),
      TextSpan(
        text: '(${weekDayName})', // 曜日名部分
        style: TextStyle(
          color: date.weekday == DateTime.sunday
            ? Colors.red  // 日曜日は赤色
            : date.weekday == DateTime.saturday
              ? Colors.blue  // 土曜日は青色
              : Colors.black, // それ以外の曜日はデフォルトカラーを使用
        ),
      ),
    ],
  ),
),
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
        child:  Center(
          child: Text('予定はありません。'),
        )
        )
        );
       }
     }
    );
  },
        );
      },
      child: Container(
  alignment: Alignment.center,
  decoration: boxDecoration,
  margin: const EdgeInsets.all(10), 
  child: Stack(
    alignment: Alignment.center,
    children: <Widget>[
      Text('$i', style: TextStyle(color: textColor, fontSize: 14)),
      if (hasEvent) 
  Positioned(
  top: 16, 
  child: Container(
    width: 4, // サイズを大きくする
    height:4, // サイズを大きくする
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black,
    ),
  ),
),


    ],
  ),
),

)
        
      );
  }


  // 翌月の日付を埋める
  int nextMonthDayIndex = 1;
  while (dayWidgets.length % 7 != 0) {
    dayWidgets.add(
      Container(
        alignment: Alignment.center,
        child: Text(
          "$nextMonthDayIndex",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
    nextMonthDayIndex++;
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
              child: Text('今日')),
               Spacer(), //余白を追加
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
),
 Spacer(),  Spacer(), //余白を追加
            ],
          ),
          
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 228, 226, 226),  // 背景色をグレーに設定
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      weekDay[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: i == 5 ? Colors.blue : i == 6 ? Colors.red : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
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