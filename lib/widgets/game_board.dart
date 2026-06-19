import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import 'tile_widget.dart';

class GameBoard extends StatelessWidget {
  final List<List<int?>> grid;
  final void Function(Direction) onSwipe;

  const GameBoard({super.key, required this.grid, required this.onSwipe});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth;
      final tileSize = (size - 5 * 8) / 4;

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
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.boardBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              for (int r = 0; r < 4; r++)
                for (int c = 0; c < 4; c++)
                  Positioned(
                    left: 8 + c * (tileSize + 8),
                    top: 8 + r * (tileSize + 8),
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: AppTheme.cellBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              for (int r = 0; r < 4; r++)
                for (int c = 0; c < 4; c++)
                  if (grid[r][c] != null)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      left: 8 + c * (tileSize + 8),
                      top: 8 + r * (tileSize + 8),
                      child: SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: TileWidget(value: grid[r][c]),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }
}
