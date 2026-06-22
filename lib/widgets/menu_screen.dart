import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const MenuScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final StorageService _storage = StorageService();
  int _bestScore = 0;
  int _gridSize = 4;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final score = await _storage.loadBestScore();
    if (mounted) setState(() => _bestScore = score);
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.isDark,
          gridSize: _gridSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppTheme.darkText;
    final mutedColor = isDark ? Colors.white70 : AppTheme.boardBackground;

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
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: $_bestScore',
              style: TextStyle(
                fontSize: 20,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Board Size',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
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
                foregroundColor: isDark ? Colors.white70 : AppTheme.darkText,
                backgroundColor: isDark ? AppTheme.darkCellBackground : AppTheme.cellBackground,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _startGame,
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
              icon: Icon(Icons.emoji_events, color: mutedColor),
              label: Text('Leaderboard', style: TextStyle(color: mutedColor)),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
