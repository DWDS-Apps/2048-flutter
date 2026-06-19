# Development Roadmap — 2048 Flutter

## Phase 0: Project Setup (est. 1hr) ✓
- [x] Create PRD, architecture, component, and logic docs.
- [x] `flutter create` in the repo root.
- [x] Set up folder structure.
- [x] Define constants and theme.

## Phase 1: Core Data Model & Game Logic (est. 2-3hr)
- [x] GameState model
- [x] GameController (swipe, spawn, win/game-over, undo, reset)
- [ ] Unit tests

## Phase 2: Static UI (est. 2-3hr)
- [ ] MenuScreen
- [ ] GameBoard with tile rendering
- [ ] TileWidget with color mapping
- [ ] ScoreBoard
- [ ] GameOverlay
- [ ] GameScreen wiring

## Phase 3: Gesture & Animation (est. 2-3hr)
- [ ] Swipe gesture detection
- [ ] Animation lock
- [ ] Tile slide animation
- [ ] Merge pop animation
- [ ] New tile appear animation

## Phase 4: Persistence & Polish (est. 1-2hr)
- [ ] StorageService with SharedPreferences
- [ ] Best score persistence
- [ ] Dark mode toggle
- [ ] Sound effects (optional)

## Phase 5: Nice-to-Have (est. 2-3hr)
- [ ] Board size selector
- [ ] Local leaderboard
- [ ] Keyboard support

## Phase 6: Release Prep (est. 1hr)
- [ ] App icon
- [ ] Physical device testing
- [ ] Platform-specific fixes
- [ ] Final README
