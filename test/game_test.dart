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
    });
  });
}
