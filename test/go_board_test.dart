import 'dart:math';

import 'package:golo/golo.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

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
  });
}
