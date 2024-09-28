import 'package:golo/src/player.dart';

import 'base_status.dart';

class CoordinateStatus extends BaseStatus {
  static CoordinateStatus empty = CoordinateStatus._(0);
  static CoordinateStatus black = CoordinateStatus._(1);
  static CoordinateStatus white = CoordinateStatus._(2);
  static CoordinateStatus wall = CoordinateStatus._(3);

  // CoordinateStatus._(int value) : super._(value);
  CoordinateStatus._(super.value);

  factory CoordinateStatus.fromPlayer(Player player) {
    if (player == Player.black) {
      return CoordinateStatus.black;
    } else if (player == Player.white) {
      return CoordinateStatus.white;
    } else {
      throw ArgumentError('Invalid player');
    }
  }

  Player get player {
    if (this == CoordinateStatus.black) {
      return Player.black;
    } else if (this == CoordinateStatus.white) {
      return Player.white;
    } else {
      throw StateError('CoordinateStatus is not a player');
    }
  }

  @override
  String toString() {
    if (this == CoordinateStatus.empty) {
      return 'empty';
    } else if (this == CoordinateStatus.black) {
      return 'black';
    } else if (this == CoordinateStatus.white) {
      return 'white';
    } else {
      return 'wall';
    }
  }
}
