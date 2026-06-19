import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../themes/app_theme.dart';
import 'game_board.dart';
import 'game_overlay.dart';
import 'score_board.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const GameScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController _controller = GameController();
  final StorageService _storage = StorageService();
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final score = await _storage.loadBestScore();
    _controller.updateBestScore(score);
  }

  Future<void> _saveBestScore() async {
    await _storage.saveBestScore(_controller.state.bestScore);
  }

  void _handleSwipe(Direction direction) {
    if (_animating) return;
    _animating = true;
    _controller.handleSwipe(direction);
    _saveBestScore();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _animating = false);
    });
  }

  void _resetGame() {
    _controller.reset();
    _saveBestScore();
  }

  void _undo() {
    _controller.undo();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('2048'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: widget.onToggleTheme,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScoreBoard(score: state.score, bestScore: state.bestScore, label: 'Score'),
                    const SizedBox(width: 16),
                    ScoreBoard(score: state.bestScore, bestScore: state.bestScore, label: 'Best'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton('Undo', _undo, state.history == null),
                    const SizedBox(width: 12),
                    _buildButton('New Game', _resetGame, false),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        GameBoard(
                          grid: state.grid,
                          onSwipe: _handleSwipe,
                        ),
                        GameOverlay(
                          won: state.won && !state.keepPlaying,
                          gameOver: state.gameOver,
                          score: state.score,
                          onKeepGoing: () => _controller.keepPlaying(),
                          onNewGame: _resetGame,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, bool disabled) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.boardBackground,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
