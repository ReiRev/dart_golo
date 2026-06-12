/// Monte Carlo dead stone estimation.
///
/// Ported from the Rust sources of "@sabaki/deadstones" by SabakiHQ
/// (https://github.com/SabakiHQ/deadstones, MIT License).
///
/// The original Xorshift128 generator is replaced by `dart:math`'s [Random];
/// pass a `seed` to make results deterministic.
library;

import 'dart:math';

import '../board.dart';

/// A lightweight, playout-only Go board used by the dead stone estimator.
///
/// Unlike [Board], the state is stored as a flat [List] of integer signs
/// (`1` for black, `-1` for white, `0` for an empty point) indexed by
/// `y * width + x`. It performs no rule bookkeeping (ko, captures count)
/// and is therefore cheap to clone during Monte Carlo playouts.
class PseudoBoard {
  /// Flat board state of length `width * height`.
  ///
  /// Entry `y * width + x` holds the sign at `(x, y)`: `1` for black,
  /// `-1` for white, `0` for an empty point.
  final List<int> data;

  /// Number of columns of the board.
  final int width;

  /// Creates a pseudo board from a flat sign list [data] and its [width].
  ///
  /// `data.length` must be a multiple of [width].
  PseudoBoard(this.data, this.width) {
    if (width <= 0 || data.length % width != 0) {
      throw ArgumentError('data length must be a multiple of width');
    }
  }

  /// Creates a pseudo board snapshot of [board].
  ///
  /// [Stone.black] maps to `1`, [Stone.white] to `-1`, and empty points to
  /// `0`. The data is copied; the original [board] is never mutated.
  factory PseudoBoard.fromBoard(Board board) {
    final data = <int>[
      for (var y = 0; y < board.height; y++)
        for (var x = 0; x < board.width; x++)
          switch (board.get((x: x, y: y))) {
            Stone.black => 1,
            Stone.white => -1,
            null => 0,
          }
    ];

    return PseudoBoard(data, board.width);
  }

  /// Number of rows of the board.
  int get height => data.length ~/ width;

  /// Returns a deep copy of this pseudo board.
  PseudoBoard clone() => PseudoBoard(List.of(data), width);

  /// Converts a [vertex] to its flat index into [data].
  int vertexToIndex(Vertex vertex) => vertex.y * width + vertex.x;

  /// Converts a flat index [v] back to a `(x, y)` vertex.
  Vertex indexToVertex(int v) => (x: v % width, y: v ~/ width);

  /// Returns the sign at flat index [v], or `null` if [v] is out of board.
  int? get(int v) => 0 <= v && v < data.length ? data[v] : null;

  /// Sets the sign at flat index [v]. Out-of-board indices are ignored.
  void set(int v, int sign) {
    if (0 <= v && v < data.length) {
      data[v] = sign;
    }
  }

  /// Returns the flat indices of the orthogonal neighbors of [v] that lie
  /// on the board.
  List<int> getNeighbors(int v) {
    final x = v % width;

    return [
      if (v >= width) v - width,
      if (v + width < data.length) v + width,
      if (x > 0) v - 1,
      if (x < width - 1) v + 1,
    ];
  }

  /// Returns the connected component containing [vertex], where points are
  /// connected if their sign is contained in [signs].
  ///
  /// The starting [vertex] is always included, regardless of its sign.
  List<int> getConnectedComponent(int vertex, Set<int> signs) {
    final result = <int>[vertex];
    final visited = <int>{vertex};
    final stack = <int>[vertex];

    while (stack.isNotEmpty) {
      final v = stack.removeLast();

      for (final neighbor in getNeighbors(v)) {
        final s = get(neighbor);
        if (s == null || !signs.contains(s) || visited.contains(neighbor)) {
          continue;
        }

        visited.add(neighbor);
        result.add(neighbor);
        stack.add(neighbor);
      }
    }

    return result;
  }

  /// Returns all stones of the same sign as [vertex] that are reachable
  /// through paths of same-signed stones and empty points.
  ///
  /// Returns an empty list if [vertex] is empty or out of board.
  List<int> getRelatedChains(int vertex) {
    final sign = get(vertex);
    if (sign == null || sign == 0) return [];

    return getConnectedComponent(vertex, {sign, 0})
        .where((v) => get(v) == sign)
        .toList();
  }

  /// Returns the chain (connected stones of equal sign, or the connected
  /// empty region) containing [vertex].
  ///
  /// Returns an empty list if [vertex] is out of board.
  List<int> getChain(int vertex) {
    final sign = get(vertex);
    if (sign == null) return [];

    return getConnectedComponent(vertex, {sign});
  }

  /// Returns whether the chain at [vertex] has at least one liberty.
  ///
  /// Returns `false` if [vertex] is out of board.
  bool hasLiberties(int vertex) {
    final sign = get(vertex);
    if (sign == null) return false;

    final visited = <int>{};
    final stack = <int>[vertex];

    while (stack.isNotEmpty) {
      final v = stack.removeLast();
      if (!visited.add(v)) continue;

      for (final neighbor in getNeighbors(v)) {
        final s = get(neighbor);

        if (s == 0) return true;
        if (s == sign && !visited.contains(neighbor)) {
          stack.add(neighbor);
        }
      }
    }

    return false;
  }

  /// Plays a playout move of [sign] at flat index [v], mutating the board.
  ///
  /// A move is rejected, the board rolled back, and `null` returned when:
  ///
  /// - every neighbor already has the same sign (filling an obvious own
  ///   eye), or
  /// - the played stone would end up without liberties, unless it is a lone
  ///   stone capturing at least two opponent chains, or a stone connected
  ///   to a friendly chain capturing at least one stone.
  ///
  /// On success, returns the flat indices of captured (freed) stones.
  List<int>? makePseudoMove(int v, int sign) {
    final neighbors = getNeighbors(v);
    var checkCapture = false;
    var checkMultiDeadChains = false;

    if (neighbors.every((neighbor) => get(neighbor) == sign)) {
      return null;
    }

    set(v, sign);

    if (!hasLiberties(v)) {
      final isPointChain = neighbors.every((n) => get(n) != sign);

      if (isPointChain) {
        checkMultiDeadChains = true;
      } else {
        checkCapture = true;
      }
    }

    final dead = <int>[];
    var deadChains = 0;

    for (final neighbor in neighbors) {
      if (get(neighbor) != -sign || hasLiberties(neighbor)) {
        continue;
      }

      final chain = getChain(neighbor);
      deadChains++;

      for (final c in chain) {
        set(c, 0);
        dead.add(c);
      }
    }

    if (checkMultiDeadChains && deadChains <= 1 ||
        checkCapture && dead.isEmpty) {
      for (final d in dead) {
        set(d, -sign);
      }

      set(v, 0);
      return null;
    }

    return dead;
  }

  /// Returns the flat indices of stones that are obviously dead, judged by
  /// the surrounding connected regions (no playouts involved).
  List<int> getFloatingStones() {
    final done = <int>{};
    final result = <int>[];

    for (var vertex = 0; vertex < data.length; vertex++) {
      if (get(vertex) != 0 || done.contains(vertex)) {
        continue;
      }

      final posArea = getConnectedComponent(vertex, {0, -1});
      final negArea = getConnectedComponent(vertex, {0, 1});
      final posDead = posArea.where((v) => get(v) == -1).toList();
      final negDead = negArea.where((v) => get(v) == 1).toList();

      final posDeadSet = posDead.toSet();
      final negDeadSet = negDead.toSet();
      final posAreaSet = posArea.toSet();
      final negAreaSet = negArea.toSet();

      final posDiff = posArea
          .where((v) => !posDeadSet.contains(v) && !negAreaSet.contains(v))
          .length;
      final negDiff = negArea
          .where((v) => !negDeadSet.contains(v) && !posAreaSet.contains(v))
          .length;

      final favorNeg = negDiff <= 1 && negDead.length <= posDead.length;
      final favorPos = posDiff <= 1 && posDead.length <= negDead.length;

      List<int> actualArea;
      List<int> actualDead;

      if (favorPos && !favorNeg) {
        actualArea = posArea;
        actualDead = posDead;
      } else if (favorNeg && !favorPos) {
        actualArea = negArea;
        actualDead = negDead;
      } else {
        actualArea = getChain(vertex);
        actualDead = [];
      }

      done.addAll(actualArea);
      result.addAll(actualDead);
    }

    return result;
  }
}

/// Plays random moves on a copy of [board], starting with [sign], until
/// neither player can move, then fills the remaining empty points with the
/// sign of an adjacent stone.
///
/// The input [board] is not mutated; the finished position is returned as a
/// new [PseudoBoard]. Randomness is drawn from [random].
PseudoBoard playTillEnd(PseudoBoard board, int sign, Random random) {
  board = board.clone();

  final illegalVertices = <int>[];
  var finishedPos = false;
  var finishedNeg = false;
  final freeVertices = <int>[
    for (var v = 0; v < board.data.length; v++)
      if (board.data[v] == 0) v
  ];

  while (freeVertices.isNotEmpty && (!finishedPos || !finishedNeg)) {
    var madeMove = false;

    while (freeVertices.isNotEmpty) {
      final randomIndex = random.nextInt(freeVertices.length);
      final vertex = freeVertices.removeAt(randomIndex);
      final freedVertices = board.makePseudoMove(vertex, sign);

      if (freedVertices != null) {
        freeVertices.addAll(freedVertices);

        if (sign < 0) {
          finishedPos = false;
        } else {
          finishedNeg = false;
        }

        madeMove = true;
        break;
      } else {
        illegalVertices.add(vertex);
      }
    }

    if (sign > 0) {
      finishedPos = !madeMove;
    } else {
      finishedNeg = !madeMove;
    }

    freeVertices.addAll(illegalVertices);
    illegalVertices.clear();

    sign = -sign;
  }

  // Patch holes

  for (var vertex = 0; vertex < board.data.length; vertex++) {
    if (board.data[vertex] != 0) continue;

    var sign = 0;

    for (final neighbor in board.getNeighbors(vertex)) {
      final s = board.get(neighbor);

      if (s == 1 || s == -1) {
        sign = s!;
        break;
      }
    }

    if (sign != 0) {
      board.set(vertex, sign);
    }
  }

  return board;
}

List<double> _getProbabilityMap(
    PseudoBoard board, int iterations, Random random) {
  final negCounts = List<int>.filled(board.data.length, 0);
  final posCounts = List<int>.filled(board.data.length, 0);

  for (var i = 0; i < iterations; i++) {
    final sign = i < iterations ~/ 2 ? -1 : 1;
    final areaMap = playTillEnd(board, sign, random);

    for (var v = 0; v < areaMap.data.length; v++) {
      final s = areaMap.data[v];

      if (s == -1) {
        negCounts[v]++;
      } else if (s == 1) {
        posCounts[v]++;
      }
    }
  }

  return [
    for (var v = 0; v < board.data.length; v++)
      posCounts[v] + negCounts[v] == 0
          ? 0.0
          : posCounts[v] * 2 / (posCounts[v] + negCounts[v]) - 1
  ];
}

/// Estimates per-vertex ownership probabilities for [board] by running
/// [iterations] random playouts.
///
/// Returns a grid indexed as `result[y][x]` with values in `[-1, 1]`,
/// where `1` means the point is certainly controlled by black and `-1` by
/// white. Provide a [seed] for deterministic results.
List<List<double>> getProbabilityMap(
  Board board, {
  int iterations = 100,
  int? seed,
}) {
  final pseudo = PseudoBoard.fromBoard(board);
  final map = _getProbabilityMap(pseudo, iterations, Random(seed));

  return [
    for (var y = 0; y < board.height; y++)
      map.sublist(y * board.width, (y + 1) * board.width)
  ];
}

/// Returns the vertices of stones on [board] that are obviously dead,
/// judged heuristically by the surrounding regions (no playouts involved).
List<Vertex> getFloatingStones(Board board) {
  final pseudo = PseudoBoard.fromBoard(board);

  return pseudo.getFloatingStones().map(pseudo.indexToVertex).toList();
}

/// Guesses the dead stones on [board] using [iterations] random playouts.
///
/// If [finished] is `true`, the position is assumed to be a finished game:
/// obviously dead stones (see [getFloatingStones]) are removed before the
/// playouts and an additional pass keeps the life and death status of
/// related chains consistent.
///
/// Returns the vertices of all stones judged dead. Provide a [seed] for
/// deterministic results.
List<Vertex> guess(
  Board board, {
  bool finished = false,
  int iterations = 100,
  int? seed,
}) {
  final pseudo = PseudoBoard.fromBoard(board);
  final random = Random(seed);

  final floating = <int>[];
  if (finished) {
    floating.addAll(pseudo.getFloatingStones());

    for (final v in floating) {
      pseudo.set(v, 0);
    }
  }

  final map = _getProbabilityMap(pseudo, iterations, random);
  final result = <int>[];
  final done = <int>{};

  for (var vertex = 0; vertex < map.length; vertex++) {
    final sign = pseudo.data[vertex];
    if (sign == 0 || done.contains(vertex)) continue;

    final chain = pseudo.getChain(vertex);
    final probability =
        chain.fold(0.0, (sum, v) => sum + map[v]) / chain.length;
    final dead = (probability.isNegative ? -1 : 1) == -sign;

    for (final c in chain) {
      if (dead) result.add(c);
      done.add(c);
    }
  }

  if (!finished) {
    return result.map(pseudo.indexToVertex).toList();
  }

  // Preserve life & death status of related chains

  final resultSet = result.toSet();
  final doneRelated = <int>{};
  final updatedResult = <int>[...floating];

  for (final vertex in result) {
    if (doneRelated.contains(vertex)) continue;

    final related = pseudo.getRelatedChains(vertex);
    final deadProbability =
        related.where(resultSet.contains).length / related.length;
    final dead = deadProbability > 0.5;

    for (final v in related) {
      if (dead) updatedResult.add(v);
      doneRelated.add(v);
    }
  }

  return updatedResult.map(pseudo.indexToVertex).toList();
}
