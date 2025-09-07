import 'package:test/test.dart';
import 'package:golo/golo.dart';

void main() {
  group('Game', () {
    group('constructor', () {
      test("creates a board default width and height", () {
        final game = Game();
        final board = game.board;
        expect(board.width, 19);
        expect(board.height, 19);
        expect(
          board.state.every(
            (row) => row.every((cell) => cell == null),
          ),
          true,
        );
      });
    });

    group('SGF meta data', () {
      test('defaults are initialized', () {
        final game = Game();

        expect(game.application, 'Dart Golo');
        expect(game.charset, 'UTF-8');

        expect(game.rule, null);
        expect(game.event, null);
        expect(game.round, null);
        expect(game.place, null);
        expect(game.date, null);
        expect(game.name, null);
        expect(game.comment, null);
        expect(game.annotator, null);
        expect(game.copyright, null);
        expect(game.source, null);
        expect(game.result, null);
        expect(game.komi, null);
        expect(game.handicap, null);
        expect(game.overtime, null);
        expect(game.time, null);
        expect(game.byoYomiPeriods, null);
        expect(game.byoYomiLength, null);
        expect(game.playerBlack, null);
        expect(game.playerWhite, null);
        expect(game.blackRank, null);
        expect(game.whiteRank, null);
        expect(game.blackTeam, null);
        expect(game.whiteTeam, null);
        expect(game.blackCountry, null);
        expect(game.whiteCountry, null);
      });

      test('(set|get) game info', () {
        final game = Game();

        game.rule = 'Japanese';
        game.event = 'Example Cup';
        game.round = 'Game 1';
        game.place = 'Seoul, Korea';
        game.date = '2024-09-01';
        game.name = 'Final Match';
        game.comment = 'Exciting game.';
        game.annotator = 'Analyst';
        game.copyright = 'Example Org';
        game.source = 'https://example.com';
        game.result = 'W+R';
        game.komi = '7.5';
        game.handicap = '2';
        game.overtime = '3x60 byo-yomi';
        game.time = '7200';
        game.byoYomiPeriods = '3';
        game.byoYomiLength = '60';
        game.playerBlack = 'Lee Sedol';
        game.playerWhite = 'AlphaGo';
        game.blackRank = '9d';
        game.whiteRank = '9d';
        game.blackTeam = 'Human';
        game.whiteTeam = 'Computer';
        game.blackCountry = 'KR';
        game.whiteCountry = 'UK';

        expect(game.rule, 'Japanese');
        expect(game.event, 'Example Cup');
        expect(game.round, 'Game 1');
        expect(game.place, 'Seoul, Korea');
        expect(game.date, '2024-09-01');
        expect(game.name, 'Final Match');
        expect(game.comment, 'Exciting game.');
        expect(game.annotator, 'Analyst');
        expect(game.copyright, 'Example Org');
        expect(game.source, 'https://example.com');
        expect(game.result, 'W+R');
        expect(game.komi, '7.5');
        expect(game.handicap, '2');
        expect(game.overtime, '3x60 byo-yomi');
        expect(game.time, '7200');
        expect(game.byoYomiPeriods, '3');
        expect(game.byoYomiLength, '60');
        expect(game.playerBlack, 'Lee Sedol');
        expect(game.playerWhite, 'AlphaGo');
        expect(game.blackRank, '9d');
        expect(game.whiteRank, '9d');
        expect(game.blackTeam, 'Human');
        expect(game.whiteTeam, 'Computer');
        expect(game.blackCountry, 'KR');
        expect(game.whiteCountry, 'UK');

        game.rule = null;
        game.event = null;
        game.round = null;
        game.place = null;
        game.date = null;
        game.name = null;
        game.comment = null;
        game.annotator = null;
        game.copyright = null;
        game.source = null;
        game.result = null;
        game.komi = null;
        game.handicap = null;
        game.overtime = null;
        game.time = null;
        game.byoYomiPeriods = null;
        game.byoYomiLength = null;
        game.playerBlack = null;
        game.playerWhite = null;
        game.blackRank = null;
        game.whiteRank = null;
        game.blackTeam = null;
        game.whiteTeam = null;
        game.blackCountry = null;
        game.whiteCountry = null;

        expect(game.rule, null);
        expect(game.event, null);
        expect(game.round, null);
        expect(game.place, null);
        expect(game.date, null);
        expect(game.name, null);
        expect(game.comment, null);
        expect(game.annotator, null);
        expect(game.copyright, null);
        expect(game.source, null);
        expect(game.result, null);
        expect(game.komi, null);
        expect(game.handicap, null);
        expect(game.overtime, null);
        expect(game.time, null);
        expect(game.byoYomiPeriods, null);
        expect(game.byoYomiLength, null);
        expect(game.playerBlack, null);
        expect(game.playerWhite, null);
        expect(game.blackRank, null);
        expect(game.whiteRank, null);
        expect(game.blackTeam, null);
        expect(game.whiteTeam, null);
        expect(game.blackCountry, null);
        expect(game.whiteCountry, null);
      });

      test('(set|get) player info', () {
        final game = Game();

        game.playerBlack = 'B';
        game.playerWhite = 'W';
        game.blackRank = '1k';
        game.whiteRank = '2k';
        game.blackTeam = 'TeamB';
        game.whiteTeam = 'TeamW';
        game.blackCountry = 'KR';
        game.whiteCountry = 'JP';

        expect(game.playerBlack, 'B');
        expect(game.playerWhite, 'W');
        expect(game.blackRank, '1k');
        expect(game.whiteRank, '2k');
        expect(game.blackTeam, 'TeamB');
        expect(game.whiteTeam, 'TeamW');
        expect(game.blackCountry, 'KR');
        expect(game.whiteCountry, 'JP');

        game.playerBlack = null;
        game.playerWhite = null;
        game.blackRank = null;
        game.whiteRank = null;
        game.blackTeam = null;
        game.whiteTeam = null;
        game.blackCountry = null;
        game.whiteCountry = null;

        expect(game.playerBlack, null);
        expect(game.playerWhite, null);
        expect(game.blackRank, null);
        expect(game.whiteRank, null);
        expect(game.blackTeam, null);
        expect(game.whiteTeam, null);
        expect(game.blackCountry, null);
        expect(game.whiteCountry, null);
      });
    });

    group('play', () {
      test('advances board and alternates turns', () {
        final game = Game();
        expect(game.currentPlayer, Stone.black);

        final v1 = (x: 3, y: 3);
        game.play(v1);
        var board = game.board;
        expect(board.get(v1), Stone.black);
        expect(game.currentPlayer, Stone.white);

        final v2 = (x: 4, y: 3);
        game.play(v2);
        board = game.board;
        expect(board.get(v2), Stone.white);
        expect(game.currentPlayer, Stone.black);
      });

      test('prevents overwrite on same vertex', () {
        final game = Game();
        final v = (x: 10, y: 10);
        game.play(v);
        expect(
          () => game.play(v),
          throwsA(predicate((e) =>
              e is IllegalMoveException &&
              e.reason == IllegalMoveReason.overwrite)),
        );
      });

      test('throws outOfBoard for moves outside', () {
        final game = Game();
        expect(
          () => game.play((x: 19, y: 0)),
          throwsA(predicate((e) =>
              e is IllegalMoveException &&
              e.reason == IllegalMoveReason.outOfBoard)),
        );
        expect(
          () => game.play((x: -1, y: 0)),
          throwsA(predicate((e) =>
              e is IllegalMoveException &&
              e.reason == IllegalMoveReason.outOfBoard)),
        );
      });

      test('throws suicide when filling own last liberty', () {
        final game = Game();

        // Surround (10,10) with White stones on four sides.
        game.pass(); // W to play
        game.play((x: 9, y: 10)); // W
        game.pass(); // B passes, W again
        game.play((x: 11, y: 10)); // W
        game.pass();
        game.play((x: 10, y: 9)); // W
        game.pass();
        game.play((x: 10, y: 11)); // W

        // Now Black attempts to play at (10,10) which is suicide.
        expect(
          () => game.play((x: 10, y: 10)),
          throwsA(predicate((e) =>
              e is IllegalMoveException &&
              e.reason == IllegalMoveReason.suicide)),
        );
      });

      test('throws ko on immediate recapture', () {
        final game = Game();

        // Set up classic single-stone ko around (10,10) with last liberty at (10,9).
        game.pass(); // W to play
        game.play((x: 10, y: 10)); // W center stone to be captured in ko
        game.play((x: 9, y: 10)); // B
        game.play((x: 9, y: 9)); // W
        game.play((x: 11, y: 10)); // B
        game.play((x: 11, y: 9)); // W
        game.play((x: 10, y: 11)); // B
        game.play((x: 10, y: 8)); // W

        // Black captures at (10,9), creating ko at (10,10).
        game.play((x: 10, y: 9)); // B capture -> ko

        // White immediate recapture at (10,10) is forbidden by ko.
        expect(
          () => game.play((x: 10, y: 10)),
          throwsA(predicate((e) =>
              e is IllegalMoveException && e.reason == IllegalMoveReason.ko)),
        );
      });
    });

    group('boardAt', () {
      test('returns root snapshot for nodeId 0', () {
        final game = Game();
        final rootBoard = game.boardAt(0);
        expect(rootBoard.width, 19);
        expect(rootBoard.height, 19);
        expect(rootBoard.isEmpty(), true);
      });

      test('returns immutable snapshots for each move', () {
        final game = Game();
        final b1 = (x: 3, y: 3);
        final w1 = (x: 4, y: 3);

        game.play(b1); // nodeId 1
        var snap1 = game.boardAt(1);
        expect(snap1.get(b1), Stone.black);
        expect(snap1.get(w1), isNull);

        game.play(w1); // nodeId 2
        var snap2 = game.boardAt(2);
        expect(snap2.get(b1), Stone.black);
        expect(snap2.get(w1), Stone.white);

        // Ensure snapshot at node 1 is unchanged by later moves.
        snap1 = game.boardAt(1);
        expect(snap1.get(b1), Stone.black);
        expect(snap1.get(w1), isNull);
      });
    });
  });
}
