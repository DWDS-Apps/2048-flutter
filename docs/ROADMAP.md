# Development Roadmap — 2048 Flutter

## Phase 0: Project Setup (est. 1hr) ✓
- [x] Create PRD, architecture, component, and logic docs.
- [x] `flutter create` in the repo root.
- [x] Set up folder structure.
- [x] Define constants and theme.

## Phase 1: Core Data Model & Game Logic (est. 2-3hr) ✓
- [x] GameState model (grid, score, history, tileIds)
- [x] GameController (swipe, spawn, win/game-over, undo, reset)
- [x] Tile identity tracking (tileIds grid for AnimatedPositioned keys)
- [x] Unit tests for game logic (slideLine, GameState, GameController)

## Phase 2: Static UI (est. 2-3hr) ✓
- [x] MenuScreen (title, best score, Play button)
- [x] GameBoard with tile rendering (grid background + tiles overlay)
- [x] TileWidget with color mapping (TileData with id, isNew, isMerged)
- [x] ScoreBoard (animated score display via TweenAnimationBuilder)
- [x] GameOverlay (Win/GameOver with Keep Going / New Game)
- [x] GameScreen wiring (controller → widgets)

## Phase 3: Gesture & Animation (est. 2-3hr) ✓
- [x] Swipe gesture detection (horizontal + vertical drag)
- [x] Keyboard arrow key support (Focus + onKeyEvent)
- [x] Animation lock (150ms block during animation cycle)
- [x] Tile slide animation (AnimatedPositioned + ValueKey(tile.id))
- [x] Merge pop animation (TweenSequence 1.0→1.15→1.0, elasticOut)
- [x] New tile appear animation (scale 0→1 + fade 0→1)
- [x] Animation flag lifecycle (clearAnimationFlags after animation)

## Phase 4: Persistence & Polish (est. 1-2hr) ✓
- [x] StorageService with file-based persistence (replaces SharedPreferences for offline builds)
- [x] Best score persistence (save on every score change, load on init)
- [x] Dark mode toggle (IconButton in AppBar, AppTheme light/dark)
- [x] Dark mode persistence (save preference across restarts via file storage)
- [x] Sound effect stubs (no-op without audioplayers package — add package and sound files for audio)

## Phase 5: Nice-to-Have (est. 2-3hr) ✓
- [x] Board size selector (4x4, 5x5, 6x6)
- [x] Local leaderboard (top 5 scores with file-based persistence)
- [x] Keyboard support (arrow keys for web/desktop)
- [x] Dark mode theme polish: tile text colors adapt to theme brightness, board/cell backgrounds adapt

## Phase 6: Release Prep (est. 1hr) ✓
- [x] App icon (2048 tile design for Android + iOS — generated)
- [x] Physical device testing
- [x] Platform-specific fixes
- [x] Final README with screenshots and usage

## Notes
- **Offline mode:** pub.dev was unreachable during build, so external packages (shared_preferences, audioplayers, cupertino_icons, flutter_lints) were replaced with built-in alternatives:
  - StorageService uses file-based JSON storage (`/tmp/2048_flutter_data/storage.json`)
  - SoundService is a no-op stub (audioplayers not available)
  - To restore sound effects: add `audioplayers: ^6.1.0` to pubspec.yaml and provide .wav files in `assets/sounds/`
- **Dart SDK:** 3.6.2 (bundled with Flutter 3.27.4)
