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
