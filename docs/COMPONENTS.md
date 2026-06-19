# Component Tree & Widget Spec — 2048 Flutter

## 1. Widget Tree

```
MaterialApp (ThemeData from AppTheme)
└── GameApp (stateful, manages theme mode)
    ├── MenuScreen
    │   ├── Text("2048")
    │   ├── Text("Best: {bestScore}")
    │   └── ElevatedButton("Play")
    │
    └── GameScreen (ListenableBuilder)
        ├── ScoreBoard
        │   ├── Text("Score: {score}")
        │   └── Text("Best: {bestScore}")
        ├── Row
        │   ├── ElevatedButton("Undo")
        │   ├── ElevatedButton("New Game")
        │   └── IconButton(theme toggle)
        ├── GameBoard (GestureDetector)
        │   └── Stack
        │       ├── GridBackground (Container with rounded corners)
        │       └── ...TileWidget (AnimatedPositioned)
        │           └── Container (colored, Text(value))
        └── GameOverlay (if won || gameOver)
            ├── ColoredBox (semi-transparent)
            ├── Text("You Win!" / "Game Over")
            ├── Text("{score}")
            └── ElevatedButton("Keep Going" / "Try Again")
```

## 2. Widget Responsibilities

### GameApp
- **State:** theme mode (light/dark)
- **Responsibility:** Root widget, manages theme toggle, routes between menu and game.

### MenuScreen
- **Props:** `bestScore: int`, `onPlay: VoidCallback`
- **Responsibility:** Title screen, displays high score, launches game.

### GameScreen
- **Props:** none (owns GameController + GameState via `StatefulWidget`)
- **Responsibility:** Wires controller to child widgets, passes callbacks.

### ScoreBoard
- **Props:** `score: int`, `bestScore: int`
- **Responsibility:** Display current and best scores. Animates score changes.

### GameBoard
- **Props:** `grid: List<List<int?>>`, `onSwipe: DirectionCallback`
- **Responsibility:** Detects swipe gestures, renders background + tiles overlay.

### TileWidget
- **Props:** `value: int?`, `isNew: bool`, `isMerged: bool`
- **Responsibility:** Renders a colored tile with centered number text.

### GameOverlay
- **Props:** `won: bool`, `gameOver: bool`, `score: int`, callbacks
- **Responsibility:** Semi-transparent overlay with result message and action buttons.

## 3. Tile Color Map

| Value | Background | Text |
|-------|-----------|------|
| 2 | #eee4da | #776e65 |
| 4 | #ede0c8 | #776e65 |
| 8 | #f2b179 | #f9f6f2 |
| 16 | #f59563 | #f9f6f2 |
| 32 | #f67c5f | #f9f6f2 |
| 64 | #f65e3b | #f9f6f2 |
| 128 | #edcf72 | #f9f6f2 |
| 256 | #edcc61 | #f9f6f2 |
| 512 | #edc850 | #f9f6f2 |
| 1024 | #edc53f | #f9f6f2 |
| 2048+ | #edc22e | #f9f6f2 |

## 4. Shared Constants

```dart
class GameConstants {
  static const int gridSize = 4;
  static const double gutter = 8.0;
  static const double borderRadius = 6.0;
  static const Duration slideDuration = Duration(milliseconds: 100);
  static const Duration appearDuration = Duration(milliseconds: 120);
  static const double newTileProbability4 = 0.1;
  static const int winValue = 2048;
}
```
