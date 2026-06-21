import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/models/game_state.dart';

void main() {
  group('slideLine', () {
    test('slides tiles to the left, merging after slide', () {
      final result = slideLine([2, null, null, 2]);
      // [2, null, null, 2] → filter nulls → [2,2] → merge → [4] → pad → [4, null, null, null]
      expect(result.line, [4, null, null, null]);
      expect(result.score, 4);
      expect(result.moved, true);
    });

    test('merges two adjacent equal tiles once', () {
      final result = slideLine([2, 2, 4, null]);
      expect(result.line, [4, 4, null, null]);
      expect(result.score, 4);
      expect(result.moved, true);
    });

    test('cascading merge [2,2,4,4] produces [4,8,null,null]', () {
      final result = slideLine([2, 2, 4, 4]);
      expect(result.line, [4, 8, null, null]);
      expect(result.score, 12);
      expect(result.moved, true);
    });

    test('no merge on different values [2,4,8,16]', () {
      final result = slideLine([2, 4, 8, 16]);
      expect(result.line, [2, 4, 8, 16]);
      expect(result.score, 0);
      expect(result.moved, false);
    });

    test('three same values [2,2,2,null] merges only first pair', () {
      final result = slideLine([2, 2, 2, null]);
      expect(result.line, [4, 2, null, null]);
      expect(result.score, 4);
      expect(result.moved, true);
    });

    test('four same values [2,2,2,2] merges into [4,4,null,null]', () {
      final result = slideLine([2, 2, 2, 2]);
      expect(result.line, [4, 4, null, null]);
      expect(result.score, 8);
      expect(result.moved, true);
    });

    test('empty line returns all nulls', () {
      final result = slideLine([null, null, null, null]);
      expect(result.line, [null, null, null, null]);
      expect(result.score, 0);
      expect(result.moved, false);
    });

    test('single tile stays in place', () {
      final result = slideLine([null, null, null, 2]);
      expect(result.line, [2, null, null, null]);
      expect(result.score, 0);
      expect(result.moved, true);
    });

    test('already compacted line [4,8,null,null] stays', () {
      final result = slideLine([4, 8, null, null]);
      expect(result.line, [4, 8, null, null]);
      expect(result.score, 0);
      expect(result.moved, false);
    });
  });

  group('GameState', () {
    test('emptyCells returns all cells on empty grid', () {
      final state = GameState();
      expect(state.emptyCells.length, 16);
    });

    test('emptyCells excludes occupied cells', () {
      final state = GameState();
      state.grid[0][0] = 2;
      state.grid[1][1] = 4;
      expect(state.emptyCells.length, 14);
    });

    test('canMove returns true when empty cells exist', () {
      final state = GameState();
      expect(state.canMove(), true);
    });

    test('canMove returns true when adjacent equal tiles exist', () {
      final state = GameState()
        ..grid[0] = [2, 4, 8, 16].toList()
        ..grid[1] = [3, 6, 12, 24].toList()
        ..grid[2] = [5, 10, 20, 40].toList()
        ..grid[3] = [7, null, 28, 56].toList();
      // There's a null at [3][1], so it's still movable
      expect(state.canMove(), true);
    });

    test('canMove returns false when full grid with no adjacent equals', () {
      final state = GameState()
        ..grid[0] = [2, 4, 8, 16].toList()
        ..grid[1] = [32, 64, 128, 256].toList()
        ..grid[2] = [512, 1024, 2048, 4096].toList()
        ..grid[3] = [8192, 16384, 32768, 65536].toList();
      expect(state.canMove(), false);
    });

    test('hasWon returns true when 2048 tile exists', () {
      final state = GameState()
        ..grid[0][0] = 2048;
      expect(state.hasWon(), true);
    });

    test('hasWon returns false when no 2048 tile exists', () {
      final state = GameState()
        ..grid[0][0] = 1024;
      expect(state.hasWon(), false);
    });

    test('hasWon returns false when keepPlaying is true', () {
      final state = GameState()
        ..keepPlaying = true
        ..grid[0][0] = 2048;
      expect(state.hasWon(), false);
    });

    test('clone creates deep copy', () {
      final state = GameState()
        ..grid[0][0] = 2
        ..grid[1][1] = 4
        ..score = 10;
      final cloned = state.clone();
      cloned.grid[0][0] = null;
      cloned.score = 20;

      expect(state.grid[0][0], 2);
      expect(state.score, 10);
      expect(cloned.score, 20);
    });

    test('clone includes history', () {
      final state = GameState()
        ..history = MoveRecord(
          grid: [[2, null, null, null], [null, null, null, null], [null, null, null, null], [null, null, null, null]],
          tileIds: [[1, null, null, null], [null, null, null, null], [null, null, null, null], [null, null, null, null]],
          score: 0,
        );
      final cloned = state.clone();
      expect(cloned.history, isNotNull);
      expect(cloned.history!.grid[0][0], 2);
    });
  });

  group('Position', () {
    test('equality works', () {
      expect(const Position(0, 0), const Position(0, 0));
      expect(const Position(1, 2), isNot(const Position(2, 1)));
    });

    test('hashCode handles different positions', () {
      final set = {const Position(0, 0), const Position(1, 0), const Position(0, 1)};
      expect(set.length, 3);
    });
  });
}
