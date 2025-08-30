import 'dart:math';

enum GoStone {
  black,
  white,
}

typedef Vertex = ({int x, int y});

extension VertexExt on Vertex {
  String toGoString(int size) {
    if (x < 0 || y < 0 || x >= size || y >= size) return '';
    const letters = 'ABCDEFGHJKLMNOPQRST';
    return '${letters[x]}${size - y}';
  }
}

typedef KoInfo = ({GoStone stone, Vertex vertex});

enum IllegalMoveReason { overwrite, ko, suicide }

class IllegalMoveException implements Exception {
  final IllegalMoveReason reason;
  final Vertex vertex;
  final GoStone stone;
  const IllegalMoveException(this.reason,
      {required this.vertex, required this.stone});
  @override
  String toString() =>
      'IllegalMoveException(${reason.name} at ${vertex.x},${vertex.y} by $stone)';
}

class GoBoard {
  List<List<GoStone?>> state;
  final Map<GoStone, int> _captures = {GoStone.black: 0, GoStone.white: 0};
  KoInfo? _koInfo;
  static const alpha = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';

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

  GoBoard set(Vertex v, GoStone? stone) {
    state[v.y][v.x] = stone;
    return this;
  }

  GoBoard makeMove(
    Vertex vertex,
    GoStone stone, {
    bool preventSuicide = false,
    bool preventOverwrite = false,
    bool preventKo = false,
  }) {
    final move = clone();
    if (!has(vertex)) return move;

    if (preventOverwrite && move.get(vertex) != null) {
      throw IllegalMoveException(
        IllegalMoveReason.overwrite,
        vertex: vertex,
        stone: stone,
      );
    }

    if (preventKo && _koInfo?.stone == stone && _koInfo?.vertex == vertex) {
      throw IllegalMoveException(
        IllegalMoveReason.ko,
        vertex: vertex,
        stone: stone,
      );
    }

    move.set(vertex, stone);

    final other = stone == GoStone.black ? GoStone.white : GoStone.black;
    final neighbors = move.getNeighbors(vertex);
    final deadStones = <Vertex>[];
    final deadNeighbors = neighbors.where(
      (n) => move.get(n) == other && !move.hasLiberties(n),
    );

    for (final n in deadNeighbors) {
      if (move.get(n) == null) continue;

      final chain = move.getChain(n);
      for (final c in chain) {
        move.state[c.y][c.x] = null;
        move.setCaptures(stone, move.getCaptures(stone) + 1);
        deadStones.add(c);
      }
    }

    final liberties = move.getLiberties(vertex);
    final hasKo = deadStones.length == 1 &&
        liberties.length == 1 &&
        liberties[0] == deadStones[0] &&
        neighbors.every((n) => move.get(n) != stone);

    move._koInfo = hasKo ? (stone: other, vertex: deadStones[0]) : null;

    if (deadStones.isEmpty && liberties.isEmpty) {
      if (preventSuicide) {
        throw IllegalMoveException(
          IllegalMoveReason.suicide,
          vertex: vertex,
          stone: stone,
        );
      }

      final chain = move.getChain(vertex);
      for (final c in chain) {
        move.set(c, null).setCaptures(
              other,
              getCaptures(other),
            );
      }
    }

    return move;
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

  List<Vertex> getHandicapPlacement(int count, {bool tygem = false}) {
    if (min(width, height) <= 6 || count < 2) return [];

    final nearX = width >= 13 ? 3 : 2;
    final nearY = height >= 13 ? 3 : 2;
    final farX = width - nearX - 1;
    final farY = height - nearY - 1;
    final middleX = (width - 1) ~/ 2;
    final middleY = (height - 1) ~/ 2;

    final result = <Vertex>[];
    if (!tygem) {
      result.addAll([
        (x: nearX, y: farY),
        (x: farX, y: nearY),
        (x: farX, y: farY),
        (x: nearX, y: nearY),
      ]);
    } else {
      result.addAll([
        (x: nearX, y: farY),
        (x: farX, y: nearY),
        (x: nearX, y: nearY),
        (x: farX, y: farY),
      ]);
    }

    if (width.isOdd && height.isOdd && width != 7 && height != 7) {
      if (count == 5) result.add((x: middleX, y: middleY));
      result.addAll([
        (x: nearX, y: middleY),
        (x: farX, y: middleY),
      ]);
      if (count == 7) result.add((x: middleX, y: middleY));
      result.addAll([
        (x: middleX, y: nearY),
        (x: middleX, y: farY),
        (x: middleX, y: middleY),
      ]);
    } else if (width.isOdd && width != 7) {
      result.addAll([
        (x: middleX, y: nearY),
        (x: middleX, y: farY),
      ]);
    } else if (height.isOdd && height != 7) {
      result.addAll([
        (x: nearX, y: middleY),
        (x: farX, y: middleY),
      ]);
    }

    return result.take(count).toList();
  }

  String stringifyVertex(Vertex v) {
    if (!has(v)) return '';
    return '${alpha[v.x]}${height - v.y}';
  }

  Vertex? parseVertex(String coord) {
    if (coord.length < 2) return null;
    final x = alpha.indexOf(coord[0].toUpperCase());
    final n = int.tryParse(coord.substring(1));
    if (n == null) return null;
    final y = height - n;
    final v = (x: x, y: y);
    return has(v) ? v : null;
  }

  @override
  String toString() {
    final buf = StringBuffer();
    final labelWidth = height.toString().length;
    String padLeft(String s, int w) => s.padLeft(w);
    String cellSymbol(GoStone? s) {
      if (s == null) return '.';
      return s == GoStone.black ? 'X' : 'O';
    }

    final header = StringBuffer();
    header.write(' '.padLeft(labelWidth + 1));
    if (width <= alpha.length) {
      for (var x = 0; x < width; x++) {
        header.write(alpha[x]);
        if (x != width - 1) header.write(' ');
      }
    } else {
      for (var x = 1; x <= width; x++) {
        header.write((x % 10).toString());
        if (x != width) header.write(' ');
      }
    }
    buf.writeln(header.toString());
    for (var y = 0; y < height; y++) {
      final rowLabel = (y + 1).toString();
      buf.write(padLeft(rowLabel, labelWidth));
      buf.write(' ');
      for (var x = 0; x < width; x++) {
        buf.write(cellSymbol(state[y][x]));
        if (x != width - 1) buf.write(' ');
      }
      buf.write(' ');
      buf.writeln(rowLabel);
    }
    buf.writeln(header.toString());
    return buf.toString();
  }
}
