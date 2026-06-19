import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/game_state.dart';

class GameController extends ChangeNotifier {
  GameState _state;
  final Random _random = Random();

  GameController() : _state = GameState() {
    _initGame();
  }

  GameState get state => _state;

  void _initGame() {
    _state = GameState(bestScore: _state.bestScore);
    _addRandomTile();
    _addRandomTile();
    notifyListeners();
  }

  void reset() {
    _initGame();
  }

  void handleSwipe(Direction direction) {
    if (_state.gameOver) return;
    if (_state.won && !_state.keepPlaying) {
      // Win overlay is shown; wait for user action
      return;
    }

    final oldGrid = _state.grid.map((row) => row.toList()).toList();
    final oldScore = _state.score;

    bool moved = false;
    int totalScore = 0;

    if (direction == Direction.left) {
      for (int r = 0; r < 4; r++) {
        final result = slideLine(_state.grid[r]);
        _state.grid[r] = result.line;
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.right) {
      for (int r = 0; r < 4; r++) {
        final reversed = _state.grid[r].reversed.toList();
        final result = slideLine(reversed);
        _state.grid[r] = result.line.reversed.toList();
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.up) {
      for (int c = 0; c < 4; c++) {
        final col = [_state.grid[0][c], _state.grid[1][c], _state.grid[2][c], _state.grid[3][c]];
        final result = slideLine(col);
        for (int r = 0; r < 4; r++) {
          _state.grid[r][c] = result.line[r];
        }
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.down) {
      for (int c = 0; c < 4; c++) {
        final col = [_state.grid[3][c], _state.grid[2][c], _state.grid[1][c], _state.grid[0][c]];
        final result = slideLine(col);
        for (int r = 0; r < 4; r++) {
          _state.grid[3 - r][c] = result.line[r];
        }
        totalScore += result.score;
        moved = moved || result.moved;
      }
    }

    if (!moved) return;

    _state.history = MoveRecord(grid: oldGrid, score: oldScore);
    _state.score += totalScore;
    if (_state.score > _state.bestScore) {
      _state.bestScore = _state.score;
    }

    _addRandomTile();
    _state.won = _state.hasWon();
    _state.gameOver = !_state.canMove();

    notifyListeners();
  }

  void undo() {
    if (_state.history == null) return;
    _state.grid = _state.history!.cloneGrid();
    _state.score = _state.history!.score;
    _state.history = null;
    _state.gameOver = false;
    // If we undid after reaching 2048, keep won but allow playing
    notifyListeners();
  }

  void keepPlaying() {
    _state.keepPlaying = true;
    notifyListeners();
  }

  void _addRandomTile() {
    final empty = _state.emptyCells;
    if (empty.isEmpty) return;

    final pos = empty[_random.nextInt(empty.length)];
    _state.grid[pos.row][pos.col] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  void updateBestScore(int score) {
    _state.bestScore = score;
  }
}
