/// Static heuristics for estimating influence maps on Go positions.
///
/// Ported from "@sabaki/influence" (MIT, © Yichuan Shen),
/// https://github.com/SabakiHQ/influence. The upstream functions operate on a
/// 2D sign grid (`data[y][x]`, 1 = black, -1 = white, 0 = empty); here they
/// take a [Board] and convert it to that grid internally, preserving the
/// original algorithms and default constants exactly.
library;

import 'dart:math' as math;

import '../board.dart';

/// Converts a [Board] to the `data[y][x]` sign grid the algorithms operate on.
/// 1 = black, -1 = white, 0 = empty.
List<List<int>> _signs(Board board) {
  return [
    for (var y = 0; y < board.height; y++)
      [
        for (var x = 0; x < board.width; x++)
          switch (board.get((x: x, y: y))) {
            Stone.black => 1,
            Stone.white => -1,
            null => 0,
          }
      ]
  ];
}

// Orthogonal neighbors. Mirrors helper.js `getNeighbors`; coordinates may go
// out of board, which several algorithms rely on.
List<List<int>> _getNeighbors(int x, int y) => [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
    ];

int _sign(num x) => x > 0 ? 1 : (x < 0 ? -1 : 0);

// Flood-fills the chain of equal-valued points containing [v]. Mirrors
// helper.js `getChain`: out-of-board neighbors (rows that don't exist) are
// skipped via the `data[ny] == null` check.
List<List<int>> _getChain(List<List<num>> data, List<int> v) {
  final sign = data[v[1]][v[0]];
  final result = <List<int>>[];
  final done = <String>{};

  void visit(List<int> v) {
    result.add(v);
    done.add('${v[0]},${v[1]}');

    for (final n in _getNeighbors(v[0], v[1])) {
      final nx = n[0];
      final ny = n[1];
      if (ny < 0 || ny >= data.length || nx < 0 || nx >= data[ny].length) {
        continue;
      }
      if (data[ny][nx] != sign || done.contains('$nx,$ny')) continue;
      visit(n);
    }
  }

  visit(v);
  return result;
}

double? _average(List<num> arr, [double? defaultValue]) {
  if (arr.isEmpty) return defaultValue;
  return arr.fold<num>(0, (sum, x) => sum + x) / arr.length;
}

/// Computes the definite-territory map for [board].
///
/// Stone points keep their color; an empty-point chain takes the color of its
/// adjacent stones if single-colored, or 0 (dame) if it touches both colors.
/// Returns a `result[y][x]` grid with values -1 (white), 0, or 1 (black).
List<List<int>> areaMap(Board board) {
  return [
    for (final row in _areaMap(_signs(board))) [for (final v in row) v.toInt()]
  ];
}

// areaMap operating on a numeric grid. Non-zero cells keep their raw value
// (so influenceMap's final `areaMap(map)` preserves blurred floats on stone
// points); empty-chain cells get `sign * indicator` (-1/0/1).
List<List<num>> _areaMap(List<List<num>> data) {
  final height = data.length;
  final width = height == 0 ? 0 : data[0].length;
  final map = [for (var i = 0; i < height; i++) List<num?>.filled(width, null)];

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (map[y][x] != null) continue;
      if (data[y][x] != 0) {
        map[y][x] = data[y][x];
        continue;
      }

      final chain = _getChain(data, [x, y]);
      var sign = 0;
      var indicator = 1;

      for (final c in chain) {
        if (indicator == 0) break;

        for (final n in _getNeighbors(c[0], c[1])) {
          final nx = n[0];
          final ny = n[1];
          if (ny < 0 || ny >= data.length || nx >= data[ny].length || nx < 0) {
            continue;
          }
          if (data[ny][nx] == 0) continue;

          if (sign == 0) {
            sign = _sign(data[ny][nx]);
          } else if (sign != _sign(data[ny][nx])) {
            indicator = 0;
            break;
          }
        }
      }

      for (final c in chain) {
        map[c[1]][c[0]] = sign * indicator;
      }
    }
  }

  return [
    for (final row in map) [for (final v in row) v!]
  ];
}

/// Computes the distance map to the nearest stone of the given [sign]
/// (1 = black, -1 = white) on [board], via a two-pass sweep.
///
/// Returns a `result[y][x]` grid of distances; cells with no reachable stone
/// hold [double.infinity].
List<List<double>> nearestNeighborMap(Board board, int sign) {
  return _nearestNeighborMapFromSigns(_signs(board), sign);
}

List<List<double>> _nearestNeighborMapFromSigns(
    List<List<int>> data, int sign) {
  final height = data.length;
  final width = height == 0 ? 0 : data[0].length;
  final map = [
    for (var i = 0; i < height; i++) List<double>.filled(width, double.infinity)
  ];
  var min = double.infinity;

  void f(int x, int y) {
    if (data[y][x] == sign) {
      min = 0;
    } else {
      min++;
    }

    min = math.min(min, map[y][x]);
    map[y][x] = min;
  }

  for (var y = 0; y < height; y++) {
    min = double.infinity;

    for (var x = 0; x < width; x++) {
      f(x, y);
      final old = min;

      for (var ny = y + 1; ny < height; ny++) {
        f(x, ny);
      }
      min = old;

      for (var ny = y - 1; ny >= 0; ny--) {
        f(x, ny);
      }
      min = old;
    }
  }

  for (var y = height - 1; y >= 0; y--) {
    min = double.infinity;

    for (var x = width - 1; x >= 0; x--) {
      f(x, y);
      final old = min;

      for (var ny = y + 1; ny < height; ny++) {
        f(x, ny);
      }
      min = old;

      for (var ny = y - 1; ny >= 0; ny--) {
        f(x, ny);
      }
      min = old;
    }
  }

  return map;
}

/// Computes the radiance map for stones of the given [sign] (1 = black,
/// -1 = white) on [board].
///
/// Each chain radiates via BFS; the radiation is blocked by enemy stones, and
/// out-of-board contributions are folded back at mirrored vertices. [p1], [p2],
/// and [p3] are the upstream tuning constants.
///
/// Returns a `result[y][x]` grid of radiance values.
List<List<double>> radianceMap(Board board, int sign,
    {num p1 = 6, num p2 = 1.5, num p3 = 2}) {
  return _radianceMapFromSigns(_signs(board), sign, p1: p1, p2: p2, p3: p3);
}

List<List<double>> _radianceMapFromSigns(List<List<int>> data, int sign,
    {num p1 = 6, num p2 = 1.5, num p3 = 2}) {
  final height = data.length;
  final width = height == 0 ? 0 : data[0].length;
  final map = [for (var i = 0; i < height; i++) List<double>.filled(width, 0)];
  final size = [width, height];
  final done = <String>{};

  List<int> getMirroredVertex(List<int> v) {
    if (v[0] >= 0 && v[0] < width && v[1] >= 0 && v[1] < height) return v;
    return [
      for (var i = 0; i < v.length; i++)
        v[i] < 0 ? -v[i] - 1 : (v[i] >= size[i] ? 2 * size[i] - v[i] - 1 : v[i])
    ];
  }

  void castRadiance(List<List<int>> chain) {
    final queue = [
      for (final x in chain) [x, 0]
    ];
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final item = queue.removeAt(0);
      final v = item[0] as List<int>;
      final d = item[1] as int;
      final mv = getMirroredVertex(v);

      // `mv !== v` in JS is reference identity; getMirroredVertex returns the
      // same instance only when the vertex is in board.
      map[mv[1]][mv[0]] +=
          !identical(mv, v) ? p3.toDouble() : p2 / (d / p1 * 6 + 1);

      for (final n in _getNeighbors(v[0], v[1])) {
        final nx = n[0];
        final ny = n[1];
        final blockedByEnemy = ny >= 0 &&
            ny < data.length &&
            nx >= 0 &&
            nx < data[ny].length &&
            data[ny][nx] == -sign;
        if (d >= p1 || blockedByEnemy || visited.contains('$nx,$ny')) {
          continue;
        }

        visited.add('$nx,$ny');
        queue.add([n, d + 1]);
      }
    }
  }

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (data[y][x] != sign || done.contains('$x,$y')) continue;

      final chain = _getChain(data, [x, y]);
      for (final w in chain) {
        done.add('${w[0]},${w[1]}');
      }

      castRadiance(chain);
    }
  }

  return map;
}

/// Estimates the influence map for [board].
///
/// Combines [areaMap], [nearestNeighborMap], and [radianceMap], then applies
/// the upstream post-processing (isolated-island removal, ragged-area fix,
/// near-edge fill, blur, normalization).
///
/// - [discrete]: if true, returns only -1, 0, 1 values.
/// - [maxDistance], [minRadiance]: upstream tuning constants.
///
/// Returns a `result[y][x]` grid; non-discrete values lie in [-1, 1].
List<List<num>> influenceMap(Board board,
    {bool discrete = false, num maxDistance = 6, num minRadiance = 2}) {
  final data = _signs(board);
  final height = data.length;
  final width = height == 0 ? 0 : data[0].length;
  final areamap = _areaMap([
    for (final r in data) [for (final v in r) v]
  ]);
  final map = [
    for (final row in areamap) [for (final v in row) v]
  ];
  final pnnmap = _nearestNeighborMapFromSigns(data, 1);
  final nnnmap = _nearestNeighborMapFromSigns(data, -1);
  final prmap = _radianceMapFromSigns(data, 1);
  final nrmap = _radianceMapFromSigns(data, -1);
  var max = double.negativeInfinity;
  var min = double.infinity;

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (map[y][x] != 0) continue;

      final s = _sign(nnnmap[y][x] - pnnmap[y][x]);
      final faraway = s == 0 || (s > 0 ? pnnmap : nnnmap)[y][x] > maxDistance;
      final dim = s == 0 || (s > 0 ? prmap : nrmap)[y][x].round() < minRadiance;

      if (faraway || dim) {
        map[y][x] = 0;
      } else {
        map[y][x] = s * (s > 0 ? prmap[y][x] : nrmap[y][x]);
      }

      max = math.max(max, map[y][x].toDouble());
      min = math.min(min, map[y][x].toDouble());

      if (discrete) map[y][x] = _sign(map[y][x]);
    }
  }

  // Postprocessing.

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (areamap[y][x] != 0) continue;

      var sign = _sign(map[y][x]);

      final neighbors = _getNeighbors(x, y).where((n) {
        final i = n[0];
        final j = n[1];
        return j >= 0 && j < data.length && i >= 0 && i < data[j].length;
      }).toList();
      final friendlyNeighbors = sign == 0
          ? null
          : neighbors.where((n) => _sign(map[n[1]][n[0]]) == sign).toList();

      // Prevent single point areas.

      if (sign != 0) {
        if (neighbors.length >= 2 &&
            neighbors.every((n) => _sign(map[n[1]][n[0]]) != sign)) {
          map[y][x] = 0;
          continue;
        }
      }

      // Fix ragged areas.

      if (sign != 0) {
        if (friendlyNeighbors!.length == 1) {
          final i = friendlyNeighbors[0][0];
          final j = friendlyNeighbors[0][1];

          if (data[j][i] == sign) {
            map[y][x] = 0;
            continue;
          }
        }
      }

      // Fix empty pillars.

      final distance = [x, y, width - x - 1, height - y - 1].reduce(math.min);

      if (distance <= 2 && sign != 0) {
        final signedNeighbors =
            neighbors.where((n) => map[n[1]][n[0]] != 0).toList();

        if (signedNeighbors.length >= 2) {
          final i1 = signedNeighbors[0][0];
          final j1 = signedNeighbors[0][1];
          final i2 = signedNeighbors[1][0];
          final j2 = signedNeighbors[1][1];
          final s = _sign(map[j1][i1]);

          if ((signedNeighbors.length >= 3 || i1 == i2 || j1 == j2) &&
              signedNeighbors.every((n) => _sign(map[n[1]][n[0]]) == s)) {
            map[y][x] = !discrete
                ? _average([for (final n in signedNeighbors) map[n[1]][n[0]]])!
                : s;
            sign = s;
          }
        }
      }

      // Blur.

      if (!discrete && sign != 0) {
        map[y][x] = _average([
          [x, y],
          ...friendlyNeighbors!
        ].map((n) => map[n[1]][n[0]]).toList())!;
      }
    }
  }

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      if (areamap[y][x] != 0 || map[y][x] == 0) continue;

      final sign = _sign(map[y][x]);

      // Normalize.

      if (!discrete) {
        if (sign > 0) {
          map[y][x] = math.min(map[y][x] / max, 1);
        } else if (sign < 0) {
          map[y][x] = math.max(-map[y][x] / min, -1);
        }
      }
    }
  }

  // Upstream feeds the float map back through areaMap, whose `getChain`
  // groups by exact value; this yields the final discrete-territory grouping.
  return _areaMap(map);
}
