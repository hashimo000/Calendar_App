import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:calendar/Calendar/addPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:calendar/database.dart';
final titleProvider = StateProvider<String>((ref) => '');
final commentsProvider = StateProvider<String>((ref) => '');


class EditPage extends ConsumerStatefulWidget {
  final int eventId;
  
   EditPage({Key? key, required this.eventId}) : super(key: key);
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
   // 初期化が完了したかどうかを追跡するためのブールフラグを追加
  bool _isInitialized = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
   final FocusNode _titleFocusNode = FocusNode(); // FocusNodeを追加
  late String _initialTitle;
  late String _initialComments;
  late DateTime _initialStartDateTime;
  late DateTime _initialEndDateTime;
  late bool _initialIsAllDay;
   late Event? _event; // データベースから読み込んだイベントデータを保持するための変数


@override

 void initState() {
  super.initState();
  _titleController.addListener(_onTextChanged);
  _commentsController.addListener(_onTextChanged);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final database = ref.read(appDatabaseProvider);
    final Event? event = await database.getEventById(widget.eventId);

    if (event != null) {
      setState(() {
        // イベントデータでUIを初期化
        _titleController.text = event.title;
        _commentsController.text = event.comments ?? '';
        _initialTitle = event.title;
        _initialComments = event.comments ?? '';
        _initialStartDateTime = event.startDateTime;
        _initialEndDateTime = event.endDateTime;
        _initialIsAllDay = event.isAllDay;
        _event = event;
        _isInitialized = true;
      });
      // 初期化が完了した後にフォーカスを設定
        _titleFocusNode.requestFocus();
      // 初期データでプロバイダーも更新
      ref.read(dateTimeStartProvider.notifier).state = _initialStartDateTime;
      ref.read(dateTimeEndProvider.notifier).state = _initialEndDateTime;
      ref.read(allDayEventProvider.notifier).state = _initialIsAllDay;
    }
  });
}
void _onTextChanged() {
  // 状態の更新が必要な場合にはここで行う
  setState(() {});
}

  @override
void dispose() {
  _titleController.removeListener(_onTextChanged);
  _commentsController.removeListener(_onTextChanged);
  _titleController.dispose();
  _commentsController.dispose();
  _titleFocusNode.dispose(); // FocusNodeを破棄
  super.dispose();
}
bool _isEdited(WidgetRef ref) {
  final currentTitle = _titleController.text;
  final currentComments = _commentsController.text;
  final currentStartDateTime = ref.read(dateTimeStartProvider);
  final currentEndDateTime = ref.read(dateTimeEndProvider);
  final currentIsAllDay = ref.read(allDayEventProvider);

  return currentTitle != _initialTitle ||
         currentComments != _initialComments ||
         currentStartDateTime != _initialStartDateTime ||
         currentEndDateTime != _initialEndDateTime ||
         currentIsAllDay != _initialIsAllDay;
}
void _showActionSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,  // 背景を透明に設定
    builder: (BuildContext context) {
      return Container(
        margin: EdgeInsets.all(20),  // 余白を設定
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),  // 角の丸みを設定
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
              _buildActionItem('編集を破棄', onTap: () {
                _titleController.text = _initialTitle;
                _commentsController.text = _initialComments;
                ref.read(dateTimeStartProvider.notifier).state = _initialStartDateTime;
                ref.read(dateTimeEndProvider.notifier).state = _initialEndDateTime;
                ref.read(allDayEventProvider.notifier).state = _initialIsAllDay;

                Navigator.pop(context);
                Navigator.pop(context);
              }),
              SizedBox(height: 20),  // 項目間のスペース
              _buildActionItem('キャンセル', onTap: () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildActionItem(String text, {required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.blueAccent),
      ),
    ),
  );
}

void _showDateTimePickerStart(BuildContext context, WidgetRef ref) {
  final isAllDay = ref.watch(allDayEventProvider);
  DateTime initialDateTime = ref.read(dateTimeStartProvider);

  int adjustment = (15 - initialDateTime.minute % 15) % 15;
  DateTime adjustedInitialDateTime = initialDateTime.add(Duration(minutes: adjustment));
  DateTime tempNewDate = initialDateTime;  // 一時的な日時を保持する変数

  showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // キャンセル時は何もしない
                  Navigator.pop(context);
                },
              ),
              CupertinoButton(
                child: Text('完了', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // 完了時に一時的な変数から実際のプロバイダーを更新
                  ref.read(dateTimeStartProvider.notifier).state = tempNewDate;
                  // 終了時間が必要な場合も更新
                  DateTime currentEndDateTime = ref.read(dateTimeEndProvider);
                  if (currentEndDateTime.isBefore(tempNewDate.add(Duration(hours: 1)))) {
                    ref.read(dateTimeEndProvider.notifier).state = tempNewDate.add(Duration(hours: 1));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              initialDateTime: adjustedInitialDateTime,
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                // DatePickerからの新しい日時を一時的な変数に保存
                tempNewDate = newDate;
              },
              minimumDate: null,
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
  final currentEndDateTime = ref.read(dateTimeEndProvider);  // 現在の終了時間を取得
  DateTime initialDateTime = currentEndDateTime;

  int minutes = initialDateTime.minute;
  int adjustment = (15 - minutes % 15) % 15;
  DateTime adjustedDateTime = initialDateTime.add(Duration(minutes: adjustment));  // 初期値を15分単位に調整

  DateTime tempNewDate = adjustedDateTime;  // 一時的な新しい終了日時を保持する変数

  showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // キャンセル時は何もしない
                  Navigator.pop(context);
                },
              ),
              CupertinoButton(
                child: Text('完了', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // 完了時に一時的な変数から実際のプロバイダーを更新
                  ref.read(dateTimeEndProvider.notifier).state = tempNewDate;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              initialDateTime: adjustedDateTime,  // 調整済みの初期値を使用
              mode: isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDate) {
                // DatePickerからの新しい日時を一時的な変数に保存
                tempNewDate = newDate;
              },
              minimumDate: ref.read(dateTimeStartProvider).add(Duration(hours: 1)),  // 終了時間の最小値を開始時間の1時間後に設定
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
    Navigator.of(context).pop(); 
  }
void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '予定の削除', 
          textAlign: TextAlign.center, 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        content: Text('本当にこの日の予定を削除しますか？', style: TextStyle(fontSize: 16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,  // アクションボタンを均等に配置
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // ダイアログを閉じる
            },
            style: TextButton.styleFrom(

              textStyle: TextStyle(fontSize: 16),
            ),
            child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _deleteEvent();  // イベント削除の処理
              Navigator.of(context).pop();  // ダイアログを閉じる
              Navigator.of(context).pop();  // 前の画面に戻る
            },
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16),
            ),
            child: Text('削除', style: TextStyle(color: Colors.blue)),
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
       if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return  GestureDetector(
    onTap: () {
      // 画面のどこかをタップしたときにキーボードを非表示にする
      FocusScope.of(context).unfocus();
    },
     child: Scaffold(
      appBar: AppBar(
        title:Center(child:const Text('予定の編集' ,style: TextStyle(color: Colors.white), )), 
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.close,color: Colors.white), 
           onPressed: () {
            if (_isEdited(ref)) {
              _showActionSheet();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: <Widget>[
          OutlinedButton(
             onPressed: _isEdited(ref) ? () async{
              
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
               Navigator.pop(context);
            }: null, // isEditedがfalseの場合、ボタンは非活性化される。
            style:  ButtonStyle(
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
     padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0)), 
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
                focusNode: _titleFocusNode, // FocusNodeをTextFieldに適用
              decoration: InputDecoration(
                hintText: ('タイトルを入力してください'),
                border: const OutlineInputBorder(),
                
              ),
            ),
            SwitchListTile(
              title: const Text('終日'),
              value: ref.watch(allDayEventProvider),
              onChanged: (bool value) {
                ref.read(allDayEventProvider.notifier).state = value;
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
      SizedBox(width: 8.0), 
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
                hintText:  'コメントを入力してください',
                border: const OutlineInputBorder(),
              ),
            ),
            TextButton(
              onPressed: _showDeleteConfirmationDialog, 
              child: Text('この予定を削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    )
    );
  }
}
