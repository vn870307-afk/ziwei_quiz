import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  _LeaderboardWidgetState createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final data = await LeaderboardService.getTopScores();
    setState(() {
      leaderboard = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '排行榜',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        if (leaderboard.isEmpty)
          Text('目前沒有紀錄', style: TextStyle(fontSize: 16))
        else
          ...leaderboard.asMap().entries.map((entry) {
            final idx = entry.key;
            final player = entry.value;
            return Text(
              '${idx + 1}. ${player['name']} - ${player['score']} 分',
              style: TextStyle(fontSize: 16),
            );
          }),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await LeaderboardService.clear();
            _loadLeaderboard();
          },
          child: Text('清空排行榜（測試用）'),
        ),
      ],
    );
  }
}
