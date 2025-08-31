# golo — Go board logic for Dart
A lightweight, test‑covered package that implements Go (Igo/Weiqi/Baduk) board rules and utilities in pure Dart.

## Example REPL
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

## Design Notes
- Board stores `state[y][x]` as `Stone?` (`null` = empty).
- `makeMove` clones before applying to keep functional usage simple; `set` mutates for setup/utility scenarios.
- Column “I” is skipped to match SGF/Go software conventions.

## Attribution
- This library is a Dart port inspired by and partially derived from the JavaScript project “@sabaki/go-board” by SabakiHQ:
  https://github.com/SabakiHQ/go-board

## License
- MIT License. Portions adapted from “@sabaki/go-board” (MIT). See `LICENSE` for third‑party notices.

**Attribution**
- This library is a Dart port inspired by and partially derived from the JavaScript project "@sabaki/go-board" by SabakiHQ:
  https://github.com/SabakiHQ/go-board

See the License section for details about third‑party notices.

**License**
- Licensed under the MIT License. This project includes portions adapted from "@sabaki/go-board" (MIT), and the original MIT license and copyright notice are included in `LICENSE`.
