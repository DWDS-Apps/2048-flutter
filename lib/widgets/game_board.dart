import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final List<TileData> tiles;
  final void Function(Direction) onSwipe;
  final int gridSize;

  const GameBoard({
    super.key,
    required this.tiles,
    required this.onSwipe,
    this.gridSize = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth;
      final gutter = 8.0;
      final tileSize = (size - (gridSize + 1) * gutter) / gridSize;

      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! > 0) {
            onSwipe(Direction.right);
          } else {
            onSwipe(Direction.left);
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! > 0) {
            onSwipe(Direction.down);
          } else {
            onSwipe(Direction.up);
          }
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.arrowLeft) {
                onSwipe(Direction.left);
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowRight) {
                onSwipe(Direction.right);
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowUp) {
                onSwipe(Direction.up);
                return KeyEventResult.handled;
              } else if (key == LogicalKeyboardKey.arrowDown) {
                onSwipe(Direction.down);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkBoardBackground
                  : AppTheme.boardBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(gutter),
            child: Stack(
              children: [
                // Grid background cells
                for (int r = 0; r < gridSize; r++)
                  for (int c = 0; c < gridSize; c++)
                    Positioned(
                      left: gutter + c * (tileSize + gutter),
                      top: gutter + r * (tileSize + gutter),
                      child: Container(
                        width: tileSize,
                        height: tileSize,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkCellBackground
                              : AppTheme.cellBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                // Tiles with animated positioning
                for (final tile in tiles)
                  AnimatedPositioned(
                    key: ValueKey('tile_${tile.id}'),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    left: gutter + tile.col * (tileSize + gutter),
                    top: gutter + tile.row * (tileSize + gutter),
                    child: SizedBox(
                      width: tileSize,
                      height: tileSize,
                      child: TileWidget(
                        value: tile.value,
                        isNew: tile.isNew,
                        isMerged: tile.isMerged,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
