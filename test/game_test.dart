import 'package:golo/golo.dart';
import 'package:test/test.dart';

void main() {
  group('Board State', () {
    for (Player initialPlayer in [Player.black, Player.white]) {
      group('when initial player is $initialPlayer', () {
        test('Remove a center stone', () {
          final game = Game(boardSize: 3);
          // .  .  .
          // .  ○  .
          // .  .  .
          game.play(initialPlayer, 1, 1);

          // .  ●   .
          // ●  ○  ●
          // .  ●  .
          game.play(initialPlayer.opponent, 0, 1);
          game.play(initialPlayer.opponent, 1, 0);
          game.play(initialPlayer.opponent, 1, 2);
          game.play(initialPlayer.opponent, 2, 1);

          expect(
            game.boardState.at(1, 1),
            CoordinateStatus.empty,
          );
        });

        test('Remove a corner stone', () {
          final game = Game(boardSize: 3);
          // ○  .  .
          // .  .  .
          // .  .  .
          game.play(initialPlayer, 0, 0);

          // ○  ●  .
          // ●  .  .
          // .  .  .
          game.play(initialPlayer.opponent, 0, 1);
          game.play(initialPlayer.opponent, 1, 0);

          expect(
            game.boardState.at(0, 0),
            CoordinateStatus.empty,
          );
        });

        test('Remove a stone on a wall', () {
          final game = Game(boardSize: 3);
          // .  ○  .
          // .  .  .
          // .  .  .
          game.play(initialPlayer, 1, 0);

          // ●  ○  ●
          // .  ●  .
          // .  .  .
          game.play(initialPlayer.opponent, 0, 0);
          game.play(initialPlayer.opponent, 1, 1);
          game.play(initialPlayer.opponent, 2, 0);

          expect(
            game.boardState.at(1, 0),
            CoordinateStatus.empty,
          );
        });

        test('Remove multiple stones', () {
          final game = Game(boardSize: 3);
          // ●  ○  .
          // ●  ○  .
          // ●  .  .
          game.play(initialPlayer, 0, 0);
          game.play(initialPlayer, 0, 1);
          game.play(initialPlayer, 0, 2);

          game.play(initialPlayer.opponent, 1, 0);
          game.play(initialPlayer.opponent, 1, 1);
          game.play(initialPlayer.opponent, 1, 2);

          expect(
            game.boardState.at(0, 0),
            CoordinateStatus.empty,
          );
          expect(
            game.boardState.at(0, 1),
            CoordinateStatus.empty,
          );
          expect(
            game.boardState.at(0, 2),
            CoordinateStatus.empty,
          );
        });
      });
    }
  });
}
