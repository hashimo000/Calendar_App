import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:calendar/database.dart';
final dateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now().add(Duration(hours: 1)));
final allDayEventProvider = StateProvider<bool>((ref) => false); 
final eventTitleProvider = StateProvider<String>((ref) => '');
final eventDateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final eventDateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now());
final eventCommentsProvider = StateProvider<String>((ref) => '');
final TextEditingController _titleController = TextEditingController();
final TextEditingController _commentsController = TextEditingController();
final eventListProvider = StateProvider<List<EVENTS>>((ref) => []);
final now = DateTime.now();
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(openConnection());
  return database;
});
class EVENTS {
  final int id;
  String title;
  DateTime startDateTime;
  DateTime endDateTime;
  String comments;
  bool isAllDay;

  EVENTS({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    this.comments = '',
    this.isAllDay = false,
  });
}

class AddPage extends ConsumerStatefulWidget {
  const AddPage({Key? key,}) : super(key: key);
   @override
  _AddPageState createState() => _AddPageState();
}
class _AddPageState extends ConsumerState<AddPage> {
  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
  _commentsController.addListener(_updateButtonState);
    WidgetsBinding.instance.addPostFrameCallback((_) => resetFormState());
  }
 @override
  void dispose() {
    // ウィジェットが破棄される前にリスナーを削除
    _titleController.removeListener(_updateButtonState);
    _commentsController.removeListener(_updateButtonState);

    // 破棄プロセスを完了するために、スーパーメソッドを呼び出すことを忘れないでください
    super.dispose();
  }

  void _updateButtonState() {
    // setStateを呼び出す前に、ウィジェットがまだマウントされているかどうかをチェック
    if (mounted) {
      setState(() {}); // ウィジェットがまだツリーに存在する場合のみ、状態を更新
    }
  }



  void resetFormState() {
    // テキストフィールドをクリア
    _titleController.clear();
    _commentsController.clear();

    // 状態プロバイダーをリセット
    ref.read(allDayEventProvider.notifier).state = false;
    ref.read(dateTimeStartProvider.notifier).state = DateTime.now();
    ref.read(dateTimeEndProvider.notifier).state = DateTime.now().add(Duration(hours: 1));
  }


void _showDateTimePickerStart(BuildContext context, WidgetRef ref) {
  final isAllDay = ref.watch(allDayEventProvider);
  showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
            child: CupertinoDatePicker(
              initialDateTime: DateTime(now.year, now.month, now.day),
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                // 選択された新しい開始時間を現在の終了時間と比較
                final currentEnd = ref.read(dateTimeEndProvider);
                if (newDate.isAfter(currentEnd)) {
                  // 開始時間が終了時間よりも後の場合は、終了時間を開始時間+1時間に設定
                  final newEnd = newDate.add(Duration(hours: 1));
                  ref.read(dateTimeEndProvider.notifier).state = newEnd;
                }
                ref.read(dateTimeStartProvider.notifier).state = newDate;
              },
              minimumDate: DateTime(2022, 5, 5),
              maximumDate: DateTime(2030, 6, 7),
              minuteInterval: 15,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDateTimePickerEnd(BuildContext context, WidgetRef ref) {
  final isAllDay = ref.watch(allDayEventProvider);
  final currentStart = ref.read(dateTimeStartProvider);

  // 現在の開始時刻から1時間後の時刻を計算
  final oneHourLater = currentStart.add(Duration(hours: 1));

  // 分を15で割り、結果を切り上げてから15を掛けて、15分単位に丸める
  final roundedMinutes = (oneHourLater.minute / 15).ceil() * 15;
  DateTime roundedOneHourLater;

  // 分が60以上の場合は、時間を1つ進めて分を0にする
  if (roundedMinutes >= 60) {
    roundedOneHourLater = DateTime(oneHourLater.year, oneHourLater.month, oneHourLater.day, oneHourLater.hour + 1, 0);
  } else {
    roundedOneHourLater = DateTime(oneHourLater.year, oneHourLater.month, oneHourLater.day, oneHourLater.hour, roundedMinutes);
  }

  // 開始時間より後の時刻かどうかを判定し、条件に応じて初期値と最小日時を設定
  final initialAndMinimumDateTime = roundedOneHourLater.isAfter(currentStart) ? roundedOneHourLater : currentStart.add(Duration(hours: 1));

  showCupertinoModalPopup(
    context: context,
    builder: (_) => Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 200,
            child: CupertinoDatePicker(
              initialDateTime: initialAndMinimumDateTime,
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                ref.read(dateTimeEndProvider.notifier).state = newDate;
              },
              minimumDate: initialAndMinimumDateTime,
              maximumDate: DateTime(2030, 6, 7),
              minuteInterval: 15,
            ),
          ),
        ],
      ),
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final isAllDay = ref.watch(allDayEventProvider);
    final dateFormat = isAllDay ? 'yyyy-MM-dd' : 'yyyy-MM-dd kk:mm';

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:Text('予定の追加', style: TextStyle(color: Colors.white))
          ) ,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.close,color: Colors.white), 
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: _titleController.text.isNotEmpty && _commentsController.text.isNotEmpty 
            ?  ()async {
              
              final database = ref.read(appDatabaseProvider);
             // データベースにイベントを追加
             print("データベースに保存する前の終日フラグ: ${ref.read(allDayEventProvider)}");
              await database.addEvent(
              title: _titleController.text,
              startDateTime: ref.read(dateTimeStartProvider),
              endDateTime: ref.read(dateTimeEndProvider),
              isAllDay: ref.read(allDayEventProvider),
              comments: _commentsController.text,
              );

             // 新しいイベントを作成
              final currentList = ref.read(eventListProvider);
              final newId = currentList.isNotEmpty ? currentList.last.id + 1 : 1; // 新しいIDを生成
              final newEvent = EVENTS(
                   id: newId, // 新しいIDをイベントに割り当て
                   title: _titleController.text, // タイトル
                   startDateTime: ref.read(dateTimeStartProvider), // 開始時間
                   endDateTime: ref.read(dateTimeEndProvider), // 終了時間
                   comments: _commentsController.text, // コメント
                   isAllDay: ref.read(allDayEventProvider), // 終日フラグ
                );
                // 現在のイベントリストに新しいイベントを追加して更新
            ref.read(eventListProvider.notifier).update((state) => [...state, newEvent]);

            // 入力フィールドをクリア
            _titleController.clear();
            _commentsController.clear();
              String enteredTitle = _titleController.text;
              String enteredComments = _commentsController.text; 
               DateTime startDateTime = ref.read(dateTimeStartProvider);
               DateTime endDateTime = ref.read(dateTimeEndProvider);
              // ここに保存のロジックを記述
    ref.read(eventTitleProvider.notifier).state = enteredTitle;// TextFieldから入力されたタイトル;
    ref.read(eventCommentsProvider.notifier).state = enteredComments; // TextFieldから入力されたコメント;
    ref.read(eventDateTimeStartProvider.notifier).state = startDateTime; // DateTimePickerから選択された日時;
    ref.read(eventDateTimeEndProvider.notifier).state = endDateTime;
    
    Navigator.pop(context); 
     Navigator.pop(context);
            }
         :null ,
            
            style: ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Color.fromARGB(255, 216, 216, 216); // ボタン非活性時の背景色
        }
        return Colors.white; // デフォルトの背景色
      },
    ),
    foregroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Color.fromARGB(255, 155, 155, 155); // 無効時のテキストカラー
        }
        return Colors.black; // デフォルトのテキストカラー
      },
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
            child: const 
            Text('保存',
             
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText:  'タイトルを入力してください',
                border: const OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: const Text('終日'),
              value: isAllDay,
              onChanged: (bool value) {
                ref.read(allDayEventProvider.notifier).state = value;
                print("終日スイッチが ${value ? 'ON' : 'OFF'} に変更されました。");  // ログ出力
              },
                 activeColor: Color.fromRGBO(50, 124, 215, 1), // オンの状態の色
                 inactiveTrackColor: Colors.grey, // オフの状態のトラック色
                 activeTrackColor: Color.fromARGB(255, 106, 187, 245), // オンの状態のトラック色
                 inactiveThumbColor: Colors.white, // オフの状態のサム色
            ),
            ListTile(
  title: Row(
    children: <Widget>[
      Text('開始'),
      SizedBox(width: 8.0),
      // Consumerを使用して選択された開始時間を表示
      Consumer(
        builder: (context, ref, child) {
          final selectedStart = ref.watch(dateTimeStartProvider);
          return Expanded( // Expandedを使用して余白を埋める
            child: Text(
              DateFormat(dateFormat).format(selectedStart),
              textAlign: TextAlign.end, // テキストを右寄せにする
            ),
          );
        },
      ),
    ],
  ),
  onTap: () => _showDateTimePickerStart(context, ref),
),

          ListTile(
  title: Row(
    children: <Widget>[
      Text('終了'),
      SizedBox(width: 8.0), 
      // Consumerを使用して選択された開始時間を表示
      Consumer(
        builder: (context, ref, child) {
          final selectedEnd = ref.watch(dateTimeEndProvider);
          return Expanded( // Expandedを使用して余白を埋める
            child: Text(
              DateFormat(dateFormat).format(selectedEnd),
              textAlign: TextAlign.end, // テキストを右寄せにする
            ),
          );
        },
      ),
    ],
  ),
  onTap: () => _showDateTimePickerEnd(context, ref),
),

            TextField(
              controller: _commentsController,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'コメントを入力してください',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
