class TileData {
  final int id;
  final int value;
  final int row;
  final int col;
  final bool isNew;
  final bool isMerged;
  final int mergeGroup;

  const TileData({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
    this.mergeGroup = 0,
  });

  TileData copyWith({
    int? id,
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
    int? mergeGroup,
  }) {
    return TileData(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
      mergeGroup: mergeGroup ?? this.mergeGroup,
    );
  }
}

class MoveRecord {
  final List<List<int?>> grid;
  final List<List<int?>> tileIds;
  final int score;

  const MoveRecord({required this.grid, required this.tileIds, required this.score});

  List<List<int?>> cloneGrid() {
    return grid.map((row) => row.toList()).toList();
  }

  List<List<int?>> cloneTileIds() {
    return tileIds.map((row) => row.toList()).toList();
  }
}

class GameState {
  final int gridSize;
  List<List<int?>> grid;
  List<List<int?>> tileIds;
  int score;
  int bestScore;
  bool gameOver;
  bool won;
  bool keepPlaying;
  MoveRecord? history;
  List<TileData> renderTiles;
  int lastScoreGained;

  GameState({
    this.gridSize = 4,
    List<List<int?>>? grid,
    List<List<int?>>? tileIds,
    this.score = 0,
    this.bestScore = 0,
    this.gameOver = false,
    this.won = false,
    this.keepPlaying = false,
    this.history,
    List<TileData>? renderTiles,
    this.lastScoreGained = 0,
  })  : grid = grid ?? List.generate(gridSize, (_) => List<int?>.filled(gridSize, null)),
        tileIds = tileIds ?? List.generate(gridSize, (_) => List<int?>.filled(gridSize, null)),
        renderTiles = renderTiles ?? [];

  GameState clone() {
    return GameState(
      gridSize: gridSize,
      grid: grid.map((row) => row.toList()).toList(),
      tileIds: tileIds.map((row) => row.toList()).toList(),
      score: score,
      bestScore: bestScore,
      gameOver: gameOver,
      won: won,
      keepPlaying: keepPlaying,
      history: history != null
          ? MoveRecord(
              grid: history!.grid.map((r) => r.toList()).toList(),
              tileIds: history!.tileIds.map((r) => r.toList()).toList(),
              score: history!.score,
            )
          : null,
      renderTiles: List.from(renderTiles),
      lastScoreGained: lastScoreGained,
    );
  }

  List<Position> get emptyCells {
    final cells = <Position>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == null) {
          cells.add(Position(r, c));
        }
      }
    }
    return cells;
  }

  bool canMove() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == null) return true;
        if (c < gridSize - 1 && grid[r][c] == grid[r][c + 1]) return true;
        if (r < gridSize - 1 && grid[r][c] == grid[r + 1][c]) return true;
      }
    }
    return false;
  }

  bool hasWon() {
    if (keepPlaying) return false;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == 2048) return true;
      }
    }
    return false;
  }

  void clearAnimationFlags() {
    renderTiles = renderTiles
        .map((t) => t.copyWith(isNew: false, isMerged: false))
        .toList();
  }
}

class Position {
  final int row;
  final int col;
  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 31 + col;
}

enum Direction { up, down, left, right }

class SlideResult {
  final List<int?> line;
  final int score;
  final bool moved;

  const SlideResult({required this.line, required this.score, required this.moved});
}

SlideResult slideLine(List<int?> line, {int size = 4}) {
  final filtered = line.where((v) => v != null).toList();
  bool moved = false;
  int score = 0;
  final result = <int>[];

  int i = 0;
  while (i < filtered.length) {
    if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
      final merged = filtered[i]! * 2;
      result.add(merged);
      score += merged;
      moved = true;
      i += 2;
    } else {
      result.add(filtered[i]!);
      i++;
    }
  }

  while (result.length < size) {
    result.add(0);
  }

  final finalLine = result.map((v) => v == 0 ? null : v).toList();

  if (!moved) {
    for (int j = 0; j < size; j++) {
      if (line[j] != finalLine[j]) {
        moved = true;
        break;
      }
    }
  }

  return SlideResult(line: finalLine, score: score, moved: moved);
}
