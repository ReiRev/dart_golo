// Interactive REPL example for the golo package, implemented with Game.

import 'dart:io';
import 'package:args/args.dart';
import 'package:golo/golo.dart';

void main(List<String> args) {
  final parser = _buildArgParser();
  late final ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    stderr.writeln('Argument error: $e');
    stderr.writeln();
    stderr.writeln('Use --help to see usage.');
    exitCode = 64; // EX_USAGE
    return;
  }

  if (results['help'] == true) {
    _printCliUsage(parser);
    return;
  }

  final width = int.tryParse(results['width']) ?? 19;
  final height = int.tryParse(results['height']) ?? 19;

  var game = Game(width: width, height: height);

  // Adjust who plays first if requested explicitly; otherwise default is
  // Black, or White when handicap stones were placed.
  final toPlayFlag = results['to-play'] as String?;
  final requested = _parseColor(toPlayFlag ?? '');
  if (requested != null && requested != game.currentPlayer) {
    // Toggle by a pass to switch side.
    game.pass();
  }

  _printWelcome(game);

  while (true) {
    stdout.write(_prompt(game.currentPlayer));
    final line = stdin.readLineSync();
    if (line == null) {
      stdout.writeln('');
      break;
    }

    final input = line.trim();
    if (input.isEmpty) {
      stdout.writeln(game.board);
      continue;
    }

    final parts = input.split(RegExp(r'\s+'));
    final cmd = parts[0].toLowerCase();

    try {
      switch (cmd) {
        case 'help':
        case '?':
          _printHelp();
          break;
        case 'quit':
        case 'exit':
          stdout.writeln('Bye!');
          return;
        case 'show':
        case 'board':
          // Will print after switch
          break;
        case 'captures':
          _printCaptures(game.board);
          break;
        case 'pass':
          game.pass();
          stdout.writeln('Pass.');
          break;
        case 'undo':
          final undone = game.undo();
          if (undone == null) {
            stdout.writeln('Nothing to undo.');
          }
          break;
        case 'new':
        case 'size':
          final dims = _parseDims(parts.skip(1).join(' '));
          if (dims == null) {
            stdout.writeln('Usage: new <N>[x<M>], e.g. new 19 or new 9x13');
          } else {
            game = dims.$2 == null
                ? Game(width: dims.$1)
                : Game(width: dims.$1, height: dims.$2);
            stdout.writeln(
                'Started new ${game.board.width}x${game.board.height} board.');
          }
          break;
        case 'libs':
        case 'lib':
        case 'liberties':
          if (parts.length < 2) {
            stdout.writeln('Usage: libs <coord> (e.g. libs D4)');
            break;
          }
          final v = game.board.parseVertex(parts[1]);
          if (v == null) {
            stdout.writeln('Invalid coordinate: ${parts[1]}');
            break;
          }
          final board = game.board;
          final libs = board
              .getLiberties(v)
              .map(board.stringifyVertex)
              .where((s) => s.isNotEmpty)
              .toList();
          stdout.writeln('Liberties of ${parts[1].toUpperCase()}: '
              '${libs.isEmpty ? '(none)' : libs.join(', ')}');
          break;
        case 'b':
        case 'w':
        case 'play':
        case 'move':
        case 'put':
        case 'place':
          final parsed =
              _parsePlayCommand(cmd, parts, game.board, game.currentPlayer);
          if (parsed == null) {
            _printPlayUsage();
            break;
          }
          // If user forced color different from current, insert a pass to switch.
          final desired = parsed.$1;
          if (desired != game.currentPlayer) {
            game.pass();
          }
          game.play(parsed.$2);
          break;
        default:
          // Bare coordinate like "D4": play for the current player.
          final v = game.board.parseVertex(parts[0]);
          if (v != null) {
            game.play(v);
          } else {
            stdout.writeln('Unknown command. Type `help` for a list.');
          }
      }
    } on IllegalMoveException catch (e) {
      final v = _displayVertex(game.board, e.vertex);
      stdout.writeln('Illegal move: ${e.reason.name} at $v');
    } catch (e) {
      stdout.writeln('Error: $e');
    }

    stdout.writeln(game.board);
  }
}

ArgParser _buildArgParser() => ArgParser()
  ..addOption('width', valueHelp: 'N', help: 'Board width', defaultsTo: '19')
  ..addOption('height', valueHelp: 'M', help: 'Board height', defaultsTo: '19')
  ..addOption('to-play',
      abbr: 't',
      valueHelp: 'b|w',
      help: 'Who plays first',
      allowed: ['b', 'w', 'black', 'white'])
  ..addOption('handicap',
      abbr: 'H', valueHelp: 'N', help: 'Place N handicap stones for Black')
  ..addFlag('tygem', help: 'Use Tygem ordering for handicap', defaultsTo: false)
  ..addFlag('help',
      abbr: 'h', help: 'Show CLI help and exit', negatable: false);

void _printCliUsage(ArgParser parser) {
  stdout.writeln('Go REPL (golo)');
  stdout.writeln('Usage: dart run example/golo_repl.dart [options]');
  stdout.writeln();
  stdout.writeln('Options:');
  stdout.writeln(parser.usage);
  stdout.writeln();
  stdout.writeln('Examples:');
  stdout.writeln('  dart run example/golo_repl.dart --width 19');
  stdout.writeln(
      '  dart run example/golo_repl.dart --width 9 --height 13 -H 4 --tygem');
  stdout.writeln('  dart run example/golo_repl.dart --height 13 --to-play w');
  stdout.writeln();
  stdout.writeln('Note: handicap options are currently ignored.');
  stdout.writeln('Inside the REPL, type `help` for available commands.');
}

// Returns (width, height?) from a string like "19" or "9x13".
(int, int?)? _parseDims(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  final rx = RegExp(r'^(\d+)(?:x(\d+))?$');
  final m = rx.firstMatch(t.toLowerCase());
  if (m == null) return null;
  final w = int.parse(m.group(1)!);
  final h = m.group(2) != null ? int.parse(m.group(2)!) : null;
  return (w, h);
}

// Parse play command and return (stone, vertex) or null.
(Stone, Vertex)? _parsePlayCommand(
  String cmd,
  List<String> parts,
  Board board,
  Stone toPlay,
) {
  Stone? color;
  String? coord;

  if (cmd == 'b' || cmd == 'w') {
    if (parts.length < 2) return null;
    color = cmd == 'b' ? Stone.black : Stone.white;
    coord = parts[1];
  } else {
    if (parts.length < 2) return null;
    final maybeColor = _parseColor(parts[1]);
    if (maybeColor != null) {
      if (parts.length < 3) return null;
      color = maybeColor;
      coord = parts[2];
    } else {
      color = toPlay;
      coord = parts[1];
    }
  }

  final v = board.parseVertex(coord);
  if (v == null) return null;
  return (color, v);
}

Stone? _parseColor(String s) {
  final c = s.toLowerCase();
  if (c == 'b' || c == 'black' || c == 'x') return Stone.black;
  if (c == 'w' || c == 'white' || c == 'o') return Stone.white;
  return null;
}

String _prompt(Stone toPlay) => '[${toPlay == Stone.black ? 'B' : 'W'}] > ';

void _printWelcome(Game game) {
  final board = game.board;
  final tp = game.currentPlayer == Stone.black ? 'B' : 'W';
  stdout.writeln('Go REPL — ${board.width}x${board.height} (to-play: $tp)');
  _printHelp();
  stdout.writeln(board);
}

void _printCaptures(Board board) {
  final b = board.getCaptures(Stone.black);
  final w = board.getCaptures(Stone.white);
  stdout.writeln('Captures — Black: $b, White: $w');
}

void _printHelp() {
  stdout.writeln('Commands:');
  stdout.writeln('  play <coord>           e.g. play D4 (auto turn)');
  stdout.writeln(
      '  b <coord> | w <coord>  e.g. b D4 (forces color by inserting pass)');
  stdout.writeln('  libs <coord>           show liberties of a stone');
  stdout.writeln('  captures               show capture counts');
  stdout.writeln('  pass                   pass and switch turn');
  stdout.writeln('  undo                   revert last move or pass');
  stdout.writeln('  new <N>[x<M>]          start new board');
  stdout.writeln('  show                   print the board');
  stdout.writeln('  help                   show this help');
  stdout.writeln('  quit | exit            leave the REPL');
}

void _printPlayUsage() {
  stdout.writeln('Usage:');
  stdout.writeln('  play <coord>           e.g. play D4');
  stdout.writeln('  b <coord> | w <coord>  e.g. b D4');
  stdout.writeln('  play b <coord>         e.g. play w Q16');
}

String _displayVertex(Board board, Vertex v) {
  final s = board.stringifyVertex(v);
  return s.isEmpty ? '(${v.x},${v.y})' : s;
}
