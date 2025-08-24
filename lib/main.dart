import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '紫微斗數測驗',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(), // 首頁，選擇題型
    );
  }
}
