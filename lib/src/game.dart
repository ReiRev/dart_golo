import 'board_state.dart';
import 'player.dart';

class Game {
  final int _boardSize;
  int get boardSize => _boardSize;

  late BoardState _boardState;
  BoardState get boardState => _boardState;

  Game({
    required int boardSize,
  })  : assert(boardSize > 0),
        _boardSize = boardSize {
    _boardState = BoardState(boardSize: boardSize);
  }

  void play(Player player, int x, int y) {
    _boardState.play(player, x, y);
  }

  @override
  String toString() {
    return _boardState.toString();
  }
}
