// Mirrors "@sabaki/influence" src/influenceMap.js.
part of 'influence.dart';

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
