import 'package:flutter/material.dart';
import 'data/question_service.dart';
import 'models/question.dart';
import 'screens/quiz_screen.dart';
import 'screens/home_screen.dart'; // 新增首頁

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '紫微斗數測驗',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(), // 這裡指定首頁
    );
  }
}
