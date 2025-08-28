// ignore_for_file: lines_longer_than_80_chars
import 'package:golo/golo.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';
import './data.dart' as data;

void main() {
  group('GoBoard', () {
    group('constructor', () {
      test('creates board', () {
        final board = GoBoard([
          [null, null, null],
          [null, null, null]
        ]);
        expect(board.width, 3);
        expect(board.height, 2);

        for (var x = 0; x < board.width; x++) {
          for (var y = 0; y < board.height; y++) {
            expect(board.get(x, y), null);
          }
        }

        expect(board.getCaptures(GoStone.black), 0);
        expect(board.getCaptures(GoStone.white), 0);
      });

      test('throws error with un-uniform board size', () {
        expect(
            () => GoBoard([
                  [null, null, null],
                  [null, null],
                  [null, null, null]
                ]),
            throwsA(isA<ArgumentError>()));
      });
    });

    group('creates board from dimension', () {
      test('with width and height', () {
        final board = GoBoard.fromDimension(5, 4);
        expect(board.width, 5);
        expect(board.height, 4);
      });

      test('with width', () {
        final board = GoBoard.fromDimension(5);
        expect(board.width, 5);
        expect(board.height, 5);
      });
    });

    group('has', () {
      test('should return true when vertex is on board', () {
        final board = GoBoard.fromDimension(19);
        expect(board.has(0, 0), true);
        expect(board.has(13, 18), true);
        expect(board.has(5, 4), true);
      });

      test('should return false when vertex is not on board', () {
        final board = GoBoard.fromDimension(19);
        expect(board.has(-1, -1), false);
        expect(board.has(5, -1), false);
        expect(board.has(board.width, 0), false);
        expect(board.has(board.width, board.height), false);
      });
    });

    test('clear', () {
      final board = GoBoard.fromDimension(9, 9);
      board
          .set(0, 0, GoStone.black)
          .set(1, 1, GoStone.white)
          .set(3, 5, GoStone.black);
      board.clear();
      expect(
          DeepCollectionEquality()
              .equals(board.state, GoBoard.fromDimension(9, 9).state),
          true);
    });

    //   group('makeMove', () {
    //     test('should not mutate board', () {
    //       final board = GoBoard.fromDimension(19);
    //       board.makeMove(5, 5, GoStone.black);

    //       expect(
    //           DeepCollectionEquality()
    //               .equals(board.state, GoBoard.fromDimension(19).state),
    //           true);
    //     });

    //     test('should make a move', () {
    //       final board = GoBoard.fromDimension(19);
    //       final move = board.makeMove(5, 5, GoStone.black);
    //       board.set(5, 5, GoStone.black);

    //       expect(DeepCollectionEquality().equals(board.state, move.state), true);
    //     });

    //     test('should remove captured stones', () {
    //       final board = GoBoard.fromDimension(19);
    //       const black = [
    //         [0, 1],
    //         [GoStone.black, 0],
    //         [GoStone.black, 2],
    //         [2, 0],
    //         [2, 2]
    //       ];
    //       const white = [
    //         [GoStone.black, 1],
    //         [2, 1]
    //       ];

    //       for (var xy in black) {
    //         board.set(xy[0], xy[1], GoStone.black);
    //       }
    //       for (var xy in white) {
    //         board.set(xy[0], xy[1], GoStone.white);
    //       }

    //       final move = board.makeMove(3, GoStone.black, GoStone.black);

    //       expect(move.get(3, 1), GoStone.black);
    //       for (var xy in black) {
    //         expect(move.get(xy[0], xy[1]), GoStone.black);
    //       }
    //       for (var xy in white) {
    //         expect(move.get(xy[0], xy[1]), null);
    //       }
    //     });
    //   });

    test('isSquare', () {
      final board = GoBoard.fromDimension(15, 16);
      expect(board.isSquare(), false);

      expect(data.board.isSquare(), true);
    });

    test('isEmpty', () {
      final board = GoBoard.fromDimension(15, 16);
      expect(board.isEmpty(), true);

      expect(data.board.isEmpty(), false);
    });
  });
}
