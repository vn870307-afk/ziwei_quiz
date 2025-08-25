import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  static Future<List<Question>> loadQuestions({String path = 'assets/data/questions.json'}) async {
    try {
      final String response = await rootBundle.loadString(path);
      final List<dynamic> data = json.decode(response);
      return data.map((q) => Question.fromJson(q)).toList();
    } catch (e) {
      print("載入題庫失敗: $e");
      throw e;
    }
  }
}
