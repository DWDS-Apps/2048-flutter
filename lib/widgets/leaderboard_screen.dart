import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../themes/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final StorageService _storage = StorageService();
  List<LeaderboardEntry> _entries = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _storage.loadLeaderboard();
    if (mounted) setState(() {
      _entries = entries;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text(
                    'No scores yet!\nPlay a game to set your first record.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final medals = ['🥇', '🥈', '🥉'];
                    final prefix = index < 3 ? medals[index] : '${index + 1}.';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(
                          prefix,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          '${entry.score}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        subtitle: Text(
                          '${entry.gridSize}×${entry.gridSize} • ${entry.date}',
                          style: TextStyle(color: AppTheme.boardBackground),
                        ),
                        trailing: Icon(
                          Icons.emoji_events,
                          color: index == 0
                              ? Colors.amber
                              : index == 1
                                  ? Colors.grey
                                  : index == 2
                                      ? Colors.brown
                                      : Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
