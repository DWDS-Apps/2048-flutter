import 'package:flutter_test/flutter_test.dart';
import 'package:merge_up_2048/models/game_state.dart';
import 'package:merge_up_2048/controllers/game_controller.dart';

/// Helper: set both value and tileId at (row,col).
void _setCell(GameController ctrl, int row, int col, int? value, {int? id}) {
  ctrl.state.grid[row][col] = value;
  ctrl.state.tileIds[row][col] = id ?? value;
}

/// Helper: bulk set a grid of values, assigning sequential tile IDs.
void _setGrid(GameController ctrl, List<List<int?>> values) {
  int nextId = 1000;
  for (int r = 0; r < values.length; r++) {
    for (int col = 0; col < values[r].length; col++) {
      _setCell(ctrl, r, col, values[r][col], id: values[r][col] != null ? nextId++ : null);
    }
  }
}

/// Count non-null tiles in the grid.
int _countTiles(GameController ctrl) {
  int count = 0;
  for (final row in ctrl.state.grid) {
    for (final cell in row) {
      if (cell != null) count++;
    }
  }
  return count;
}

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
    });

    test('initializes with two tiles and score 0', () {
      final state = controller.state;
      expect(state.score, 0);
      expect(state.gameOver, false);
      expect(state.won, false);
      expect(_countTiles(controller), 2);
    });

    test('reset clears the board and starts fresh', () {
      controller.handleSwipe(Direction.left);
      controller.reset();

      final state = controller.state;
      expect(state.score, 0);
      expect(state.gameOver, false);
      expect(_countTiles(controller), 2);
    });

    test('swipe with no possible movement does nothing', () {
      controller.reset();
      _setGrid(controller, [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [8192, 16384, 32768, 65536],
      ]);

      final countBefore = _countTiles(controller);
      expect(countBefore, 16);

      controller.handleSwipe(Direction.left);

      // No movement possible — no new tile should spawn, count unchanged
      expect(_countTiles(controller), countBefore);
    });

    test('undo restores previous state', () {
      final stateBefore = controller.state.clone();

      controller.handleSwipe(Direction.left);
      controller.undo();

      final state = controller.state;
      expect(state.score, stateBefore.score);
      expect(state.gameOver, stateBefore.gameOver);

      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          expect(state.grid[r][c], stateBefore.grid[r][c]);
        }
      }
    });

    test('undo cannot be called twice', () {
      controller.handleSwipe(Direction.left);
      controller.undo();
      final stateAfterUndo = controller.state.clone();
      controller.undo();
      expect(controller.state.score, stateAfterUndo.score);
      expect(controller.state.history, null);
    });

    test('undo is not available on fresh game', () {
      expect(controller.state.history, null);
    });

    test('swipe left merges tiles correctly', () {
      controller.reset();
      _setGrid(controller, [
        [2, 2, 4, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      controller.handleSwipe(Direction.left);

      // [2,2,4,null] → slide → [4,4,null,null] + spawned tile
      expect(controller.state.grid[0][0], 4);
      expect(controller.state.grid[0][1], 4);
      expect(controller.state.score, 4);
      // 2 merged tiles + 1 spawned = 3 total
      expect(_countTiles(controller), 3);
    });

    test('swipe right merges tiles correctly', () {
      controller.reset();
      _setGrid(controller, [
        [null, 2, 2, 4],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      controller.handleSwipe(Direction.right);

      // [null,2,2,4] → reversed → [4,2,2,null] → slide → [4,4,null,null] → reverse → [null,null,4,4] + spawn
      expect(controller.state.grid[0][2], 4);
      expect(controller.state.grid[0][3], 4);
      expect(controller.state.score, 4);
      expect(_countTiles(controller), 3);
    });

    test('swipe up merges tiles correctly', () {
      controller.reset();
      _setGrid(controller, [
        [2, null, null, null],
        [2, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      controller.handleSwipe(Direction.up);

      // Column 0: [2,2,null,null] → slide (up) → [4,null,null,null] + spawn
      expect(controller.state.grid[0][0], 4);
      expect(controller.state.score, 4);
      expect(_countTiles(controller), 2); // 1 merge result + 1 spawn
    });

    test('swipe down merges tiles correctly', () {
      controller.reset();
      _setGrid(controller, [
        [null, null, null, null],
        [null, null, null, null],
        [2, null, null, null],
        [2, null, null, null],
      ]);

      controller.handleSwipe(Direction.down);

      // Column 0 processed bottom-to-top: [2,2,null,null] → [4,null,null,null] + spawn
      expect(controller.state.grid[3][0], 4);
      expect(controller.state.score, 4);
      expect(_countTiles(controller), 2); // 1 merge result + 1 spawn
    });

    test('score accumulates across moves', () {
      controller.reset();
      _setGrid(controller, [
        [2, 2, 4, 4],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      controller.handleSwipe(Direction.left);
      // First move: [2,2,4,4] → [4,8,null,null] ⇒ score +12
      final scoreAfterFirst = controller.state.score;
      expect(scoreAfterFirst, greaterThan(0));

      // Second move: set up another merge opportunity with matching values
      _setGrid(controller, [
        [4, null, null, null],
        [4, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);

      controller.handleSwipe(Direction.down);
      // Second move should add more score
      expect(controller.state.score, greaterThan(scoreAfterFirst));
    });

    test('gameOver triggers when board is full and no merges possible', () {
      controller.reset();
      // Set up a board where one move is possible (row 3 shifts left),
      // and after the move + new tile spawn the board is full with no
      // adjacent equals, exercising the actual game-over code path.
      _setGrid(controller, [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [null, 8192, 16384, 32768],
      ]);

      controller.handleSwipe(Direction.left);

      // Row 3: [null,8192,16384,32768] → [8192,16384,32768,null]
      // New tile spawns at [3][3]. Since 4096 != 2/4 and 32768 != 2/4,
      // no adjacent equals exist → gameOver = true
      expect(controller.state.gameOver, isTrue);
      expect(controller.state.canMove(), isFalse);
    });

    test('keepPlaying suppresses win overlay', () {
      controller.reset();
      _setGrid(controller, [
        [2048, null, null, null],
        [2, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ]);
      controller.state.won = false;

      // A downward move shifts the 2048 tile, triggering win detection
      controller.handleSwipe(Direction.down);
      expect(controller.state.won, true);

      controller.keepPlaying();
      expect(controller.state.keepPlaying, true);
      expect(controller.state.hasWon(), false);
    });

    test('renderTiles contains correct number of tiles', () {
      int count = 0;
      for (final row in controller.state.grid) {
        for (final cell in row) {
          if (cell != null) count++;
        }
      }
      expect(controller.state.renderTiles.length, count);
    });
  });
}
