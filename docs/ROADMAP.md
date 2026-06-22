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
- [x] Sound effects via audioplayers 5.2.1 (swipe, merge, new tile WAVs; dedicated AudioPlayer per sound)

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

## Bugs Fixed (June 2026)
- [x] Fixed missing `package:flutter/foundation.dart` import in GameController (ChangeNotifier)
- [x] Fixed broken test expectations in game_state_test.dart (slideLine merge behavior)
- [x] Fixed broken controller tests — tests now properly set tileIds alongside grid values
- [x] Fixed missing closing parenthesis in game_board.dart GestureDetector widget tree
- [x] Fixed GameOverlay hardcoded light-theme colors — adapts to dark mode now (background, text, buttons)
- [x] Fixed duplicate leaderboard entry on game-over + New Game sequence (added _scoreSavedForCurrentGame flag)
- [x] Fixed game-over detection test to exercise the actual code path (valid move → full board → gameOver=true)
- [x] Fixed `_isNewTilePosition` O(n²) → O(1) with Set lookup for old tile IDs
- [x] Added sound toggle UI button (speaker icon) with persistence in StorageService
- [x] Added Ctrl+Z (undo) and Ctrl+N (new game) keyboard shortcuts for web/desktop
- [x] Removed unused `mergeGroup` field from TileData
- [x] Removed unused `bestScore` prop from ScoreBoard constructor
- [x] Fixed game_board_layout_test.dart record types (double?), closeTo usage, unused variables, and ValueKey type assertion

## Notes
- **Sound effects:** Audioplayers 5.2.1 added via `pub.dev` with assets/sounds/{swipe,merge,new_tile}.wav. Each sound has a dedicated AudioPlayer instance for concurrent playback. Volume levels: swipe 0.5, merge 0.6, new_tile 0.4. Sound can be toggled on/off via speaker icon in the game AppBar; preference persists across restarts.
- **Keyboard shortcuts:** Arrow keys for moves, Ctrl+Z for undo, Ctrl+N for new game (web/desktop).
- **Dart SDK:** 3.6.2 (bundled with Flutter 3.27.4)
