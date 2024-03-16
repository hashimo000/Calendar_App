import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';//datetimepickerの最新バージョンインポート
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/addPage.dart';

final TextEditingController _titleController = TextEditingController();
final TextEditingController _commentsController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final event = ref.read(eventListProvider).where((event) => event.id == widget.eventId).first;
      _titleController.text = event.title; // 既存のイベントタイトルを設定
      _commentsController.text = event.comments; // 既存のイベントコメントを設定
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

void _showDateTimePickerStart(BuildContext context, WidgetRef ref) {
  final isAllDay = ref.watch(allDayEventProvider);
  if (isAllDay) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2022, 5, 5),
      maxTime: DateTime(2030, 6, 7),
      onConfirm: (date) {
        // 日付のみを設定
        ref.read(dateTimeStartProvider.notifier).update((state) => DateTime(date.year, date.month, date.day));
      },
      currentTime: ref.watch(dateTimeStartProvider),
      locale: LocaleType.jp,
    );
  } else {
    // ここでDateTimePickerを表示
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2022, 5, 5, 0, 00),
      maxTime: DateTime(2030, 6, 7, 23, 59),
      onConfirm: (date) {
         ref.read(dateTimeStartProvider.notifier).state = date;
      },
      currentTime: ref.watch(dateTimeStartProvider),
      locale: LocaleType.jp,
    );
  }
}

void _showDateTimePickerEnd(BuildContext context, WidgetRef ref) {
  final isAllDay = ref.watch(allDayEventProvider);
  if (isAllDay) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2022, 5, 5),
      maxTime: DateTime(2030, 6, 7),
      onConfirm: (date) {
        // 日付のみを設定
        ref.read(dateTimeEndProvider.notifier).update((state) => DateTime(date.year, date.month, date.day));
      },
      currentTime: ref.watch(dateTimeEndProvider),
      locale: LocaleType.jp,
    );
  } else {
    // ここでDateTimePickerを表示
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2022, 5, 5, 0, 00),
      maxTime: DateTime(2030, 6, 7, 23, 59),
      onConfirm: (date) {
        ref.read(dateTimeEndProvider.notifier).state = date;
      },
      currentTime: ref.watch(dateTimeEndProvider),
      locale: LocaleType.jp,
    );
  }
}
void _deleteEvent() {
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
            Navigator.pop(context); // ボタンをタップした時、元の画面に戻る
          },
        ),
        actions: <Widget>[
          TextButton(
                      onPressed: () {
               final enteredTitle = ref.read(titleProvider);
              final enteredComments = ref.read(commentsProvider);
              final startDateTime = ref.read(dateTimeStartProvider);
              final endDateTime = ref.read(dateTimeEndProvider);
              final isAllDay = ref.read(allDayEventProvider);

              ref.read(eventListProvider.notifier).update((state) {
                return state.map((event) {
                  if (event.id == eventId) {
                    return Event(
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

            child: const 
            Text('保存',
              style: TextStyle(
                color: Colors.white, // アプリバーの色に合わせて文字色を白に設定
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children:  <Widget>[
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
                title: Text('終日'),
                value: ref.watch(allDayEventProvider),
               onChanged: (bool value) {
               ref.read(allDayEventProvider.notifier).state = value; 
               },
               
               ),

            
            GestureDetector(
                  onTap: () => _showDateTimePickerStart(context, ref),
                  child: Consumer(
                  builder: (context, ref, child) {
                  final selectedDate = ref.watch(dateTimeStartProvider);
                 return Container(
                  child:Text("開始: ${DateFormat(dateFormat).format(selectedDate)}"),
                 );
                },
               ),
              ),
            GestureDetector(
                  onTap: () => _showDateTimePickerEnd(context, ref),
                  child: Consumer(
                  builder: (context, ref, child) {
                  final selectedDate = ref.watch(dateTimeEndProvider);
                 
                 return Text("終了: ${DateFormat(dateFormat).format(selectedDate)}");
                },
               ),
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
              border: OutlineInputBorder(), // 枠線を追加して入力フィールドをはっきりさせる
             ),
            ),
             TextButton(
              onPressed: _showDeleteConfirmationDialog, // 削除確認ダイアログを表示する関数を呼び出す
              child: Text('この予定を削除'),
            ),
          ],
        )
      ),
    );
  }
}
