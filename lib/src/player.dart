import 'base_status.dart';

class Player extends BaseStatus {
  static Player black = Player._(1);
  static Player white = Player._(2);

  Player._(super.value);

  Player get opponent => this == black ? white : black;

  String toString() {
    return this == black ? 'black' : 'white';
  }
}
