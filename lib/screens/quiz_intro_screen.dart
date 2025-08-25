import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../widgets/leaderboard_widget.dart';
import '../models/question.dart';

class QuizIntroScreen extends StatelessWidget {
  final List<Question> questions; // 傳入題庫

  const QuizIntroScreen({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('紫微斗數測驗說明')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 遊戲說明
            Text(
              '遊戲說明：\n'
              '1. 每次測驗 20 題\n'
              '2. 答對越快得分越高\n'
              '3. 連續快速答對可進入 Fever 模式，分數加更多！\n',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // 排行榜
            LeaderboardWidget(),
            SizedBox(height: 20),

            // 開始測驗按鈕
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(questions: questions),
                  ),
                );
              },
              child: Text('開始測驗'),
            ),
          ],
        ),
      ),
    );
  }
}
