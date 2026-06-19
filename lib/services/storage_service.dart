import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final int score;
  final String date;
  final int gridSize;

  const LeaderboardEntry({
    required this.score,
    required this.date,
    required this.gridSize,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date,
    'gridSize': gridSize,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      score: json['score'] as int,
      date: json['date'] as String,
      gridSize: (json['gridSize'] as int?) ?? 4,
    );
  }
}

class StorageService {
  static const String _bestScoreKey = 'best_score';
  static const String _darkModeKey = 'dark_mode';
  static const String _leaderboardKey = 'leaderboard';

  Future<int> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, score);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, dark);
  }

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_leaderboardKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    final entries = await loadLeaderboard();
    entries.add(entry);
    entries.sort((a, b) => b.score.compareTo(a.score));
    // Keep top 5
    final top = entries.take(5).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _leaderboardKey,
      jsonEncode(top.map((e) => e.toJson()).toList()),
    );
  }
}
