## 1.0.2

- Game: add `depth` (max depth), `currentDepth`, `parentOf`, and `depthOf` helpers.
- Game: `remove({nodeId, includeSelf})` can now keep a node while clearing descendants and still guards against removing the root.
- SgfTree: add `depth`, `currentDepth`, and `depthOf(id)` helpers mirroring the Game API.
- Tests: extend coverage for depth helpers and removal options.

## 1.0.1

- Game: add `remove({nodeId})` to delete a node or truncate from root.
- SgfTree: add `removeFrom(id, {includeSelf})` for recursive deletion.
- Game: add navigation helpers `goNext`, `goAt` (variation index), `goBack`, `goSibling`.
- Game: `currentPlayer` is now computed from the last move (no mutable state).
- Tests: add coverage for removal and navigation; minor assertions tightened.

## 1.0.0

- Breaking: Renamed and consolidated core APIs.
  - Coordinates now use `Vertex` record (`({int x, int y})`). Many method
    signatures changed (e.g., `Board.get/has/set`, `Game.play`, `Node` helpers).
  - `Board.makeMove` is now pure and returns a new `Board` instead of mutating
    in place; it throws `IllegalMoveException` with an `IllegalMoveReason`.
  - `BoardTree` returns cloned snapshots from `[]` and stores clones on `[]=`;
    snapshots should be treated as immutable.
  - `SgfTree`/`Node`: Node IDs are non-null `int`; `get`/`set` helpers live on
    `Node` (moved from tree-level usage). Node `data` shape is
    `Map<String, List<String>>`.
  - SGF writer filters to uppercase property identifiers; lower-case custom
    keys are no longer emitted unless uppercase.

- Added: High-level `Game` API with SGF I/O and history.
  - `Game.play`, `Game.pass`, `Game.undo`, `Game.boardAt`.
  - Root metadata helpers (e.g., `rule`, `application`, `players`, `result`,
    `komi`, `handicap`, etc.).
  - `Game.toSgf()` and `Game.fromSgf()` (imports main line, applies setup).

- Added: SGF tokenizer and parser.
  - `sgf.Token`, `sgf.TokenIterator`, `sgf.Parser`, `sgf.RecursiveNode`.
  - Parser normalizes property identifiers to uppercase and unescapes SGF values.
  - Example: `example/sgf_player.dart` (interactive mainline navigator).

- Added: Board utilities and rule enforcement.
  - `IllegalMoveException` + `IllegalMoveReason` (overwrite/ko/suicide/outOfBoard).
  - `getLiberties`, `getChain`, `getNeighbors`, `getRelatedChains`, `isValid`.
  - `copyWith`, `clone`, `diff`, `parseVertex`, `stringifyVertex`.
  - `getHandicapPlacement` (Tygem ordering supported via flag).

- Changed: SGF serialization.
  - Pretty parentheses + indentation; only uppercase property IDs are written.

- Docs/Examples: Added `example/golo_repl.dart`, updated README and LICENSE.

Migration notes
- Replace any previous point type with `Vertex`: `(x: x, y: y)`.
- Update uses of `Board.makeMove(...)` to handle the returned board (do not
  rely on mutation) and catch `IllegalMoveException` as needed.
- Treat `BoardTree` snapshots as immutable; write back via `tree[id] = board`.
- If you relied on lower-case SGF properties, use uppercase identifiers.

## 0.0.1

- Initial version.
