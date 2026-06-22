import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ScoreBoard extends StatefulWidget {
  final int score;
  final String label;

  const ScoreBoard({
    super.key,
    required this.score,
    this.label = 'Score',
  });

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;
  }

  @override
  void didUpdateWidget(ScoreBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _previousScore = oldWidget.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBest = widget.label == 'Best';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBoardBackground : AppTheme.boardBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFFeee4da),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          if (isBest)
            Text(
              '${widget.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: _previousScore, end: widget.score),
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
