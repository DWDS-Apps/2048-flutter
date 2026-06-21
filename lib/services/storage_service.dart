import 'dart:convert';
import 'dart:io';

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
  static const String _prefix = '2048_';

  String get _filePath {
    // Use a simple file path in the app's data directory
    final dir = Directory('/tmp/2048_flutter_data');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return '${dir.path}/storage.json';
  }

  Map<String, dynamic> _readAll() {
    try {
      final file = File(_filePath);
      if (!file.existsSync()) return {};
      final content = file.readAsStringSync();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _writeAll(Map<String, dynamic> data) {
    final file = File(_filePath);
    file.writeAsStringSync(jsonEncode(data));
  }

  Future<int> loadBestScore() async {
    final data = _readAll();
    return data[_bestScoreKey] as int? ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final data = _readAll();
    data[_bestScoreKey] = score;
    _writeAll(data);
  }

  Future<bool> loadDarkMode() async {
    final data = _readAll();
    return data[_darkModeKey] as bool? ?? false;
  }

  Future<void> saveDarkMode(bool dark) async {
    final data = _readAll();
    data[_darkModeKey] = dark;
    _writeAll(data);
  }

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final data = _readAll();
    final jsonStr = data[_leaderboardKey] as String?;
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
    final data = _readAll();
    data[_leaderboardKey] = jsonEncode(top.map((e) => e.toJson()).toList());
    _writeAll(data);
  }
}
