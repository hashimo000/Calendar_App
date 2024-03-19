import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:flutter/cupertino.dart';
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
  late String _initialTitle;
  late String _initialComments;
  late DateTime _initialStartDateTime;
  late DateTime _initialEndDateTime;
  late bool _initialIsAllDay;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final event = ref.read(eventListProvider).where((event) => event.id == widget.eventId).first;
      _titleController.text = event.title; // 既存のイベントタイトルを設定
      _commentsController.text = event.comments; // 既存のイベントコメントを設定
       _initialTitle = event.title;
      _initialComments = event.comments;
      _initialStartDateTime = event.startDateTime;
      _initialEndDateTime = event.endDateTime;
      _initialIsAllDay = event.isAllDay;
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
            if (_isEdited()) {
              _showActionSheet();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: <Widget>[
          OutlinedButton(
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
