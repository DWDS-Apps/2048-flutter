import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/models/game_state.dart';
import 'package:game2048/controllers/game_controller.dart';

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

      // Count non-null tiles
      int count = 0;
      for (final row in state.grid) {
        for (final cell in row) {
          if (cell != null) count++;
        }
      }
      expect(count, 2);
    });

    test('reset clears the board and starts fresh', () {
      controller.handleSwipe(Direction.left);
      controller.reset();

      final state = controller.state;
      expect(state.score, 0);
      expect(state.gameOver, false);

      int count = 0;
      for (final row in state.grid) {
        for (final cell in row) {
          if (cell != null) count++;
        }
      }
      expect(count, 2);
    });

    test('swipe with no possible movement does nothing', () {
      // Fill board with alternating non-mergable values
      controller.reset();

      // Manually set a full board with no possible moves
      final grid = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [8192, 16384, 32768, 65536],
      ];

      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      // Capture tile count before
      int countBefore = 0;
      for (final row in controller.state.grid) {
        for (final cell in row) {
          if (cell != null) countBefore++;
        }
      }

      controller.handleSwipe(Direction.left);

      int countAfter = 0;
      for (final row in controller.state.grid) {
        for (final cell in row) {
          if (cell != null) countAfter++;
        }
      }

      // No new tile should spawn since nothing moved
      expect(countBefore, countAfter);
    });

    test('undo restores previous state', () {
      final stateBefore = controller.state.clone();

      controller.handleSwipe(Direction.left);
      controller.undo();

      final state = controller.state;
      expect(state.score, stateBefore.score);
      expect(state.gameOver, stateBefore.gameOver);

      // Grid should match
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          expect(state.grid[r][c], stateBefore.grid[r][c]);
        }
      }
    });

    test('undo cannot be called twice', () {
      controller.handleSwipe(Direction.left);
      controller.undo();
      // Save state after first undo
      final stateAfterUndo = controller.state.clone();
      controller.undo();
      // Should still be the same (no change)
      expect(controller.state.score, stateAfterUndo.score);
      expect(controller.state.history, null);
    });

    test('undo is not available on fresh game', () {
      expect(controller.state.history, null);
    });

    test('swipe left merges tiles correctly', () {
      // Manually set up a board with merges possible left
      controller.reset();
      final grid = [
        [2, 2, 4, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      controller.handleSwipe(Direction.left);

      // Row 0: [2,2,4,null] → [4,4,null,null]
      expect(controller.state.grid[0][0], 4);
      expect(controller.state.grid[0][1], 4);
      expect(controller.state.grid[0][2], null);
      expect(controller.state.grid[0][3], null);
      expect(controller.state.score, 4);
    });

    test('swipe right merges tiles correctly', () {
      controller.reset();
      final grid = [
        [null, 2, 2, 4],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      controller.handleSwipe(Direction.right);

      // Row 0 reversed: [4,2,2,null] → slideLine → [4,4,null,null] → reverse → [null,null,4,4]
      expect(controller.state.grid[0][0], null);
      expect(controller.state.grid[0][1], null);
      expect(controller.state.grid[0][2], 4);
      expect(controller.state.grid[0][3], 4);
      expect(controller.state.score, 4);
    });

    test('swipe up merges tiles correctly', () {
      controller.reset();
      // Set column 0: [2,2,null,null]
      final grid = [
        [2, null, null, null],
        [2, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      controller.handleSwipe(Direction.up);

      // Column 0: [2,2,null,null] → [4,null,null,null]
      expect(controller.state.grid[0][0], 4);
      expect(controller.state.grid[1][0], null);
      expect(controller.state.score, 4);
    });

    test('swipe down merges tiles correctly', () {
      controller.reset();
      final grid = [
        [null, null, null, null],
        [null, null, null, null],
        [2, null, null, null],
        [2, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      controller.handleSwipe(Direction.down);

      // Column 0 reversed: [2,2] → [4,null] → after reversal: [null,null,4]
      // Actually down processes [3][0],[2][0],[1][0],[0][0] = [2,2,null,null]
      // slideLine → [4,null,null,null], reverse → [4,null,null,null]
      expect(controller.state.grid[3][0], 4);
      expect(controller.state.grid[2][0], null);
      expect(controller.state.score, 4);
    });

    test('score accumulates across moves', () {
      controller.reset();
      // Set up two moves worth of merges
      final grid = [
        [2, 2, 4, 4],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }

      controller.handleSwipe(Direction.left);
      // First move: [2,2,4,4] → [4,8,null,null] ⇒ score +12
      final scoreAfterFirst = controller.state.score;

      // Second move: set up another merge opportunity
      final grid2 = [
        [4, null, null, null],
        [8, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid2[r][c];
        }
      }

      controller.handleSwipe(Direction.down);
      // Second move should add more score
      expect(controller.state.score, greaterThan(scoreAfterFirst));
    });

    test('gameOver triggers when board is full and no merges possible', () {
      controller.reset();
      final grid = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [8192, 16384, 32768, 65536],
      ];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          controller.state.grid[r][c] = grid[r][c];
        }
      }
      controller.state.gameOver = false;

      // Any swipe should trigger game over check
      controller.handleSwipe(Direction.left);
      expect(controller.state.gameOver, true);
    });

    test('keepPlaying suppresses win overlay', () {
      controller.reset();
      controller.state.grid[0][0] = 2048;
      controller.state.won = false;

      // Trigger win detection
      controller.handleSwipe(Direction.down);
      // The board has 2048, so won should be true
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
