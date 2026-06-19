import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class GameOverlay extends StatelessWidget {
  final bool won;
  final bool gameOver;
  final int score;
  final VoidCallback onKeepGoing;
  final VoidCallback onNewGame;

  const GameOverlay({
    super.key,
    required this.won,
    required this.gameOver,
    required this.score,
    required this.onKeepGoing,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    if (!won && !gameOver) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              won ? 'You Win!' : 'Game Over',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFFeee4da),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (won)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: onKeepGoing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tile2048,
                    foregroundColor: AppTheme.darkText,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Keep Going', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ElevatedButton(
              onPressed: onNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.darkText,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('New Game', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
