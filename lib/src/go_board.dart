enum GoStone {
  black,
  white,
}

class GoBoard {
  List<List<GoStone?>> state;
  final Map<GoStone, int> _captures = {GoStone.black: 0, GoStone.white: 0};

  GoBoard(this.state) {
    final int rowLength = state[0].length;
    for (final row in state) {
      if (row.length != rowLength) {
        throw ArgumentError('All rows must have the same length');
      }
    }
  }

  int get height => state.length;
  int get width => state[0].length;

  GoStone? get(int x, int y) => state[y][x];

  int getCaptures(GoStone player) {
    return _captures[player] ?? 0;
  }
}
