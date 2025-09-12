# golo — Go board logic for Dart
Lightweight, well‑tested Go (Igo/Weiqi/Baduk) rules and SGF utilities in pure Dart 3.

## Install

```bash
dart pub add golo
```
Requires Dart SDK >= 3.0.0.

## Quick start

```dart
import 'package:golo/golo.dart';

void main() {
  final game = Game(width: 9); // 9x9

  // Play a few moves
  game.play((x: 2, y: 2));
  game.play((x: 6, y: 6));
  game.pass();

  // Print a snapshot and export to SGF
  print(game.board);       // ASCII board
  print(game.toSgf());     // SGF with size, moves, metadata
}
```

## SGF: read and write

High‑level (recommended):

```dart
import 'package:golo/golo.dart';

// From SGF main line (applies AB/AW/AE setup, reads SZ)
final game = Game.fromSgf('( ;SZ[9] ;B[cc] ;W[gg] ;B[] )');
print(game.board);

// To SGF (pretty parentheses + indentation)
final sgf = game.toSgf();
```

Low‑level tokenizer/parser:

```dart
import 'package:golo/sgf.dart' as sgf;

final tree = sgf.Parser().parse('(;B[hh](;W[ii])(;W[hi]C[h]))');
final root = tree.id < 0 && tree.children.isNotEmpty ? tree.children.first : tree;

// Walk main line
sgf.RecursiveNode? cur = root;
while (cur != null) {
  print(cur.data); // Map<String, List<String>> of SGF props for this node
  cur = cur.children.isNotEmpty ? cur.children.first : null;
}
```

Notes:
- Property identifiers are normalized to upper‑case in the parser.
- Bracket values are unescaped per SGF rules (e.g., `\\]` -> `]`).

## Board API cheatsheet

```dart
final board = Board.fromDimension(19);

// Safe play with rule checks (throws IllegalMoveException on violations)
final after = board.makeMove((x: 3, y: 3), Stone.black,
  preventOutOfBoard: true,
  preventOverwrite: true,
  preventSuicide: true,
  preventKo: true,
);

// Coordinates
board.parseVertex('D16');                 // -> (x: 3, y: 3)
board.stringifyVertex((x: 3, y: 3));      // -> 'D16' (I omitted)

// Analysis helpers
board.getLiberties((x: 3, y: 3));
board.getChain((x: 3, y: 3));
board.getRelatedChains((x: 3, y: 3));
board.isValid();

// Handicap suggestions (star points, Tygem order supported)
board.getHandicapPlacement(4, tygem: true);
```

## Examples

### REPL
Interactive REPL for quick testing and demos.

Run:

```bash
dart run example/golo_repl.dart --help
```

Common options:
- `--width N` and `--height M` (default both 19)
- `--to-play b|w`
- `--handicap N` and `--tygem` ordering

Inside the REPL (type `help`):
- `play D4`, `b D4`, `w Q16`
- `pass`, `undo`, `captures`, `show`
- `new 19` or `new 9x13`

### SGF Player
Console SGF player that steps through the main line.

Run with the bundled Lee Sedol vs AlphaGo SGF:

```bash
dart run example/sgf_player.dart
```

Or provide your own SGF path:

```bash
dart run example/sgf_player.dart path/to/game.sgf
```

Controls:
- Up/Down arrows: step back/forward (TTY environments)
- `j`/`k` + Enter: forward/back (non‑TTY fallback)
- `q`: quit

Details:
- Follows only the first variation (main line); ignores branches.
- Prints `Node.data` under the board for quick inspection.
- Honors `SZ` and root setup `AB`/`AW`/`AE`.

## License
MIT License. Portions adapted from [SabakiHQ/go-board](https://github.com/SabakiHQ/go-board) (MIT) and [SabakiHQ/sgf](https://github.com/SabakiHQ/sgf) (MIT). See `LICENSE` for third‑party notices.
