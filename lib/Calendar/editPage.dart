import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:calendar/database.dart';
// Providerの定義
final titleProvider = StateProvider<String>((ref) => '');
final commentsProvider = StateProvider<String>((ref) => '');


class EditPage extends ConsumerStatefulWidget {
  final int eventId;
  
   EditPage({Key? key, required this.eventId}) : super(key: key);
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  late String _initialTitle;
  late String _initialComments;
  late DateTime _initialStartDateTime;
  late DateTime _initialEndDateTime;
  late bool _initialIsAllDay;
   late Event? _event; // データベースから読み込んだイベントデータを保持するための変数


@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
  final database = ref.read(appDatabaseProvider);
  final Event? event = await database.getEventById(widget.eventId); // eventはnull許容型

  if (event != null) { // eventがnullでないことを確認
    _titleController.text = event.title; // null許容ではないため、nullチェック後は安全にアクセスできる
    _commentsController.text = event.comments ?? ''; // event.commentsがnullなら空文字を代入
    _initialTitle = event.title; // 同上
    _initialComments = event.comments ?? ''; // event.commentsがnullなら空文字を代入
    _initialStartDateTime = event.startDateTime; // null許容ではないため、nullチェック後は安全にアクセスできる
    _initialEndDateTime = event.endDateTime; // 同上
    _initialIsAllDay = event.isAllDay; // null許容ではないため、nullチェック後は安全にアクセスできる
    _event = event; // 読み込んだイベントデータをメンバ変数に保存
  }
});

}


  @override
  void dispose() {
    _titleController.dispose();
    _commentsController.dispose();
    super.dispose();
  }
  bool _isEdited() {
   final currentStartDateTime = ref.read(dateTimeStartProvider);
    final currentEndDateTime = ref.read(dateTimeEndProvider);
    final currentIsAllDay = ref.watch(allDayEventProvider);
    return _titleController.text != _initialTitle ||
           _commentsController.text != _initialComments ||
           currentStartDateTime != _initialStartDateTime ||
           currentEndDateTime != _initialEndDateTime ||
           currentIsAllDay != _initialIsAllDay;
  }
void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('編集を破棄'),
                  onTap: () {
                    _titleController.text = _initialTitle;
                    _commentsController.text = _initialComments;
                    ref.read(dateTimeStartProvider.notifier).state = _initialStartDateTime;
                    ref.read(dateTimeEndProvider.notifier).state = _initialEndDateTime;
                    ref.read(allDayEventProvider.notifier).state = _initialIsAllDay;

                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  }),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('キャンセル'),
                onTap: () {
                  Navigator.pop(context); 
                },
              ),
            ],
          ),
        );
      },
    );
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
              
              initialDateTime:  DateTime(now.year, now.month, now.day, ),
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                ref.read(dateTimeStartProvider.notifier).update((state) => newDate);
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
              
              initialDateTime:  DateTime(now.year, now.month, now.day, ),
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                ref.read(dateTimeEndProvider.notifier).update((state) => newDate);
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
void _deleteEvent()async{
   final database = ref.read(appDatabaseProvider);
      await database.deleteEventById(widget.eventId);

    ref.read(eventListProvider.notifier).update((state) {
      
      return state.where((event) => event.id != widget.eventId).toList();
    });
    Navigator.of(context).pop(); // ダイアログを閉じる
  }
void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('予定の削除'),
        content: Text('本当にこの日の予定を削除しますか？'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              _deleteEvent();
              Navigator.of(context).pop(); // ダイアログを閉じ、削除処理を実行
            },
            child: Text('削除'),
          ),
        ],
      );
    },
  );
}


 @override
  Widget build(BuildContext context) {
    // イベントリストからeventIdに対応するイベントを検索
    final eventId = widget.eventId;

    final isAllDay = ref.watch(allDayEventProvider);
    final dateFormat = isAllDay ? 'yyyy-MM-dd' : 'yyyy-MM-dd kk:mm';

    return Scaffold(
      appBar: AppBar(
        title: const Text('予定の編集'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.close), // ×アイコンを設定
           onPressed: () {
            if (_isEdited()) {
              _showActionSheet();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: <Widget>[
          OutlinedButton(
             onPressed: () async{
              
                        // 入力されたデータを取得
             final enteredTitle = _titleController.text;
             final enteredComments = _commentsController.text;
             final startDateTime = _initialStartDateTime; // ここは実際にはユーザーが選択する値に置き換える
             final endDateTime = _initialEndDateTime; // 同上
             final isAllDay = _initialIsAllDay; // 同上
  // データベースに保存
  final database = ref.read(appDatabaseProvider);
  await database.updateEvents(
    event: _event!,
    title: enteredTitle,
    comments: enteredComments,
    startDateTime: ref.read(dateTimeStartProvider),
    endDateTime: ref.read(dateTimeEndProvider),
    isAllDay: ref.read(allDayEventProvider),
  );
              
              ref.read(eventListProvider.notifier).update((state) {
                return state.map((event) {
                  if (event.id == eventId) {
                    return EVENTS(
                      id: event.id,
                      title: enteredTitle,
                      startDateTime: startDateTime,
                      endDateTime: endDateTime,
                      comments: enteredComments,
                      isAllDay: isAllDay,
                    );
                  }
                  return event;
                }).toList();
              });

              Navigator.pop(context);
            },
             style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      
    ),
    backgroundColor: Colors.white,
  ),
            child: const 
            Text('保存',
              style: TextStyle(
                color: Colors.black, // アプリバーの色に合わせて文字色を白に設定
              ),
            ),
          ),
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _titleController,
              onChanged: (value) {
                // テキストが変更されたらStateProviderの状態を更新
                ref.read(titleProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                labelText: ('タイトルを入力してください'),
              ),
            ),
            SwitchListTile(
              title: const Text('終日'),
              value: ref.watch(allDayEventProvider),
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
           final selectedDate = ref.watch(dateTimeStartProvider);
          return Expanded( // Expandedを使用して余白を埋める
            child: Text(
              DateFormat(dateFormat).format(selectedDate),
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
          final selectedDate = ref.watch(dateTimeEndProvider);
          return Expanded( // Expandedを使用して余白を埋める
            child: Text(
              DateFormat(dateFormat).format(selectedDate),
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
              onChanged: (value) {
                // テキストが変更されたらStateProviderの状態を更新
                ref.read(commentsProvider.notifier).state = value;
                },
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'コメントを入力してください',
                border: const OutlineInputBorder(),
              ),
            ),
            // 保存ボタンは AppBar の actions 内にあります
            TextButton(
              onPressed: _showDeleteConfirmationDialog, // 削除確認ダイアログを表示する関数を呼び出す
              child: Text('この予定を削除'),
            ),
          ],
        ),
      ),
    );
  }
}
