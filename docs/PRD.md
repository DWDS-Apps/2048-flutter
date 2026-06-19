# Product Requirements Document: 2048 Flutter Game

## 1. Overview
A mobile clone of the classic 2048 puzzle game built with Flutter. The goal is to slide numbered tiles on a 4x4 grid, merging matching numbers to reach the 2048 tile.

## 2. Target Platform
- iOS & Android (cross-platform via Flutter)
- Minimum SDK: iOS 13+, Android API 21+

## 3. Core Gameplay
### 3.1 Grid & Tiles
- 4x4 grid populated with numbered tiles.
- Tile values: powers of 2 (2, 4, 8, ..., 2048+).
- Each move spawns one new tile (value 2 with 90% probability, 4 with 10%).

### 3.2 Controls
- Swipe gestures in 4 directions: up, down, left, right.
- Keyboard arrow key support for web/desktop.

### 3.3 Mechanics
- All tiles slide as far as possible in the swiped direction.
- Tiles with the same number merge into one tile with the sum.
- Score increments by the sum of merged tiles each move.
- Game ends when no further moves are possible (grid full and no adjacent equal tiles).
- Winning condition: a tile with value 2048 is created (player can continue playing).

## 4. UI States
| State | Description |
|-------|-------------|
| Menu | Start screen with "Play" button, high score display |
| Playing | Active game grid, current score, best score |
| Won | Congratulations overlay with "Keep Going" / "New Game" |
| Game Over | Final score display, "Try Again" button |

## 5. Features
### 5.1 Must-Have
- Smooth swipe gesture handling with tile animation
- Score tracking (current + best persisted via SharedPreferences)
- Win detection with optional continue-after-win
- Game-over detection and restart
- Undo last move (single level)

### 5.2 Nice-to-Have
- Dark/light theme toggle
- Tile color scheme matching original 2048
- Sound effects on merge/swipe
- Leaderboard (local)
- Board size selector (4x4, 5x5, 6x6)

## 6. Technical Architecture
### 6.1 State Management
Use `ChangeNotifier` + `ValueListenableBuilder` or Riverpod for predictable state.

### 6.2 File Structure
```
lib/
├── main.dart
├── app.dart
├── models/
│   └── game_state.dart       # Grid, tiles, score, move history
├── controllers/
│   └── game_controller.dart  # Game logic, swipe handling, undo
├── widgets/
│   ├── game_board.dart       # 4x4 grid rendering
│   ├── tile_widget.dart      # Individual tile with animations
│   ├── score_board.dart      # Current & best score display
│   └── game_overlay.dart     # Win/game-over overlay
├── services/
│   └── storage_service.dart  # SharedPreferences for high score
└── themes/
    └── app_theme.dart        # Colors, text styles
```

### 6.3 Data Model
```dart
class GameState {
  List<List<int?>> grid;    // 4x4 nullable int grid
  int score;
  int bestScore;
  bool gameOver;
  bool won;
  bool keepPlaying;         // user chose to continue after win
  List<MoveRecord> history; // For undo
}
```

### 6.4 Animation
- Tile movement: 100ms linear interpolation
- Tile merging: 100ms followed by pop-in animation
- New tile: fade-in + scale from 0→1 over 150ms

## 7. Constraints
- No external game engine dependencies.
- Must work offline.
- Performance: 60fps on devices from 2018+.

## 8. Success Metrics
- Build compiles for both iOS and Android.
- All swipe directions behave correctly.
- Score persists across app restarts.
- Undo restores previous state exactly.
- No tile overlap or visual glitches during animation.
