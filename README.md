# golo — Go board logic for Dart
A lightweight, test‑covered package that implements Go (Igo/Weiqi/Baduk) board rules and utilities in pure Dart.

## Examples

### REPL
An interactive REPL is provided for quick testing and demos.

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

The REPL uses the same coordinate system as the library.

### SGF Player
A minimal SGF player that parses an SGF file and lets you step through the main line move-by-move on the console.

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
- Displays the current node’s `Node.data` under the board for quick inspection.
- Honors `SZ` (board size) and initial setup properties `AB`/`AW`/`AE`.

## License
MIT License. Portions adapted from [SabakiHQ/go-board](https://github.com/SabakiHQ/go-board) (MIT) and [SabakiHQ/sgf](https://github.com/SabakiHQ/sgf) (MIT). See `LICENSE` for third‑party notices.
