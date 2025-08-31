// Interactive REPL example for the golo package.

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

  int width = int.tryParse(results['width']) ?? 19;
  int height = int.tryParse(results['height']) ?? 19;

  var board = Board.fromDimension(width, height);

  var handicap = int.tryParse(results['handicap']) ?? 0;
  final tygem = results['tygem'] == true;
  if (handicap > 0) {
    final spots = board.getHandicapPlacement(handicap, tygem: tygem);
    for (final v in spots) {
      board.set(v, Stone.black);
    }
  }

  final toPlayFlag = results['to-play'] as String?;
  var toPlay = _parseColor(toPlayFlag ?? '') ??
      (handicap > 0 ? Stone.white : Stone.black);

  final history = <Board>[];

  _printWelcome(board, toPlay, handicap: handicap);

  while (true) {
    stdout.write(_prompt(toPlay));
    final line = stdin.readLineSync();
    if (line == null) {
      stdout.writeln('');
      break;
    }

    final input = line.trim();
    if (input.isEmpty) {
      stdout.writeln(board);
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
          // fallthrough to print after switch
          break;
        case 'captures':
          _printCaptures(board);
          break;
        case 'pass':
          history.add(board);
          board = board.copyWith(koInfo: null);
          toPlay = _opponentOf(toPlay);
          stdout.writeln('Pass.');
          break;
        case 'undo':
          if (history.isEmpty) {
            stdout.writeln('Nothing to undo.');
          } else {
            board = history.removeLast();
            toPlay = _opponentOf(toPlay);
          }
          break;
        case 'new':
        case 'size':
          final dims = _parseDims(parts.skip(1).join(' '));
          if (dims == null) {
            stdout.writeln('Usage: new <N>[x<M>], e.g. new 19 or new 9x13');
          } else {
            board = dims.$2 == null
                ? Board.fromDimension(dims.$1)
                : Board.fromDimension(dims.$1, dims.$2);
            toPlay = Stone.black;
            history.clear();
            stdout.writeln('Started new ${board.width}x${board.height} board.');
          }
          break;
        case 'libs':
        case 'lib':
        case 'liberties':
          if (parts.length < 2) {
            stdout.writeln('Usage: libs <coord> (e.g. libs D4)');
            break;
          }
          final v = board.parseVertex(parts[1]);
          if (v == null) {
            stdout.writeln('Invalid coordinate: ${parts[1]}');
            break;
          }
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
          final play = _parsePlayCommand(cmd, parts, board, toPlay);
          if (play == null) {
            _printPlayUsage();
            break;
          }
          history.add(board);
          board = board.makeMove(
            play.$2, // vertex
            play.$1, // stone
            preventOutOfBoard: true,
            preventOverwrite: true,
            preventSuicide: true,
            preventKo: true,
          );
          toPlay = _opponentOf(play.$1);
          break;
        default:
          // If user typed just a coordinate like "D4", treat as auto-turn play.
          final v = board.parseVertex(parts[0]);
          if (v != null) {
            history.add(board);
            board = board.makeMove(
              v,
              toPlay,
              preventOutOfBoard: true,
              preventOverwrite: true,
              preventSuicide: true,
              preventKo: true,
            );
            toPlay = _opponentOf(toPlay);
          } else {
            stdout.writeln('Unknown command. Type `help` for a list.');
          }
      }
    } on IllegalMoveException catch (e) {
      if (history.isNotEmpty) history.removeLast();
      final v = _displayVertex(board, e.vertex);
      stdout.writeln('Illegal move: ${e.reason.name} at $v');
    } catch (e) {
      stdout.writeln('Error: $e');
    }

    stdout.writeln(board);
  }
}

Stone _opponentOf(Stone s) => s == Stone.black ? Stone.white : Stone.black;

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

void _printWelcome(Board board, Stone toPlay, {int handicap = 0}) {
  final tp = toPlay == Stone.black ? 'B' : 'W';
  final extra = handicap > 0 ? ', handicap: $handicap' : '';
  stdout
      .writeln('Go REPL — ${board.width}x${board.height} (to-play: $tp$extra)');
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
  stdout.writeln('  b <coord> | w <coord>  e.g. b D4 (force color)');
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
