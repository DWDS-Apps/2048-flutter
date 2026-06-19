import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int bestScore;
  final String label;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.bestScore,
    this.label = 'Score',
  });

  @override
  Widget build(BuildContext context) {
    final bool isBest = label == 'Best';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.boardBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFeee4da),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          if (isBest)
            Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: score, end: score),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
