// Mirrors "@sabaki/influence" src/nearestNeighborMap.js.
part of 'influence.dart';

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
