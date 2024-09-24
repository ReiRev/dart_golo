import 'package:golo/src/coordinate_status.dart';
import 'package:golo/src/player.dart';
import 'package:golo/src/board_state.dart';
import 'package:test/test.dart';

void main() {
  group('Board State', () {
    for (Player initialPlayer in [Player.black, Player.white]) {
      group('when initial player is $initialPlayer', () {
        test('Remove a center stone', () {
          final BoardState boardState = BoardState(boardSize: 3);
          boardState.play(initialPlayer, boardState.loc(1, 1));

          boardState.play(initialPlayer.opponent, boardState.loc(0, 1));
          boardState.play(initialPlayer.opponent, boardState.loc(1, 0));
          boardState.play(initialPlayer.opponent, boardState.loc(1, 2));
          boardState.play(initialPlayer.opponent, boardState.loc(2, 1));

          expect(
            boardState.flattenedBoard[boardState.loc(1, 1)],
            CoordinateStatus.empty,
          );
        });

        test('Remove a corner stone', () {
          final BoardState boardState = BoardState(boardSize: 3);
          boardState.play(initialPlayer, boardState.loc(0, 0));

          boardState.play(initialPlayer.opponent, boardState.loc(0, 1));
          boardState.play(initialPlayer.opponent, boardState.loc(1, 0));

          expect(boardState.flattenedBoard[boardState.loc(0, 0)],
              CoordinateStatus.empty);
        });

        test('Remove a stone on a wall', () {
          final BoardState boardState = BoardState(boardSize: 3);
          boardState.play(initialPlayer, boardState.loc(1, 0));

          boardState.play(initialPlayer.opponent, boardState.loc(0, 0));
          boardState.play(initialPlayer.opponent, boardState.loc(1, 1));
          boardState.play(initialPlayer.opponent, boardState.loc(2, 0));

          expect(boardState.flattenedBoard[boardState.loc(1, 0)],
              CoordinateStatus.empty);
        });
      });
    }
  });
}
