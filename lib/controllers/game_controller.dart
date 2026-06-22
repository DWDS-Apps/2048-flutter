import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

class GameController extends ChangeNotifier {
  final int _gridSize;
  GameState _state;
  final Random _random = Random();
  int _nextIdCounter = 1;

  GameController({int gridSize = 4})
      : _gridSize = gridSize,
        _state = GameState(gridSize: gridSize) {
    _initGame();
  }

  GameState get state => _state;

  int get gridSize => _gridSize;

  int _nextTileId() => _nextIdCounter++;

  void _initGame() {
    _state = GameState(gridSize: _gridSize, bestScore: _state.bestScore);
    _addRandomTile();
    _addRandomTile();
    _syncRenderTiles();
    notifyListeners();
  }

  void reset() {
    _initGame();
  }

  void handleSwipe(Direction direction) {
    if (_state.gameOver) return;
    if (_state.won && !_state.keepPlaying) return;

    // Save state for undo
    final oldGrid = _state.grid.map((row) => row.toList()).toList();
    final oldTileIds = _state.tileIds.map((row) => row.toList()).toList();
    final oldScore = _state.score;

    bool moved = false;
    int totalScore = 0;

    if (direction == Direction.left) {
      for (int r = 0; r < _gridSize; r++) {
        final result = _slideLineWithIds(
          _state.grid[r], _state.tileIds[r],
        );
        _state.grid[r] = result.line;
        _state.tileIds[r] = result.lineIds;
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.right) {
      for (int r = 0; r < _gridSize; r++) {
        final reversed = _state.grid[r].reversed.toList();
        final reversedIds = _state.tileIds[r].reversed.toList();
        final result = _slideLineWithIds(reversed, reversedIds);
        _state.grid[r] = result.line.reversed.toList();
        _state.tileIds[r] = result.lineIds.reversed.toList();
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.up) {
      for (int c = 0; c < _gridSize; c++) {
        final col = <int?>[];
        final colIds = <int?>[];
        for (int r = 0; r < _gridSize; r++) {
          col.add(_state.grid[r][c]);
          colIds.add(_state.tileIds[r][c]);
        }
        final result = _slideLineWithIds(col, colIds);
        for (int r = 0; r < _gridSize; r++) {
          _state.grid[r][c] = result.line[r];
          _state.tileIds[r][c] = result.lineIds[r];
        }
        totalScore += result.score;
        moved = moved || result.moved;
      }
    } else if (direction == Direction.down) {
      for (int c = 0; c < _gridSize; c++) {
        final col = <int?>[];
        final colIds = <int?>[];
        for (int r = _gridSize - 1; r >= 0; r--) {
          col.add(_state.grid[r][c]);
          colIds.add(_state.tileIds[r][c]);
        }
        final result = _slideLineWithIds(col, colIds);
        for (int r = 0; r < _gridSize; r++) {
          _state.grid[_gridSize - 1 - r][c] = result.line[r];
          _state.tileIds[_gridSize - 1 - r][c] = result.lineIds[r];
        }
        totalScore += result.score;
        moved = moved || result.moved;
      }
    }

    if (!moved) {
      _syncRenderTiles();
      notifyListeners();
      return;
    }

    _state.history = MoveRecord(grid: oldGrid, tileIds: oldTileIds, score: oldScore);
    _state.score += totalScore;
    _state.lastScoreGained = totalScore;
    if (_state.score > _state.bestScore) {
      _state.bestScore = _state.score;
    }

    _addRandomTile();
    _syncRenderTiles(isNewTile: true);
    _state.won = _state.hasWon();
    _state.gameOver = !_state.canMove();

    notifyListeners();
  }

  _IdSlideResult _slideLineWithIds(List<int?> valueLine, List<int?> idLine) {
    final pairs = <_ValueIdPair>[];
    for (int i = 0; i < valueLine.length; i++) {
      if (valueLine[i] != null && idLine[i] != null) {
        pairs.add(_ValueIdPair(valueLine[i]!, idLine[i]!));
      }
    }

    bool moved = false;
    int score = 0;
    final result = <_ValueIdPair>[];

    int i = 0;
    while (i < pairs.length) {
      if (i + 1 < pairs.length && pairs[i].value == pairs[i + 1].value) {
        final mergedValue = pairs[i].value * 2;
        // Merged tile gets a new ID (the old ones disappear)
        result.add(_ValueIdPair(mergedValue, _nextTileId()));
        score += mergedValue;
        moved = true;
        i += 2;
      } else {
        result.add(pairs[i]);
        i++;
      }
    }

    // Build final lists
    final finalValues = <int?>[];
    final finalIds = <int?>[];
    for (final p in result) {
      finalValues.add(p.value);
      finalIds.add(p.id);
    }
    while (finalValues.length < _gridSize) {
      finalValues.add(null);
      finalIds.add(null);
    }

    // Detect if move happened (even without merge)
    if (!moved) {
      for (int j = 0; j < _gridSize; j++) {
        if (valueLine[j] != finalValues[j]) {
          moved = true;
          break;
        }
      }
    }

    return _IdSlideResult(
      line: finalValues,
      lineIds: finalIds,
      score: score,
      moved: moved,
    );
  }

  void _syncRenderTiles({bool isNewTile = false}) {
    final tiles = <TileData>[];
    final mergePositions = <String>{};

    // Build set of old tile IDs for O(1) lookup
    final oldTileIds = <int>{};
    if (_state.history != null) {
      for (int r = 0; r < _gridSize; r++) {
        for (int c = 0; c < _gridSize; c++) {
          final hid = _state.history!.tileIds[r][c];
          if (hid != null) oldTileIds.add(hid);
        }
      }
    }

    // Detect merge positions by comparing with history
    if (_state.history != null) {
      for (int r = 0; r < _gridSize; r++) {
        for (int c = 0; c < _gridSize; c++) {
          final curVal = _state.grid[r][c];
          final curId = _state.tileIds[r][c];
          final histVal = _state.history!.grid[r][c];
          final histId = _state.history!.tileIds[r][c];
          if (curVal != null && curId != null) {
            if (histVal != null && histId != null) {
              // If value doubled but ID changed → merge
              if (curVal == histVal * 2 && curId != histId) {
                mergePositions.add('$r,$c');
              }
            } else if (histVal == null) {
              // This cell was empty in history — only flag as merge if it has
              // a value now AND the tile ID existed before the move
              // (i.e., it was created by a merge, not by the random spawn)
              if (!isNewTile || oldTileIds.contains(curId)) {
                mergePositions.add('$r,$c');
              }
            }
          }
        }
      }
    }

    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        final v = _state.grid[r][c];
        final id = _state.tileIds[r][c];
        if (v != null && id != null) {
          final isNew = isNewTile && !oldTileIds.contains(id);
          final isMerged = mergePositions.contains('$r,$c') && !isNew;
          tiles.add(TileData(
            id: id,
            value: v,
            row: r,
            col: c,
            isNew: isNew,
            isMerged: isMerged,
          ));
        }
      }
    }

    _state.renderTiles = tiles;
  }

  void undo() {
    if (_state.history == null) return;
    _state.grid = _state.history!.cloneGrid();
    _state.tileIds = _state.history!.cloneTileIds();
    _state.score = _state.history!.score;
    _state.history = null;
    _state.gameOver = false;
    _state.lastScoreGained = 0;
    _syncRenderTiles();
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
    final value = _random.nextDouble() < 0.9 ? 2 : 4;
    _state.grid[pos.row][pos.col] = value;
    _state.tileIds[pos.row][pos.col] = _nextTileId();
  }

  void updateBestScore(int score) {
    if (score > _state.bestScore) {
      _state.bestScore = score;
      notifyListeners();
    }
  }

  void clearAnimationFlags() {
    _state.clearAnimationFlags();
    notifyListeners();
  }
}

class _ValueIdPair {
  final int value;
  final int id;
  const _ValueIdPair(this.value, this.id);
}

class _IdSlideResult {
  final List<int?> line;
  final List<int?> lineIds;
  final int score;
  final bool moved;

  const _IdSlideResult({
    required this.line,
    required this.lineIds,
    required this.score,
    required this.moved,
  });
}
