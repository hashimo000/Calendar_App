import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

final dateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now());
final allDayEventProvider = StateProvider<bool>((ref) => false); 
// イベントタイトルと日時を保持するプロバイダー
final eventTitleProvider = StateProvider<String>((ref) => '');
final eventDateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final eventDateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now());
final eventCommentsProvider = StateProvider<String>((ref) => '');
final TextEditingController _titleController = TextEditingController();
final TextEditingController _commentsController = TextEditingController();
final eventListProvider = StateProvider<List<Event>>((ref) => []);
final now = DateTime.now();
class Event {
  final int id;
  String title;
  DateTime startDateTime;
  DateTime endDateTime;
  String comments;
  bool isAllDay;

  Event({
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
    WidgetsBinding.instance.addPostFrameCallback((_) => resetFormState());
  }

  void resetFormState() {
    // テキストフィールドをクリア
    _titleController.clear();
    _commentsController.clear();

    // 状態プロバイダーをリセット
    ref.read(allDayEventProvider.notifier).state = false;
    ref.read(dateTimeStartProvider.notifier).state = DateTime.now();
    ref.read(dateTimeEndProvider.notifier).state = DateTime.now();
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
            ?  () {
             // 新しいイベントを作成
              final currentList = ref.read(eventListProvider);
              final newId = currentList.isNotEmpty ? currentList.last.id + 1 : 1; // 新しいIDを生成
              final newEvent = Event(
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
    Navigator.pop(context); // ポップアップを閉じる
            }
         :null ,
            
            style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      
    ),
    backgroundColor: Colors.white,
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
      body: Center(
        child: Column(
          children:  <Widget>[
            TextField(
               controller: _titleController,
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
                  child:Text("開始"+DateFormat(dateFormat).format(selectedDate))
                 );
                },
               ),
              ),
            GestureDetector(
                  onTap: () => _showDateTimePickerEnd(context, ref),
                  child: Consumer(
                  builder: (context, ref, child) {
                  final selectedDate = ref.watch(dateTimeEndProvider);
                 
                 return Text("終了"+DateFormat(dateFormat).format(selectedDate));
                },
               ),
              ),

           TextField(
             controller: _commentsController, 
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              decoration: InputDecoration(
              labelText: 'コメントを入力してください',
              border: OutlineInputBorder(), // 枠線を追加して入力フィールドをはっきりさせる
             ),
            ),
          ],
        )
      ),
    );
  }
}
