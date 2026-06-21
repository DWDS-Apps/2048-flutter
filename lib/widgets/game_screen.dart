import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../themes/app_theme.dart';
import 'game_board.dart';
import 'game_overlay.dart';
import 'leaderboard_screen.dart';
import 'score_board.dart';

class GameScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  final int gridSize;

  const GameScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
    this.gridSize = 4,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  final StorageService _storage = StorageService();
  final SoundService _soundService = SoundService();
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(gridSize: widget.gridSize);
    _loadBestScore();
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
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
    final state = _controller.state;
    if (state.gameOver) return;
    if (state.won && !state.keepPlaying) return;

    // Save pre-move history reference to detect actual movement
    // The controller only writes a new MoveRecord when tiles actually move
    final previousHistory = state.history;

    _animating = true;
    _controller.handleSwipe(direction);

    // Check if anything actually moved (controller sets a new history object)
    final moved = state.history != previousHistory;
    if (!moved) {
      // No movement — cancel animation lock silently, no sounds
      setState(() => _animating = false);
      return;
    }

    // Play sound effects based on what happened
    if (_controller.state.lastScoreGained > 0) {
      // A merge happened — play merge sound
      _soundService.playMerge();
    } else {
      // Movement but no merge — just play swipe sound
      _soundService.playSwipe();
    }
    // New tile appears on every successful move
    _soundService.playNewTile();

    _saveBestScore();
    // Save to leaderboard on game over if score > 0
    if (_controller.state.gameOver && _controller.state.score > 0) {
      _saveToLeaderboard();
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.clearAnimationFlags();
        setState(() => _animating = false);
      }
    });
  }

  Future<void> _saveToLeaderboard() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _storage.addLeaderboardEntry(
      LeaderboardEntry(
        score: _controller.state.score,
        date: dateStr,
        gridSize: widget.gridSize,
      ),
    );
  }

  void _resetGame() {
    // Save to leaderboard before reset if score > 0
    if (_controller.state.score > 0) {
      // Fire-and-forget — save completes in background
      _saveToLeaderboard();
    }
    _controller.reset();
    _saveBestScore();
  }

  void _undo() {
    if (_animating) return;
    _controller.undo();
    _saveBestScore();
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
                icon: const Icon(Icons.emoji_events),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
              ),
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
                          tiles: state.renderTiles,
                          onSwipe: _handleSwipe,
                          gridSize: widget.gridSize,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppTheme.darkCellBackground : AppTheme.boardBackground,
        foregroundColor: Colors.white,
        disabledBackgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
