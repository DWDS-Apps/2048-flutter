# Audit & Code Quality Tasks

## [Critical] StorageService uses volatile /tmp path with blocking sync I/O — won't work on mobile

Category: Bug | Missing Feature | Technical Debt

Location:

- lib/services/storage_service.dart:37-58

Problem:

StorageService stores all data (best score, dark mode, leaderboard) at `/tmp/2048_flutter_data/storage.json` using synchronous `File` and `Directory` operations (`existsSync`, `readAsStringSync`, `writeAsStringSync`). On iOS and Android, `/tmp` either doesn't exist at the expected path or is cleared by the OS at any time. Additionally, synchronous I/O blocks the Dart isolate, causing frame drops during save/load operations.

Impact:

- Data (best score, dark mode preference, leaderboard) will be lost between app launches on mobile devices
- UI jank during sync file I/O on the main isolate
- App may crash on mobile when trying to access `/tmp/2048_flutter_data/`

Recommendation:

Replace file-based sync I/O with `shared_preferences` (for simple key-value: best score, dark mode) and a proper path from `path_provider` (for leaderboard JSON). Use the async equivalents of all File operations.

Acceptance Criteria:

- [ ] StorageService uses `SharedPreferences` for best_score and dark_mode keys
- [ ] Leaderboard uses `path_provider` to get app documents directory
- [ ] All file I/O uses async methods (`readAsString`, `writeAsString`, `exists`)
- [ ] Data survives app restart on both Android and iOS

---

## [Critical] Duplicate leaderboard entry saved on game-over + New Game sequence

Category: Bug

Location:

- lib/widgets/game_screen.dart:90-92
- lib/widgets/game_screen.dart:114-118

Problem:

When the game ends (`state.gameOver`), `_handleSwipe` calls `_saveToLeaderboard()` at line 90. If the user then presses "New Game", `_resetGame()` at line 114 also calls `_saveToLeaderboard()` when `state.score > 0`. Since the score hasn't changed between these two calls, the same score gets saved to the leaderboard twice.

Impact:

- Duplicate entries in the leaderboard for the same game
- Players see repeated scores which devalues the leaderboard

Recommendation:

Introduce a flag `_scoreSavedForCurrentGame` that is set to true when saving after game-over. Reset it on `reset()`. Check it before calling `_saveToLeaderboard()` in `_resetGame()`.

Acceptance Criteria:

- [ ] Game-over saves leaderboard entry exactly once
- [ ] New Game button doesn't duplicate the just-finished game's score
- [ ] Leaderboard shows at most one entry per completed game

---

## [Critical] SoundService has no UI control to toggle sound on/off

Category: Missing Feature

Location:

- lib/services/sound_service.dart:18-22
- lib/widgets/game_screen.dart (no sound toggle in AppBar or controls)

Problem:

SoundService has a `setEnabled(bool)` method and `_enabled` field, but there is no way for the user to toggle sound on/off from the UI. Sound plays automatically on every swipe and merge, which can be annoying in quiet environments. There's also no persistence of the sound preference.

Impact:

- User cannot disable sounds without modifying code
- Potentially disruptive in silent environments
- Feature is half-implemented — the plumbing exists but no UI

Recommendation:

Add a small speaker/volume icon button in the GameScreen AppBar (next to the theme toggle) that toggles sound. Persist the preference in StorageService.

Acceptance Criteria:

- [ ] Speaker icon button in GameScreen AppBar toggles sound on/off
- [ ] Preference persists across app restarts
- [ ] Icon visually indicates current state (speaker on/off icon)

---

## [High] GameOverlay uses hardcoded light-theme colors — doesn't adapt to dark mode

Category: Code Quality | Accessibility

Location:

- lib/widgets/game_overlay.dart:27, 35-39, 42-49, 55-72

Problem:

GameOverlay hard-codes `Colors.black.withValues(alpha: 0.5)` for the overlay background, `Colors.white` for text, `Colors.white` for the "New Game" button, and `AppTheme.darkText` for button foregrounds. In dark mode, the overlay should use a dark-mode-appropriate semi-transparent background and the button should match the dark theme palette.

Impact:

- Visual inconsistency in dark mode — overlay stands out as mismatched
- Hard-to-read text/buttons on dark-themed boards

Recommendation:

Read `Theme.of(context).brightness` and use dark-mode-aware colors (e.g. `darkBoardBackground` with adjusted opacity for the overlay background).

Acceptance Criteria:

- [ ] Overlay background color adapts to dark mode (e.g. `Colors.black.withOpacity(0.65)` or themed)
- [ ] Overlay text and button colors adapt to dark mode
- [ ] No hardcoded light-theme colors in the overlay

---

## [High] Unused `mergeGroup` field in TileData

Category: Technical Debt

Location:

- lib/models/game_state.dart:8, 30-37

Problem:

`TileData` declares `final int mergeGroup` (line 8) and includes it in `copyWith` (lines 30-37), but it is never assigned a non-zero value anywhere in the codebase. The `mergeGroup` parameter defaults to `0` in the constructor and is never changed.

Impact:

- Dead code increases cognitive load
- Could confuse future developers into thinking merge grouping is implemented
- Unnecessary serialization cost if `TileData` is ever serialized

Recommendation:

Remove `mergeGroup` field, its parameter, and its handling in `copyWith` unless a concrete use case is planned.

Acceptance Criteria:

- [ ] `mergeGroup` removed from `TileData`
- [ ] `copyWith` no longer references `mergeGroup`
- [ ] No compile errors or test failures after removal

---

## [High] Unused `bestScore` prop in ScoreBoard

Category: Code Quality

Location:

- lib/widgets/score_board.dart:6-7, 11-12

Problem:

`ScoreBoard` accepts both `score` and `bestScore` as constructor parameters (line 6-7, 12), but `bestScore` is never read or used in the widget's build method. It's passed from `GameScreen` line 166 as `ScoreBoard(score: state.bestScore, bestScore: state.bestScore, label: 'Best')` — the same value is used for both params.

Impact:

- Misleading API — future developers may expect `bestScore` to be used
- Dead parameter that should either be used or removed
- Violates Principle of Least Surprise

Recommendation:

Remove `bestScore` from ScoreBoard's constructor. The "Best" label widget simply displays `score` which is already passed.

Acceptance Criteria:

- [ ] `bestScore` parameter removed from `ScoreBoard`
- [ ] Callers updated to not pass `bestScore`
- [ ] Functionality unchanged (Best label still shows the correct value)

---

## [High] Test for game-over detection is incorrect — never actually triggers gameOver

Category: Bug | Testing

Location:

- test/game_controller_test.dart:204-218

Problem:

The test "gameOver triggers when board is full and no merges possible" sets up a full board with no merges, then calls `controller.handleSwipe(Direction.left)`. Because no movement is possible (no null cells, no equal adjacent tiles left-right), `handleSwipe` returns early at line 102 without ever reaching the game-over check at line 117. The test then asserts `controller.state.canMove()` is false — which is true, but it never verifies that `state.gameOver` was actually set to true.

Impact:

- False sense of security — game-over UI won't be tested
- The `state.gameOver` flag is never actually verified in tests
- A regression in game-over detection could go unnoticed

Recommendation:

First make a valid move (e.g. swipe down) to trigger a merge, then set up the no-move board. Or better: manually set a board where a move compacts tiles but leaves no merge possible, so `handleSwipe` passes the "moved" check, reaches the game-over logic, and sets `gameOver = true`. Then assert `expect(controller.state.gameOver, isTrue)`.

Acceptance Criteria:

- [ ] Test correctly triggers `gameOver = true` through `handleSwipe`
- [ ] Test asserts `state.gameOver` directly, not just `canMove()`
- [ ] Test exercises the actual game-over code path

---

## [High] No widget tests for visual components

Category: Testing

Location:

- Entire `test/` directory

Problem:

There are zero widget tests. The `widget_test.dart` only asserts `find.byType(GameApp)`. There are no tests for:
- `GameBoard` rendering tiles correctly
- `TileWidget` displaying correct colors for tile values
- `ScoreBoard` displaying labels and animated scores
- `GameOverlay` showing/hiding on win/game-over
- `MenuScreen` rendering and responding to play button
- `GameScreen` integration with controller

Impact:

- Visual regressions won't be caught
- Animation-related bugs invisible to test suite
- Refactoring UI carries high risk

Recommendation:

Add widget tests for each component, including:
- GameBoard with specific tile layouts
- TileWidget with various values, isNew, isMerged states
- ScoreBoard with score changes
- GameOverlay with won/gameOver/message states
- MenuScreen button callbacks

Acceptance Criteria:

- [ ] GameBoard widget test covers tile rendering with sample grid
- [ ] TileWidget test covers all value ranges and animation flags
- [ ] ScoreBoard test covers score display and "Best" label mode
- [ ] GameOverlay test covers visible/hidden, won, gameOver states
- [ ] MenuScreen test covers button press callback

---

## [Medium] `slideLine` function uses `0` as sentinel for null padding — fragile

Category: Code Quality

Location:

- lib/models/game_state.dart:191-195

Problem:

`slideLine` pads the result with integer `0` (line 191) then maps `0` back to `null` (line 195): `result.map((v) => v == 0 ? null : v).toList()`. If a tile with value `0` ever existed (impossible in 2048 but fragile), this would silently corrupt it.

Impact:

- Fragile sentinel value — works for 2048 but would break with `0` tiles
- Unnecessary conversion step — the result could use `int?` throughout

Recommendation:

Use `int?` for the result list directly, padding with `null` instead of `0`.

Acceptance Criteria:

- [ ] Result list uses `int?` throughout, padded with `null` directly
- [ ] No sentinel-value conversion needed
- [ ] All tests pass

---

## [Medium] `previousScore` tracking in ScoreBoard has stale value on rebuild

Category: Bug

Location:

- lib/widgets/score_board.dart:20-35

Problem:

`ScoreBoard` tracks `_previousScore` in `didUpdateWidget`. If the widget is rebuilt for reasons other than a score change (e.g., theme toggle triggering parent rebuild), `_previousScore` is not updated. However, `didUpdateWidget` only updates `_previousScore` when `oldWidget.score != widget.score`. This is mostly correct but if a component higher in the tree rebuilds and the ScoreBoard's `score` hasn't changed, the tween `IntTween(begin: _previousScore, end: widget.score)` could show a stale `_previousScore` from a previous game.

Impact:

- Cosmetic — score animation could show incorrect start value on rare rebuild patterns

Recommendation:

Reset `_previousScore = widget.score` in the `build` method before the TweenAnimationBuilder, or simply use `score` as both begin and end (remove animation entirely, or use a key on the game session).

Acceptance Criteria:

- [ ] Score animation always shows the correct previous-to-current transition
- [ ] No stale `_previousScore` artifacts

---

## [Medium] `_animating` flag uses `setState` on GameScreen while `ListenableBuilder` handles controller rebuilds — double-render risk

Category: Performance

Location:

- lib/widgets/game_screen.dart:31, 73, 96-97

Problem:

`_handleSwipe` uses both `_animating` (tracked via `setState` at line 73 and 96) and relies on `ListenableBuilder` (line 131-133) which rebuilds the subtree when the controller calls `notifyListeners()`. Every swipe triggers:
1. `_controller.handleSwipe(direction)` → `notifyListeners()` → `ListenableBuilder` rebuilds the Scaffold body
2. `setState(() => _animating = false)` → rebuilds the entire `GameScreen` subtree again

Impact:

- Double rebuild per swipe cycle — unnecessary performance cost
- The entire widget subtree rebuilds twice for every move

Recommendation:

Use a `ValueNotifier<bool>` for `_animating` and an `AnimatedBuilder` or `ValueListenableBuilder` for the animation lock check instead of `setState`. Or, inline the animation lock logic into the `ListenableBuilder` builder by reading `_animating` as a regular field (it still works since `setState` triggers a rebuild of `ListenableBuilder`'s parent).

Acceptance Criteria:

- [ ] `ListenableBuilder` rebuild triggered by controller changes does not cascade into a second rebuild
- [ ] Animation lock still prevents rapid swipes

---

## [Medium] Keyboard "Undo" shortcut (Ctrl+Z) not supported

Category: Missing Feature

Location:

- lib/widgets/game_board.dart:43-63

Problem:

Keyboard arrow keys are supported for swiping, but there is no keyboard shortcut for Undo (Ctrl+Z) or New Game (Ctrl+N). This limits keyboard-only play on web/desktop.

Impact:

- Web/desktop users must click the Undo button instead of using keyboard shortcuts
- Reduces parity between mobile (gesture + button) and desktop (keyboard-only) experiences

Recommendation:

Add `CallbackShortcuts` at the GameScreen level to bind Ctrl+Z to undo and Ctrl+N to new game.

Acceptance Criteria:

- [ ] Ctrl+Z triggers undo on web/desktop
- [ ] Ctrl+N triggers new game
- [ ] Shortcuts only fire when board is focused (no global shortcut conflicts)

---

## [Medium] `_isNewTilePosition` iterates the entire history grid on every tile render — O(n²) per frame

Category: Performance

Location:

- lib/controllers/game_controller.dart:231-247

Problem:

`_isNewTilePosition` is called for each cell in `_syncRenderTiles` (which is called every swipe). Inside it, there's a nested loop over the entire grid (lines 239-243) checking if the tile ID exists in history. For a 4×4 grid this is 16 × 16 = 256 iterations per frame — negligible. But if the grid size is 6×6, it becomes 36 × 36 = 1296. Still small, but the O(n²) pattern is unnecessary.

Impact:

- Minor — negligible for 4×4 but could be optimized as grid sizes grow
- Code smell — linear scan per cell should use a Set lookup

Recommendation:

Build a `Set<int>` of old tile IDs from history once, then use `contains()` for O(1) lookup per cell.

Acceptance Criteria:

- [ ] `_syncRenderTiles` builds a `Set<int>` of old tile IDs once before iterating cells
- [ ] `_isNewTilePosition` uses Set.contains() instead of nested loop
- [ ] Same behavior, faster lookup

---

## [Medium] Dark mode toggle icon shows incorrect state when returning from GameScreen

Category: Bug

Location:

- lib/app.dart:49-54

Problem:

When the user navigates back from GameScreen to MenuScreen and returns to GameScreen, the dark mode toggle icon shows `widget.isDark` which was captured when `GameScreen` was first constructed. But the actual dark mode state might have changed while the screen was active. However, since the theme toggle is passed as a callback to `GameScreen` and the `GameScreen` is not rebuilt by `GameApp` (it's on the Navigator stack), the `isDark` prop is never refreshed until the screen is re-pushed.

Impact:

- The theme toggle icon could show the wrong icon (sun when it should be moon, or vice versa) if the user navigates, changes theme, and the screen isn't rebuilt

Recommendation:

Use a callback that returns the current state: `bool Function() getIsDark` instead of passing a captured `bool`.

Acceptance Criteria:

- [ ] Theme toggle icon always reflects the actual current theme state
- [ ] No stale `isDark` capture

---

## [Low] No loading/error state in MenuScreen for failed best score load

Category: Code Quality | Accessibility

Location:

- lib/widgets/menu_screen.dart:26-28

Problem:

If `_loadBestScore()` fails (e.g., StorageService throws), the error is silently swallowed and the menu shows "Best: 0" forever.

Impact:

- User sees a misleading "Best: 0" even though a real best score exists but failed to load
- No retry mechanism

Recommendation:

Show a brief error state or retry button if score load fails.

Acceptance Criteria:

- [ ] Failed best score load is surfaced to the user (toast or retry button)
- [ ] MenuScreen still renders even if storage fails

---

## [Low] `assets/sounds/` directory contains .wav files — size and format not verified

Category: Performance

Location:

- assets/sounds/merge.wav
- assets/sounds/new_tile.wav
- assets/sounds/swipe.wav

Problem:

Three `.wav` files exist in the assets directory but their content quality, size, and format haven't been verified. Uncompressed WAV files can be large and increase bundle size.

Impact:

- Could bloat app bundle if WAV files are large (>100KB each)
- May fail to play on certain platforms if format isn't widely supported

Recommendation:

Verify WAV file sizes and consider converting to compressed OGG format for better bundle size and cross-platform support.

Acceptance Criteria:

- [ ] Sound files are verified to be playable
- [ ] Sound files are compressed (OGG recommended) to minimize bundle size
- [ ] Total sound assets < 100KB

---

## [Low] GameController uses `dart:math` Random — not seedable for deterministic testing

Category: Testing

Location:

- lib/controllers/game_controller.dart:1, 8

Problem:

`GameController` creates its own `Random` instance (line 8). This is not seedable, which means tests that depend on random tile placement (e.g., checking which empty cell gets the new tile) are non-deterministic and can flake.

Impact:

- Flaky tests if any test depends on random placement
- Hard to debug issues related to tile spawn positions

Recommendation:

Allow injecting a `Random` instance into GameController, defaulting to `Random()` but accepting a seeded `Random(42)` in tests for determinism.

Acceptance Criteria:

- [ ] GameController accepts an optional `Random` parameter in constructor
- [ ] Tests can inject a seeded Random for deterministic tile placement
- [ ] Default constructor behavior unchanged

---

## [Low] Unused imports and dead code

Category: Technical Debt

Location:

- Multiple files

Problem:

Various unused or redundant elements across the codebase:
- `lib/widgets/game_board.dart`: `import '../themes/app_theme.dart'` — `AppTheme` is referenced but could be accessed via Theme.of(context)
- `lib/widgets/tile_widget.dart` line 2: `import '../themes/app_theme.dart'` — used for `AppTheme.tileColor`, `tileFontSize`, `tileTextColor` — all used, so this is fine
- `lib/models/game_state.dart` line 8: `mergeGroup` unused (see High finding)
- `lib/widgets/score_board.dart` line 6-7: `bestScore` unused (see High finding)

Impact:

- Minor — increases code size and cognitive load

Recommendation:

Remove verified dead code. 

Acceptance Criteria:

- [ ] All verified unused imports and declarations removed
- [ ] No behavior change

---
