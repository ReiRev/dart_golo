// Mirrors "@sabaki/influence" src/radianceMap.js.
part of 'influence.dart';

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
