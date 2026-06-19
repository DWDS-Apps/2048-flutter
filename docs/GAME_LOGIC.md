# Game Logic Specification — 2048 Flutter

## 1. Core Algorithm: Slide & Merge

The game board is a `List<List<int?>>` of size 4×4, where `null` represents an empty cell.

### 1.1 Single Row/Column Merge (leftward)

```
Input:  [2, null, 2, 4]
Output: [4, 4, null, null]  (score +4)
```

**Algorithm:**
1. Filter out `null` values → `[2, 2, 4]`
2. Iterate left to right: if two adjacent equal numbers, merge them (double the value, clear the second).
3. Pad with `null`s to length 4.
4. Return `(result, scoreGained, moved)`.

### 1.2 Applying to All Directions

| Swipe | Strategy |
|-------|----------|
| Left  | rows as-is |
| Right | rows reversed → merge → reverse back |
| Up    | columns top→bottom |
| Down  | columns reversed → merge → reverse back |

### 1.3 Pseudo

```dart
MoveResult slide(List<int?> line) {
  // Filter, merge, pad
}

MoveResult handleSwipe(Grid grid, Direction dir) {
  int totalScore = 0;
  bool moved = false;

  for each target line (row or column based on dir):
    extract line values,
    result = slide(line),
    write back values,
    totalScore += result.score,
    moved |= result.moved;

  if (moved) {
    spawnRandomTile(grid);
    checkWin();
    checkGameOver();
  }
}
```

## 2. Random Tile Spawning

1. Collect all empty cells `(r, c)` where `grid[r][c] == null`.
2. If none, return.
3. Pick one random empty cell.
4. Assign value: 90% chance 2, 10% chance 4.

## 3. Win Detection

```dart
bool checkWin(Grid grid) {
  for (r, c in grid) if grid[r][c] == 2048 return true;
  return false;
}
```

## 4. Game Over Detection

```dart
bool isGameOver(Grid grid) {
  for each cell (r, c):
    if grid[r][c] == null → return false;
    if r < 3 and grid[r][c] == grid[r+1][c] → return false;
    if c < 3 and grid[r][c] == grid[r][c+1] → return false;
  return true;
}
```

## 5. Undo

- Before each move, save snapshot: `{ grid: deepCopy, score }`.
- Keep only last 1 snapshot.
- On undo: restore snapshot, clear it.
- Undo disabled when no snapshot exists or game is over.

## 6. Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Swipe with no possible movement | Nothing happens, no new tile |
| Merge cascading (e.g. [2,2,4,4] → left) | [4,8,null,null], score +12 |
| All 2048+ tiles | Display correctly, no overflow |
| Double-tap / fast swipes | Blocked during animation lock (~150ms) |
