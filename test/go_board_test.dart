import 'package:golo/golo.dart';
import 'package:test/test.dart';

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
  });
}
