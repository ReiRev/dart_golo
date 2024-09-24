import 'rule.dart';
import 'coordinate_status.dart';
import 'player.dart';

class IllegalMoveError extends Error {
  final String message;

  IllegalMoveError(this.message);

  @override
  String toString() {
    return 'IllegalMoveError: $message';
  }
}

class GameLogic {
  final Rule _rule;
  final int boardSize;
  late final int arrSize;
  late final int dy;
  late final List<int> adjOffsets;
  late final List<int> diagOffsets;

  late Player player;
  late List<CoordinateStatus> board;
  late Uint16List groupHeadIndices;
  late Uint16List groupStoneCounts;
  late Uint16List groupLibertyCounts;
  late Uint16List groupNextIndices;
  late Uint16List groupPrevIndices;
  late int? simpleKoPoint;
  late Map<Player, int> captures;

  GameLogic({
    required this.boardSize,
    Rule? rule,
  })  : assert(boardSize > 0),
        _rule = rule ?? ChineseRule() {
    arrSize = (boardSize + 1) * (boardSize + 2) + 1;
    dy = boardSize + 1;
    adjOffsets = [-dy, -1, 1, dy];
    diagOffsets = [-dy - 1, -dy + 1, dy - 1, dy + 1];

    player = Player.black;
    // initial value is zero
    board = List.filled(arrSize, CoordinateStatus.empty);
    // TODO: Make linked list class
    groupHeadIndices = Uint16List(arrSize);
    groupStoneCounts = Uint16List(arrSize);
    groupLibertyCounts = Uint16List(arrSize);
    groupNextIndices = Uint16List(arrSize);
    groupPrevIndices = Uint16List(arrSize);
    simpleKoPoint = null;
    captures = {Player.black: 0, Player.white: 0};
    moves = {Player.black: 0, Player.white: 0};

    for (int i = -1; i < boardSize; i++) {
      board[loc(i, -1)] = CoordinateStatus.wall;
      board[loc(i, boardSize)] = CoordinateStatus.wall;
      board[loc(-1, i)] = CoordinateStatus.wall;
      board[loc(boardSize, i)] = CoordinateStatus.wall;
    }

    // Catch errors easily.
    groupHeadIndices[0] = -1;
    groupNextIndices[0] = -1;
    groupPrevIndices[0] = -1;
  }
}
