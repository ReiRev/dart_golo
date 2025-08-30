enum GoStone {
  black,
  white,
}

typedef Vertex = ({int x, int y});

typedef KoInfo = ({GoStone stone, Vertex vertex});

class GoBoard {
  List<List<GoStone?>> state;
  final Map<GoStone, int> _captures = {GoStone.black: 0, GoStone.white: 0};
  KoInfo? _koInfo;

  GoBoard(this.state, {Map<GoStone, int>? captures, KoInfo? koInfo}) {
    final int rowLength = state[0].length;
    for (final row in state) {
      if (row.length != rowLength) {
        throw ArgumentError('All rows must have the same length');
      }
    }

    if (captures != null) {
      _captures[GoStone.black] = captures[GoStone.black] ?? 0;
      _captures[GoStone.white] = captures[GoStone.white] ?? 0;
    }

    if (koInfo != null) {
      _koInfo = koInfo;
    }
  }

  GoBoard.fromDimension(int width, [int? height])
      : this(List.generate(
            height ?? width, (_) => List.generate(width, (_) => null)));

  int get height => state.length;
  int get width => state[0].length;

  GoStone? get(Vertex v) => has(v) ? state[v.y][v.x] : null;
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

  GoBoard setCaptures(GoStone stone, int value) {
    _captures[stone] = value;
    return this;
  }

  List<Vertex> getChain(Vertex vertex) {
    final stone = get(vertex);
    return getConnectedComponent(vertex, (v) => get(v) == stone);
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
    Vertex vertex,
    bool Function(Vertex v) predicate, [
    List<Vertex>? result,
  ]) {
    if (!has(vertex)) return [];
    result ??= [vertex];

    // Recursive depth-first search
    for (final v in getNeighbors(vertex)) {
      if (!predicate(v)) continue;
      final already = result.any((w) => w.x == v.x && w.y == v.y);
      if (already) continue;

      result.add(v);
      getConnectedComponent(v, predicate, result);
    }

    return result;
  }

  List<Vertex> getLiberties(Vertex v) {
    if (!has(v) || get(v) == null) return [];

    final chain = getChain(v);
    final Set<Vertex> liberties = {};
    for (final c in chain) {
      for (final nv in getNeighbors(c)) {
        if (get(nv) == null) {
          liberties.add(nv);
        }
      }
    }

    return liberties.toList();
  }

  int getDistance(Vertex v1, Vertex v2) {
    return (v1.x - v2.x).abs() + (v1.y - v2.y).abs();
  }

  bool hasLiberties(Vertex v, [Map<Vertex, bool>? visited]) {
    final stone = get(v);
    if (!has(v) || stone == null) return false;

    visited ??= <Vertex, bool>{};
    if (visited.containsKey(v)) return false;

    final neighbors = getNeighbors(v);
    if (neighbors.any((n) => get(n) == null)) return true;

    visited[v] = true;

    return neighbors
        .where((n) => get(n) == stone)
        .any((n) => hasLiberties(n, visited));
  }

  bool isValid() {
    final Map<Vertex, bool> liberties = {};

    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final v = (x: x, y: y);
        if (get(v) == null || liberties.containsKey(v)) continue;
        if (!hasLiberties(v)) return false;

        for (final v in getChain(v)) {
          liberties[v] = true;
        }
      }
    }

    return true;
  }

  List<Vertex> getRelatedChains(Vertex vertex) {
    if (!has(vertex) || get(vertex) == null) return [];

    final stone = get(vertex);
    final area = getConnectedComponent(
      vertex,
      (v) {
        final s = get(v);
        return s == stone || s == null;
      },
    );

    return area.where((v) => get(v) == stone).toList();
  }

  GoBoard copyWith({
    List<List<GoStone?>>? state,
    Map<GoStone, int>? captures,
    KoInfo? koInfo,
  }) {
    return GoBoard(
      state?.map((r) => List<GoStone?>.from(r)).toList(growable: false) ??
          this.state.map((r) => List<GoStone?>.from(r)).toList(growable: false),
      captures: {...(captures ?? _captures)},
      koInfo: koInfo ?? _koInfo,
    );
  }

  GoBoard clone() => copyWith();

  List<Vertex>? diff(GoBoard board) {
    if (board.width != width || board.height != height) {
      return null;
    }

    final result = <Vertex>[];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final other = board.get((x: x, y: y));
        if (get((x: x, y: y)) == other) continue;
        result.add((x: x, y: y));
      }
    }
    return result;
  }
}
