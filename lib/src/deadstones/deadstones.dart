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
import 'pseudo_board.dart';

export 'pseudo_board.dart';

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

/// Returns the vertices of stones on [board] that are obviously dead,
/// judged heuristically by the surrounding regions (no playouts involved).
List<Vertex> getFloatingStones(Board board) {
  final pseudo = PseudoBoard.fromBoard(board);

  return pseudo.getFloatingStones().map(pseudo.indexToVertex).toList();
}
