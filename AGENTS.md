# golo — agent instructions

Pure Dart 3 library implementing Go (Igo/Weiqi/Baduk) rules and SGF
parsing/serialization. No runtime dependencies. Published on pub.dev as `golo`.

## Commands

- Test: `dart test` (single file: `dart test test/<file>.dart`)
- Static analysis: `dart analyze` — must report zero issues (`package:lints/recommended`)
- Format: `dart format .` — run before committing

## Layout

- `lib/golo.dart`, `lib/sgf.dart` — public entry points
- `lib/src/` — implementation (board, game, node, board_tree, sgf/)
- `test/` — mirrors `lib/src/`; shared fixtures in `test/data.dart`
- `example/` — REPL and SGF player demos

## Conventions

- Keep `lib/` free of runtime dependencies (pure Dart; `dev_dependencies` only).
- Public APIs need `///` doc comments in English.
- Vertices are records `(x: int, y: int)`; follow existing API style.
- Breaking public API changes require a `CHANGELOG.md` entry.
- Portions adapted from SabakiHQ projects (MIT) — keep `LICENSE` notices intact.

## Workflow (orchestration)

For non-trivial changes, the main session acts as orchestrator: follow
`agents/orchestrator.md` (plan → implementer → reviewer loop; roles in
`agents/`). Done = `dart analyze` clean + `dart test` passes + review
approved.
