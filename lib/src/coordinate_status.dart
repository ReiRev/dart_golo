import 'package:golo/src/player.dart';

import 'base_status.dart';

class CoordinateStatus extends BaseStatus {
  static const CoordinateStatus empty = CoordinateStatus._(0);
  static const CoordinateStatus black = CoordinateStatus._(1);
  static const CoordinateStatus white = CoordinateStatus._(2);
  static const CoordinateStatus wall = CoordinateStatus._(3);

  // CoordinateStatus._(int value) : super._(value);
  const CoordinateStatus._(super.value);

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
