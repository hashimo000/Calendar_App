import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPage extends ConsumerWidget {
  const AddPage({Key? key}) : super(key: key);

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
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white, // アプリバーの色に合わせて文字色を白に設定
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: const <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: ('タイトルを入力してください'),
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
