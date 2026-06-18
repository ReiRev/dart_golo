// Mirrors "@sabaki/influence" src/areaMap.js.
part of 'influence.dart';

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
