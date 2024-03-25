import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:calendar/database.dart';
final dateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now().add(Duration(hours: 1)));
final allDayEventProvider = StateProvider<bool>((ref) => false); 
// イベントタイトルと日時を保持するプロバイダー
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
              initialDateTime: currentStart.add(Duration(hours: 1)), 
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                // 選択された新しい終了時間を設定
                ref.read(dateTimeEndProvider.notifier).state = newDate;
              },
              minimumDate: currentStart, // 選択できる最小日時を開始時間に設定
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
        title: const Text('予定の追加'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.close), // ×アイコンを設定
          onPressed: () {
            Navigator.pop(context); // ボタンをタップした時、元の画面に戻る
          },
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: _titleController.text.isNotEmpty && _commentsController.text.isNotEmpty 
            ?  ()async {
              
              final database = ref.read(appDatabaseProvider);
             // データベースにイベントを追加
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
     Navigator.pop(context);// ポップアップを閉じる
            }
         :null ,
            
            style: ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey; // ボタン非活性時の背景色
        }
        return Colors.white; // デフォルトの背景色
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
              style: TextStyle(
                color: Colors.black,     
              ),
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
                labelText: ('タイトルを入力してください'),
              ),
            ),
            SwitchListTile(
              title: const Text('終日'),
              value: isAllDay,
              onChanged: (bool value) {
                ref.read(allDayEventProvider.notifier).state = value;
              },
            ),
            ListTile(
  title: Row(
    children: <Widget>[
      Text('開始'),
      SizedBox(width: 8.0), // この値はお好みで調整してください
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
      SizedBox(width: 8.0), // この値はお好みで調整してください
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
                labelText: 'コメントを入力してください',
                border: const OutlineInputBorder(),
              ),
            ),
            // 保存ボタンは AppBar の actions 内にあります
          ],
        ),
      ),
    );
  }
}
