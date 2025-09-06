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
  });
}
