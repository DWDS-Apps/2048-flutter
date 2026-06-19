# Architecture Document — 2048 Flutter

## 1. State Management

Use **ChangeNotifier + ListenableBuilder** (built-in Flutter, zero dependencies) for predictable uni-directional data flow.

```
User Gesture → GameController.handleSwipe(direction)
                    ↓
              GameState mutated in-place
                    ↓
            notifyListeners() triggers rebuild
                    ↓
         Widgets re-render via ListenableBuilder
```

## 2. Data Flow

```
┌──────────────────┐
│   GameBoard      │ ← ListenableBuilder listens to GameState
│   (widget)       │
└────────┬─────────┘
         │ onSwipe(direction)
         ▼
┌──────────────────┐
│ GameController   │ ← pure Dart, no Flutter dependency
│   .handleSwipe() │
│   .undo()        │
│   .reset()       │
└────────┬─────────┘
         │ mutates
         ▼
┌──────────────────┐
│ GameState        │ ← single source of truth
│ grid, score,     │
│ won, gameOver,   │
│ history[]        │
└────────┬─────────┘
         │ persists
         ▼
┌──────────────────┐
│ StorageService   │ ← SharedPreferences (bestScore)
└──────────────────┘
```

## 3. Rendering Pipeline

1. **GestureDetector** wrapping the board widget processes raw swipe.
2. GameController computes the new grid and returns a **MoveResult**.
3. GameState stores both old and new grid (for animation + undo).
4. **AnimatedPositioned** / custom `TweenAnimationBuilder` drives tile transitions.
5. Each tile is a `StatelessWidget` whose position is computed from row/col.

## 4. Animation System

| Animation | Duration | Curve | Implementation |
|-----------|----------|-------|----------------|
| Tile slide | 100ms | easeInOut | `AnimatedPositioned` on a `Stack` |
| Tile merge (pop) | 80ms | elasticOut | `ScaleTransition` from 1.0→1.15→1.0 |
| New tile appear | 120ms | easeOut | `FadeTransition` + `ScaleTransition` 0→1 |
| Score increment | 200ms | easeInOut | `TweenAnimationBuilder<int>` |

**Key constraint:** During an animation cycle (~150ms), input is blocked to prevent race conditions.

## 5. Persistence Layer

```dart
class StorageService {
  Future<int> loadBestScore();
  Future<void> saveBestScore(int score);
}
```

`bestScore` is saved on every score change.

## 6. Directory Dependency Order

```
themes/  →  services/  →  models/  →  controllers/  →  widgets/  →  main.dart
```

No widget imports a model/controller from a higher layer. Controllers never import widgets.

## 7. Testing Strategy

- **Unit tests** — `GameController` in isolation (all swipe directions, edge cases, undo).
- **Widget tests** — `GameBoard` renders correct tiles, `ScoreBoard` displays values.
- **Integration tests** — Full swipe → animation → new tile flow.
