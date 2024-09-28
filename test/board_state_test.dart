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
          // .  .  .
          // .  ○  .
          // .  .  .
          boardState.play(initialPlayer, 1, 1);

          // .  ●   .
          // ●  ○  ●
          // .  ●  .
          boardState.play(initialPlayer.opponent, 0, 1);
          boardState.play(initialPlayer.opponent, 1, 0);
          boardState.play(initialPlayer.opponent, 1, 2);
          boardState.play(initialPlayer.opponent, 2, 1);

          expect(
            boardState.at(1, 1),
            CoordinateStatus.empty,
          );
        });

        test('Remove a corner stone', () {
          final BoardState boardState = BoardState(boardSize: 3);
          // ○  .  .
          // .  .  .
          // .  .  .
          boardState.play(initialPlayer, 0, 0);

          // ○  ●  .
          // ●  .  .
          // .  .  .
          boardState.play(initialPlayer.opponent, 0, 1);
          boardState.play(initialPlayer.opponent, 1, 0);

          expect(
            boardState.at(0, 0),
            CoordinateStatus.empty,
          );
        });

        test('Remove a stone on a wall', () {
          final BoardState boardState = BoardState(boardSize: 3);
          // .  ○  .
          // .  .  .
          // .  .  .
          boardState.play(initialPlayer, 1, 0);

          // ●  ○  ●
          // .  ●  .
          // .  .  .
          boardState.play(initialPlayer.opponent, 0, 0);
          boardState.play(initialPlayer.opponent, 1, 1);
          boardState.play(initialPlayer.opponent, 2, 0);

          expect(
            boardState.at(1, 0),
            CoordinateStatus.empty,
          );
        });

        test('Remove multiple stones', () {
          final BoardState boardState = BoardState(boardSize: 3);
          // ●  ○  .
          // ●  ○  .
          // ●  .  .
          boardState.play(initialPlayer, 0, 0);
          boardState.play(initialPlayer, 0, 1);
          boardState.play(initialPlayer, 0, 2);

          boardState.play(initialPlayer.opponent, 1, 0);
          boardState.play(initialPlayer.opponent, 1, 1);
          boardState.play(initialPlayer.opponent, 1, 2);

          expect(
            boardState.at(0, 0),
            CoordinateStatus.empty,
          );
          expect(
            boardState.at(0, 1),
            CoordinateStatus.empty,
          );
          expect(
            boardState.at(0, 2),
            CoordinateStatus.empty,
          );
        });
      });
    }
  });
}
