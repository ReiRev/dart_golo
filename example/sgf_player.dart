// Interactive SGF player: loads an SGF, parses the main line, and
// lets you step through the game with arrow keys (Up = back, Down = forward).

import 'dart:io';

import 'package:golo/golo.dart';
import 'package:golo/sgf.dart' as sgf;

void main(List<String> args) async {
  final defaultPath = 'example/sgf/Lee-Sedol-vs-AlphaGo-20160309.sgf';
  final path = args.isNotEmpty ? args[0] : defaultPath;

  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('SGF file not found: $path');
    exitCode = 2;
    return;
  }

  final text = await file.readAsString();
  final trees = sgf.Parser().parse(text);
  if (trees.isEmpty) {
    stderr.writeln('No SGF game trees found.');
    exitCode = 1;
    return;
  }

  final root = trees.first;

  // Board size (SZ), e.g. 19 or 9:13
  final sizeVals = root.data['SZ'];
  final (width, height) = _parseSize(sizeVals) ?? (19, 19);
  Board board = Board.fromDimension(width, height);

  // Apply setup stones if present (AB/AW/AE) in the root.
  _applySetup(root, board);

  // Extract main line (first-child path), ignoring variations.
  final mainline = _extractMainline(root);

  // Build board states per node (index aligned with mainline).
  final states = <Board>[];
  {
    // state for root
    states.add(board.clone());
    for (var i = 1; i < mainline.length; i++) {
      final node = mainline[i];
      final prev = states.last.clone();
      // Optional setup inside non-root nodes
      _applySetup(node, prev);
      // Apply move if present (B or W). Empty value means pass.
      if (node.data['B'] != null || node.data['W'] != null) {
        final isBlack = node.data['B'] != null;
        final list = node.data[isBlack ? 'B' : 'W']!;
        final coord = list.isNotEmpty ? list.first : '';
        if (coord.isNotEmpty) {
          final v = _vertexFromSgf(coord);
          if (v != null) {
            states.add(prev.makeMove(v, isBlack ? Stone.black : Stone.white));
            continue;
          }
        }
      }
      // Pass or no move: carry forward
      states.add(prev);
    }
  }

  final total = mainline.length; // number of nodes/steps

  void render(int idx) {
    // Clear screen and move cursor home.
    stdout.write('\x1B[2J\x1B[H');
    final header = 'SGF: ${file.path}';
    final stepInfo = 'Node ${idx + 1}/$total';
    stdout.writeln(header);
    stdout.writeln(stepInfo);
    stdout.writeln();
    stdout.writeln(states[idx]);
    // Show Node.data for the current node under the board
    final nodeData = mainline[idx].data;
    if (nodeData.isNotEmpty) {
      stdout.writeln('Node.data: $nodeData');
    }
    stdout.writeln('[Up] Back  [Down] Forward  [Q] Quit');
  }

  // Interactive loop using raw mode for arrow keys.
  final isTty = stdin.hasTerminal;
  final originalEcho = isTty ? stdin.echoMode : null;
  final originalLine = isTty ? stdin.lineMode : null;
  try {
    if (isTty) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    } else {
      stdout.writeln(
          '(Non-interactive input) Type j + Enter (forward), k + Enter (back), q + Enter (quit).');
    }

    var idx = 0;
    render(idx);

    await for (final bytes in stdin) {
      if (bytes.isEmpty) continue;

      // Arrow keys come as ESC [ A/B/C/D. Handle Up/Down; also allow q/Q.
      if (bytes.length >= 3 && bytes[0] == 27 && bytes[1] == 91) {
        final code = bytes[2];
        if (code == 65) {
          // Up
          if (idx > 0) idx--;
          render(idx);
          continue;
        }
        if (code == 66) {
          // Down
          if (idx < total - 1) idx++;
          render(idx);
          continue;
        }
        // Ignore Left/Right or others.
      } else {
        // Single-key fallbacks: 'k' for up, 'j' for down, 'q' to quit.
        final ch = String.fromCharCodes(bytes).toLowerCase();
        if (ch.contains('q')) break;
        if (ch.contains('k')) {
          if (idx > 0) idx--;
          render(idx);
          continue;
        }
        if (ch.contains('j')) {
          if (idx < total - 1) idx++;
          render(idx);
          continue;
        }
      }
    }
  } finally {
    if (isTty) {
      stdin.echoMode = originalEcho!;
      stdin.lineMode = originalLine!;
    }
    stdout.writeln();
  }
}

// Helpers

/// Parse SZ property values to (width, height).
(int, int)? _parseSize(List<String>? values) {
  if (values == null || values.isEmpty) return null;
  final v = values.first.trim();
  if (v.isEmpty) return null;
  if (v.contains(':')) {
    final parts = v.split(':');
    final w = int.tryParse(parts[0]);
    final h = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (w == null || h == null) return null;
    return (w, h);
  }
  final n = int.tryParse(v);
  if (n == null) return null;
  return (n, n);
}

/// Apply AB/AW/AE setup from a node to the board (supports compressed point lists).
void _applySetup(sgf.Node node, Board board) {
  void apply(String key, Stone? stone) {
    final vals = node.data[key];
    if (vals == null) return;
    for (final raw in vals) {
      for (final v in _expandPoint(raw)) {
        if (board.has(v)) board.set(v, stone);
      }
    }
  }

  apply('AB', Stone.black);
  apply('AW', Stone.white);
  apply('AE', null);
}

/// Expand a simple SGF point or compressed point list (e.g. 'aa' or 'aa:cc').
Iterable<Vertex> _expandPoint(String s) sync* {
  final t = s.trim();
  if (t.isEmpty) return;
  if (!t.contains(':')) {
    final v = _vertexFromSgf(t);
    if (v != null) yield v;
    return;
  }
  final parts = t.split(':');
  if (parts.length != 2) return;
  final a = _vertexFromSgf(parts[0]);
  final b = _vertexFromSgf(parts[1]);
  if (a == null || b == null) return;
  final minX = a.x <= b.x ? a.x : b.x;
  final maxX = a.x >= b.x ? a.x : b.x;
  final minY = a.y <= b.y ? a.y : b.y;
  final maxY = a.y >= b.y ? a.y : b.y;
  for (var x = minX; x <= maxX; x++) {
    for (var y = minY; y <= maxY; y++) {
      yield (x: x, y: y);
    }
  }
}

Vertex? _vertexFromSgf(String s) {
  if (s.length < 2) return null; // pass or invalid
  final x = s.codeUnitAt(0) - 97; // 'a' => 0
  final y = s.codeUnitAt(1) - 97;
  return (x: x, y: y);
}

/// Walk first-child chain to collect nodes on the main line.
List<sgf.Node> _extractMainline(sgf.Node root) {
  final list = <sgf.Node>[];
  sgf.Node? cur = root;
  while (cur != null) {
    list.add(cur);
    cur = cur.children.isNotEmpty ? cur.children.first : null;
  }
  return list;
}
