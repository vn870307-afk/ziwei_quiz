import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  QuizScreen({required this.questions});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;
  bool answered = false;
  bool started = true; // 直接進入就開始
  List<String> currentOptions = [];

  int elapsedSeconds = 0;
  Timer? timer;

  int questionStartTime = 0;
  int streak = 0;
  bool feverMode = false;

  late List<Question> quizQuestions;

  int feverSeconds = 6;
  Timer? feverTimer;
  double feverProgress = 1.0;

  // Fever 動畫控制器
  late AnimationController _feverAnimController;
  late Animation<double> _feverScale;

  @override
  void initState() {
    super.initState();
    widget.questions.shuffle();
    quizQuestions = widget.questions.take(20).toList();
    _generateCurrentOptions();
    questionStartTime = 0;

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        elapsedSeconds++;
      });
    });

    // 初始化 Fever 動畫
    _feverAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _feverScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _feverAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    feverTimer?.cancel();
    _feverAnimController.dispose();
    super.dispose();
  }

  void _generateCurrentOptions() {
    final q = quizQuestions[currentIndex];
    final List<String> distractors = List.from(q.distractors);
    distractors.shuffle();
    final selectedDistractors = distractors.take(3).toList();
    currentOptions = List.from(selectedDistractors)..add(q.answer);
    currentOptions.shuffle();
    questionStartTime = elapsedSeconds;
  }

  void checkAnswer(int idx) {
    if (answered) return;

    setState(() {
      selectedIndex = idx;
      answered = true;
      final q = quizQuestions[currentIndex];
      final isCorrect = currentOptions[idx] == q.answer;

      if (isCorrect) {
        int usedTime = elapsedSeconds - questionStartTime;

        if (usedTime <= 3) {
          score += 3;
          streak++;

          if (feverMode) {
            feverSeconds = 6;
          }
        } else if (usedTime <= 6) {
          score += 1;
          streak = 0;
        } else {
          streak = 0;
        }

        if (streak >= 3 && !feverMode) {
          feverMode = true;
          feverProgress = 1.0;
          feverSeconds = 6;
          feverTimer?.cancel();
          feverTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              feverSeconds--;
              feverProgress = feverSeconds / 5;
              if (feverSeconds <= 0) {
                feverMode = false;
                streak = 0;
                feverTimer?.cancel();
              }
            });
          });
        }
      } else {
        streak = 0;
        feverMode = false;
        feverTimer?.cancel();
      }
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (currentIndex < quizQuestions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
          answered = false;
          _generateCurrentOptions();
        });
      } else {
        timer?.cancel();
        feverTimer?.cancel();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text("測驗完成"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("總用時：$elapsedSeconds 秒"),
                Text("總分數：$score"),
                Text("Fever 持續時間：約${5 - feverSeconds} 秒"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text("回首頁"),
              ),
            ],
          ),
        );
      }
    });
  }

  Color getButtonColor(int idx) {
    if (!answered) return const Color.fromARGB(255, 200, 212, 206);
    if (currentOptions[idx] == quizQuestions[currentIndex].answer) return Colors.green;
    if (idx == selectedIndex) return Colors.red;
    return const Color.fromARGB(255, 200, 212, 206);
  }

  @override
  Widget build(BuildContext context) {
    final q = quizQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("紫微斗數測驗")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("題目 ${currentIndex + 1} / ${quizQuestions.length}", style: TextStyle(fontSize: 16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("時間：$elapsedSeconds 秒", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text("分數：$score", style: TextStyle(fontSize: 16)),
                        if (feverMode)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/kuromi.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                    SizedBox(width: 4),
                                    // Fever 動畫文字
                                    ScaleTransition(
                                      scale: _feverScale,
                                      child: Text(
                                        "Fever!",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(color: Colors.purpleAccent, blurRadius: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: feverProgress,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.purple,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(q.question, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  child: Text(option, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
