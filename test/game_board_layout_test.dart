import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/models/game_state.dart';
import 'package:game2048/widgets/game_board.dart';

/// Wraps a widget in a MaterialApp + fixed-size container so LayoutBuilder
/// has known constraints.
Widget wrapInApp(Widget child, {double size = 360}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: size,
        height: size,
        child: child,
      ),
    ),
  );
}

/// Find all AnimatedPositioned widgets and return their (left, top) as
/// (double, double) tuples.
List<({double left, double top, Key? key})> getTilePositions(WidgetTester tester) {
  final positions = <({double left, double top, Key? key})>[];
  final animatedPositions = find.byType(AnimatedPositioned);
  for (int i = 0; i < animatedPositions.evaluate().length; i++) {
    final element = animatedPositions.evaluate().elementAt(i);
    final widget = element.widget as AnimatedPositioned;
    positions.add((
      left: widget.left,
      top: widget.top,
      key: widget.key,
    ));
  }
  return positions;
}

/// Find all background cell Positioned widgets and return their (left, top).
List<({double left, double top})> getCellPositions(WidgetTester tester) {
  final positions = <({double left, double top})>[];
  // Background cells are Positioned with no key, inside the first Stack
  final stack = find.byType(Stack);
  if (stack.evaluate().isEmpty) return positions;
  final stackElement = stack.evaluate().first;
  final stackWidget = stackElement.widget as Stack;

  // Collect all direct Positioned children of this Stack
  for (final child in stackWidget.children) {
    if (child is Positioned) {
      positions.add((left: child.left ?? 0, top: child.top ?? 0));
    }
  }
  return positions;
}

void main() {
  group('GameBoard layout', () {
    const double gutter = 8.0;
    const int gridSize = 4;

    /// Expected tile size for a given container size.
    double tileSize(double containerSize) {
      return (containerSize - (gridSize + 1) * gutter) / gridSize;
    }

    /// Expected left position for tile at column c.
    double expectLeft(double containerSize, int c) {
      return gutter + c * (tileSize(containerSize) + gutter);
    }

    /// Expected top position for tile at row r.
    double expectTop(double containerSize, int r) {
      return gutter + r * (tileSize(containerSize) + gutter);
    }

    testWidgets('tiles are positioned at correct grid coordinates',
        (WidgetTester tester) async {
      const double size = 360;
      const expectedTileSize = (size - 5 * gutter) / 4; // = 80

      final tiles = [
        const TileData(id: 1, value: 2, row: 0, col: 0),
        const TileData(id: 2, value: 4, row: 0, col: 3),
        const TileData(id: 3, value: 8, row: 3, col: 0),
        const TileData(id: 4, value: 16, row: 3, col: 3),
      ];

      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: tiles,
          onSwipe: (_) {},
          gridSize: gridSize,
        ),
        size: size,
      ));

      final positions = getTilePositions(tester);

      // We should have exactly 4 tile positions
      expect(positions.length, 4);

      // Tile at (row=0, col=0): left=8, top=8
      expect(positions[0].left, closeTo(expectLeft(size, 0), 0.01));
      expect(positions[0].top, closeTo(expectTop(size, 0), 0.01));

      // Tile at (row=0, col=3): left=8+3*88=272, top=8
      expect(positions[1].left, closeTo(expectLeft(size, 3), 0.01));
      expect(positions[1].top, closeTo(expectTop(size, 0), 0.01));

      // Tile at (row=3, col=0): left=8, top=8+3*88=272
      expect(positions[2].left, closeTo(expectLeft(size, 0), 0.01));
      expect(positions[2].top, closeTo(expectTop(size, 3), 0.01));

      // Tile at (row=3, col=3): left=272, top=272
      expect(positions[3].left, closeTo(expectLeft(size, 3), 0.01));
      expect(positions[3].top, closeTo(expectTop(size, 3), 0.01));
    });

    testWidgets('tile positions match background cell positions',
        (WidgetTester tester) async {
      const double size = 360;

      final tiles = [
        const TileData(id: 1, value: 2, row: 0, col: 0),
        const TileData(id: 2, value: 4, row: 2, col: 2),
      ];

      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: tiles,
          onSwipe: (_) {},
          gridSize: gridSize,
        ),
        size: size,
      ));

      final tilePos = getTilePositions(tester);
      final cellPos = getCellPositions(tester);

      // There should be 16 background cells (4x4 grid)
      expect(cellPos.length, 16);

      // Tile at (0,0) should be at the same position as cell (0,0)
      final cell00 = cellPos.firstWhere(
        (c) => c.left.closeTo(expectLeft(size, 0), 0.01) &&
                c.top.closeTo(expectTop(size, 0), 0.01),
      );
      expect(cell00.left, closeTo(tilePos[0].left, 0.01));
      expect(cell00.top, closeTo(tilePos[0].top, 0.01));

      // Tile at (2,2) should be at the same position as cell (2,2)
      final cell22 = cellPos.firstWhere(
        (c) => c.left.closeTo(expectLeft(size, 2), 0.01) &&
                c.top.closeTo(expectTop(size, 2), 0.01),
      );
      expect(cell22.left, closeTo(tilePos[1].left, 0.01));
      expect(cell22.top, closeTo(tilePos[1].top, 0.01));
    });

    testWidgets('all tiles stay within board bounds',
        (WidgetTester tester) async {
      const double size = 360;
      final expectedTileSize = tileSize(size);
      const maxPixels = size;

      // Fill all 16 cells with tiles
      final tiles = [
        for (int r = 0; r < 4; r++)
          for (int c = 0; c < 4; c++)
            TileData(id: r * 4 + c, value: 2, row: r, col: c),
      ];

      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: tiles,
          onSwipe: (_) {},
          gridSize: gridSize,
        ),
        size: size,
      ));

      final positions = getTilePositions(tester);
      expect(positions.length, 16);

      for (final pos in positions) {
        // Each tile should be fully inside the board
        expect(pos.left, greaterThanOrEqualTo(0));
        expect(pos.top, greaterThanOrEqualTo(0));
        expect(pos.left + expectedTileSize, lessThanOrEqualTo(maxPixels));
        expect(pos.top + expectedTileSize, lessThanOrEqualTo(maxPixels));
      }
    });

    testWidgets('no tile overlaps another tile',
        (WidgetTester tester) async {
      const double size = 360;
      final expectedTileSize = tileSize(size);

      // Fill all 16 cells
      final tiles = [
        for (int r = 0; r < 4; r++)
          for (int c = 0; c < 4; c++)
            TileData(id: r * 4 + c, value: 2, row: r, col: c),
      ];

      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: tiles,
          onSwipe: (_) {},
          gridSize: gridSize,
        ),
        size: size,
      ));

      final positions = getTilePositions(tester);
      expect(positions.length, 16);

      // Check no two tiles occupy the same bounding box
      for (int i = 0; i < positions.length; i++) {
        for (int j = i + 1; j < positions.length; j++) {
          final a = positions[i];
          final b = positions[j];
          final leftOverlap = (a.left - b.left).abs() < 1;
          final topOverlap = (a.top - b.top).abs() < 1;
          expect(leftOverlap && topOverlap, isFalse,
              reason:
                  'Tiles at indices $i and $j overlap at (${a.left}, ${a.top}) and (${b.left}, ${b.top})');
        }
      }
    });

    testWidgets('board renders correct number of background cells',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: const [],
          onSwipe: (_) {},
          gridSize: 4,
        ),
        size: 360,
      ));

      final cells = getCellPositions(tester);
      expect(cells.length, 16);
    });

    testWidgets('tile keys include tile IDs for stable identity',
        (WidgetTester tester) async {
      const tiles = [
        TileData(id: 42, value: 8, row: 1, col: 2),
      ];

      await tester.pumpWidget(wrapInApp(
        GameBoard(
          tiles: tiles,
          onSwipe: (_) {},
          gridSize: 4,
        ),
        size: 360,
      ));

      final positions = getTilePositions(tester);
      expect(positions.length, 1);
      expect(positions[0].key, isA<ValueKey<int>>());
      final valueKey = positions[0].key as ValueKey<int>;
      expect(valueKey.value, 42);
    });
  });
}
