import 'dart:convert';
import 'dart:io';

class LeaderboardService {
  static const String fileName = "leaderboard.json";

  static Future<List<Map<String, dynamic>>> getTopScores() async {
    final file = File(fileName);

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final List<dynamic> list = json.decode(content);
    list.sort((a, b) => b['score'].compareTo(a['score']));
    return list.take(10).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> addScore(String name, int score) async {
    final file = File(fileName);
    List<Map<String, dynamic>> list = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      final decoded = json.decode(content) as List<dynamic>;
      list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    list.add({"name": name, "score": score});
    await file.writeAsString(json.encode(list));
  }

  static Future<void> clear() async {
    final file = File(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
