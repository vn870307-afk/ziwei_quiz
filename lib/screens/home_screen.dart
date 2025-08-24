import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/question_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 對應題型與題庫檔名
  final Map<String, String> questionFiles = const {
    "主星+吉凶星": "lib/data/questions.json",
    "十二宮位": "lib/data/questions_type1.json",
    "主星+吉凶星+生年四化": "lib/data/questions_type2.json",
    "主星的說話方式": "lib/data/questions_type3.json",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("紫微斗數測驗")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直置中
          crossAxisAlignment: CrossAxisAlignment.center, // 水平置中
          mainAxisSize: MainAxisSize.min, // Column 高度只包住內容
          children: [
            const Text(
              "挑戰你的紫微斗數知識！\n請選擇題型開始答題",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...questionFiles.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50), // 按鈕大小固定
                  ),
                  onPressed: () async {
                    try {
                      // 載入題庫，需傳入 path
                      final questions = await QuestionService.loadQuestions(path: entry.value);
                      if (questions.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(questions: questions),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("載入題庫失敗: $e")),
                      );
                    }
                  },
                  child: Text(entry.key, style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
