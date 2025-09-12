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
  late final Game game;
  try {
    game = Game.fromSgf(text);
  } catch (e) {
    stderr.writeln('Failed to parse SGF: $e');
    exitCode = 1;
    return;
  }

  // Build board snapshots from Game (nodeId 0..N-1).
  final states = <Board>[];
  for (var i = 0;; i++) {
    try {
      states.add(game.boardAt(i));
    } catch (_) {
      break;
    }
  }

  // Build Node.data list aligned with states (root + each move/pass only).
  final nodeDatas = <Map<String, List<String>>>[];
  try {
    final tree = sgf.Parser().parse(text);
    final root = tree.id < 0 && tree.children.isNotEmpty ? tree.children.first : tree;
    final mainline = _extractMainline(root);
    if (mainline.isNotEmpty) {
      // Root data first
      nodeDatas.add(mainline.first.data);
      for (final n in mainline.skip(1)) {
        final hasMove = n.data.containsKey('B') || n.data.containsKey('W');
        if (hasMove) nodeDatas.add(n.data);
      }
    }
  } catch (_) {
    // Fallback: leave nodeDatas empty; rendering will skip printing node data.
  }

  final total = states.length; // number of nodes/steps

  void render(int idx) {
    // Clear screen and move cursor home.
    stdout.write('\x1B[2J\x1B[H');
    final header = 'SGF: ${file.path}';
    final stepInfo = 'Node ${idx + 1}/$total';
    stdout.writeln(header);
    stdout.writeln(stepInfo);
    stdout.writeln();
    stdout.writeln(states[idx]);
    if (idx < nodeDatas.length && nodeDatas[idx].isNotEmpty) {
      stdout.writeln('Node.data: ${nodeDatas[idx]}');
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

// Walk first-child chain to collect nodes on the main line.
List<sgf.RecursiveNode> _extractMainline(sgf.RecursiveNode root) {
  final list = <sgf.RecursiveNode>[];
  sgf.RecursiveNode? cur = root;
  while (cur != null) {
    list.add(cur);
    cur = cur.children.isNotEmpty ? cur.children.first : null;
  }
  return list;
}
