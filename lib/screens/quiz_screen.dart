import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  QuizScreen({required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;
  bool answered = false;
  bool started = false;
  List<String> currentOptions = [];

  int elapsedSeconds = 0; // 總時間
  Timer? timer;

  int questionStartTime = 0; // 記錄每題開始秒數
  int streak = 0; // 連續快速答對數
  bool feverMode = false; // 是否進入 Fever

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startQuiz() {
    setState(() {
      started = true;
      score = 0;
      currentIndex = 0;
      selectedIndex = null;
      answered = false;
      elapsedSeconds = 0;
      streak = 0;
      feverMode = false;

      widget.questions.shuffle();
      _generateCurrentOptions();
      questionStartTime = 0;
    });

    // 開始計時
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void _restartQuiz() {
    setState(() {
      started = false;
      score = 0;
      currentIndex = 0;
      selectedIndex = null;
      answered = false;
      elapsedSeconds = 0;
      streak = 0;
      feverMode = false;
    });
    timer?.cancel();
  }

  void _generateCurrentOptions() {
    final q = widget.questions[currentIndex];
    final List<String> distractors = List.from(q.distractors);

    distractors.shuffle();
    final selectedDistractors = distractors.take(3).toList();
    currentOptions = List.from(selectedDistractors)..add(q.answer);
    currentOptions.shuffle();

    // 記錄這一題開始的時間
    questionStartTime = elapsedSeconds;
  }

  void checkAnswer(int idx) {
    if (answered) return;

    setState(() {
      selectedIndex = idx;
      answered = true;

      final q = widget.questions[currentIndex];
      final isCorrect = currentOptions[idx] == q.answer;

      if (isCorrect) {
        // 計算答題花費秒數
        int usedTime = elapsedSeconds - questionStartTime;

        if (feverMode) {
          score += 5; // Fever 模式固定 5 分
        } else {
          if (usedTime <= 2) {
            score += 3;
            streak++;
          } else if (usedTime <= 4) {
            score += 1;
            streak = 0;
          } else {
            score += 0;
            streak = 0;
          }

          // 判斷是否進入 Fever
          if (streak >= 3) {
            feverMode = true;
          }
        }
      } else {
        streak = 0;
        feverMode = false; // 答錯就解除 Fever
      }
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (currentIndex < widget.questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
          answered = false;
          _generateCurrentOptions();
        });
      } else {
        timer?.cancel();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("測驗完成"),
            content: Text("你的分數：$score \n總用時：$elapsedSeconds 秒"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartQuiz();
                },
                child: Text("回到首頁"),
              )
            ],
          ),
        );
      }
    });
  }

  Color getButtonColor(int idx) {
    if (!answered) return Colors.blue;
    if (currentOptions[idx] == widget.questions[currentIndex].answer) return Colors.green;
    if (idx == selectedIndex) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      return Scaffold(
        appBar: AppBar(title: Text("紫微斗數測驗")),
        body: Center(
          child: ElevatedButton(
            onPressed: _startQuiz,
            child: Text("開始測驗"),
          ),
        ),
      );
    }

    final q = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("紫微斗數測驗")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 題號 + 時間 + 分數 + Fever
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("題目 ${currentIndex + 1} / ${widget.questions.length}", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text("時間：$elapsedSeconds 秒", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Text("分數：$score", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (feverMode)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text("🔥", style: TextStyle(fontSize: 24)), // Fever 圖示
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(q.question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...currentOptions.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(idx),
                  ),
                  onPressed: () => checkAnswer(idx),
                  child: Text(option),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
