enum GoStone {
  black,
  white,
}

typedef Vertex = ({int x, int y});

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

  GoBoard.fromDimension(int width, [int? height])
      : this(List.generate(
            height ?? width, (_) => List.generate(width, (_) => null)));

  int get height => state.length;
  int get width => state[0].length;

  GoStone? get(Vertex v) => state[v.y][v.x];
  bool has(Vertex v) => 0 <= v.x && v.x < width && 0 <= v.y && v.y < height;
  bool isSquare() => width == height;
  bool isEmpty() => state.every((row) => row.every((stone) => stone == null));

  GoBoard set(Vertex v, GoStone stone) {
    state[v.y][v.x] = stone;
    return this;
  }

  GoBoard makeMove(Vertex v, GoStone stone) {
    final board = GoBoard(List.generate(
        height, (y_) => List.generate(width, (x_) => state[y_][x_])));
    return board.set(v, stone);
  }

  void clear() {
    state = List.generate(height, (_) => List.generate(width, (_) => null));
  }

  int getCaptures(GoStone player) {
    return _captures[player] ?? 0;
  }

  List<Vertex> getChain(Vertex v) {
    return [];
  }

  List<Vertex> getNeighbors(Vertex v) {
    if (!has(v)) {
      return [];
    }
    final x = v.x;
    final y = v.y;
    return [
      (x: x - 1, y: y),
      (x: x + 1, y: y),
      (x: x, y: y - 1),
      (x: x, y: y + 1)
    ].where((v) => has(v)).toList();
  }

  List<Vertex> getConnectedComponent(
    Vertex v,
    bool Function(Vertex v) predicate,
  ) {
    return [];
  }

  List<Vertex> getLiberties(Vertex v) {
    if (!has(v) || get(v) == null) {}
    return [];
  }
}
