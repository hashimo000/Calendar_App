import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';//datetimepickerの最新バージョンインポート
import 'package:intl/intl.dart';

final dateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now());
final allDayEventProvider = StateProvider<bool>((ref) => false); 
class AddPage extends ConsumerWidget {
  const AddPage({Key? key,}) : super(key: key);
  
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
        ref.read(dateTimeStartProvider.notifier).update((state) => date);
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
        ref.read(dateTimeEndProvider.notifier).update((state) => date);
      },
      currentTime: ref.watch(dateTimeEndProvider),
      locale: LocaleType.jp,
    );
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          TextButton(
            onPressed: () {
              // 保存のロジックをここに記述
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
              decoration: InputDecoration(
                labelText: ('コメントを入力してください'),
              ),
            ),
          ],
        )
      ),
    );
  }
}
