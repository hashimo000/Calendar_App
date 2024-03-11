import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';//datetimepickerの最新バージョンインポート
import 'package:intl/intl.dart';

final dateTimeStartProvider = StateProvider<DateTime>((ref) => DateTime.now());
final dateTimeEndProvider = StateProvider<DateTime>((ref) => DateTime.now());

class AddPage extends ConsumerWidget {
  const AddPage({Key? key}) : super(key: key);
void _showDateTimePickerStart(BuildContext context, WidgetRef ref) {
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
void _showDateTimePickerEnd(BuildContext context, WidgetRef ref) {
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            
            GestureDetector(
                  onTap: () => _showDateTimePickerStart(context, ref),
                  child: Consumer(
                  builder: (context, ref, child) {
                  final selectedDate = ref.watch(dateTimeStartProvider);
                
                 return Text("開始"+DateFormat('yyyy-MM-dd - kk:mm').format(selectedDate));
                },
               ),
              ),
            GestureDetector(
                  onTap: () => _showDateTimePickerEnd(context, ref),
                  child: Consumer(
                  builder: (context, ref, child) {
                  final selectedDate = ref.watch(dateTimeEndProvider);
                 
                 return Text("終了"+DateFormat('yyyy-MM-dd - kk:mm').format(selectedDate));
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
