import 'dart:math';

class Question {
  final int id;
  final String question;
  final String answer;
  final List<String> distractors;

  Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.distractors,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      distractors: List<String>.from(json['distractors']),
    );
  }

  /// 產生隨機選項（正解 + 5 個隨機干擾，再打亂）
  List<String> generateOptions() {
    final random = Random();
    final shuffled = distractors..shuffle(random);

    // 取 5 個干擾 + 正確答案
    final selected = shuffled.take(5).toList()..add(answer);

    // 再打亂
    selected.shuffle(random);
    return selected;
  }
}
