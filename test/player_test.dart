import 'package:golo/src/coordinate_status.dart';
import 'package:golo/src/player.dart';
import 'package:test/test.dart';

void main() {
  group('Player', () {
    test('comparison', () {
      expect(Player.black == Player.black, isTrue);
      expect(CoordinateStatus.black == Player.black, isTrue);
      expect(Player.black == CoordinateStatus.black, isTrue);

      expect(Player.white == Player.white, isTrue);
      expect(CoordinateStatus.white == Player.white, isTrue);
      expect(Player.white == CoordinateStatus.white, isTrue);
    });

    test('opponent', () {
      expect(Player.black.opponent, Player.white);
      expect(Player.white.opponent, Player.black);
    });
  });
}
