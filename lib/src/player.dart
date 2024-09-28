import 'base_status.dart';

class Player extends BaseStatus {
  static const Player black = Player._(1);
  static const Player white = Player._(2);

  const Player._(super.value);

  Player get opponent => this == black ? white : black;

  @override
  String toString() {
    return this == black ? 'black' : 'white';
  }
}
