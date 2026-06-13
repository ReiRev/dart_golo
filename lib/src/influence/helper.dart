// Mirrors "@sabaki/influence" src/helper.js, plus the Board <-> sign-grid glue
// that the Dart port needs (the upstream API takes a raw sign grid).
part of 'influence.dart';

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

// Replacement for JS `Math.sign` (Dart has no built-in).
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
