// Demonstrates the influence heuristics on a small position.
//
// Run with: dart run example/influence_demo.dart

import 'package:golo/golo.dart';

void main() {
  // A 9x9 board with a couple of stones in opposite corners.
  final board = Board.fromDimension(9);
  board.set((x: 2, y: 2), Stone.black);
  board.set((x: 6, y: 6), Stone.white);

  print('Board:');
  print(board);

  print('Discrete influence map (1 = black, -1 = white, 0 = neutral):');
  _printMap(influenceMap(board, discrete: true));

  print('Continuous influence map (values in [-1, 1]):');
  _printMap(influenceMap(board), decimals: 2);
}

void _printMap(List<List<num>> map, {int? decimals}) {
  for (final row in map) {
    final cells = row.map((v) {
      final s = decimals == null ? v.toString() : v.toStringAsFixed(decimals);
      return s.padLeft(decimals == null ? 2 : 6);
    });
    print(cells.join(' '));
  }
  print('');
}
