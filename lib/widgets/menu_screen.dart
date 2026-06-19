import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/storage_service.dart';
import 'leaderboard_screen.dart';

class MenuScreen extends StatefulWidget {
  final void Function(int gridSize) onPlay;

  const MenuScreen({super.key, required this.onPlay});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final StorageService _storage = StorageService();
  int _bestScore = 0;
  int _gridSize = 4;

  static const List<int> _sizeOptions = [4, 5, 6];

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final score = await _storage.loadBestScore();
    if (mounted) setState(() => _bestScore = score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '2048',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: $_bestScore',
              style: TextStyle(
                fontSize: 20,
                color: AppTheme.boardBackground,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Board Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 4, label: Text('4×4')),
                ButtonSegment(value: 5, label: Text('5×5')),
                ButtonSegment(value: 6, label: Text('6×6')),
              ],
              selected: {_gridSize},
              onSelectionChanged: (Set<int> selected) {
                setState(() => _gridSize = selected.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.boardBackground,
                selectedForegroundColor: Colors.white,
                foregroundColor: AppTheme.darkText,
                backgroundColor: AppTheme.cellBackground,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => widget.onPlay(_gridSize),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.boardBackground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Play',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LeaderboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('Leaderboard'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.boardBackground,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
