// Dead stone estimation demo: builds a finished 9x9 position, prints the
// board, the Monte Carlo ownership probability map, and the guessed dead
// stones.

import 'package:golo/golo.dart';

void main() {
  // 1 = black (X), -1 = white (O), 0 = empty. The white stones scattered
  // inside black's left-hand territory are dead.
  const signs = [
    [0, 1, 0, 1, -1, 0, -1, -1, 0],
    [1, 0, 1, 1, -1, -1, -1, 0, -1],
    [0, 1, -1, 1, 1, -1, 0, -1, 0],
    [1, -1, 0, -1, 1, -1, -1, 0, -1],
    [0, 1, -1, -1, 1, 1, -1, -1, -1],
    [1, 1, 1, 1, 1, 1, 1, -1, 0],
    [0, 1, -1, -1, 1, 1, -1, -1, -1],
    [1, 1, 1, -1, -1, 1, -1, 0, -1],
    [0, 1, -1, -1, 0, 1, -1, -1, 0],
  ];

  final board = Board([
    for (final row in signs)
      [
        for (final sign in row)
          switch (sign) {
            1 => Stone.black,
            -1 => Stone.white,
            _ => null,
          }
      ]
  ]);

  print('Position:');
  print(board);

  // Ownership probabilities: 1 = certainly black, -1 = certainly white.
  final map = getProbabilityMap(board, iterations: 200, seed: 42);

  print('Ownership probability map (B = black, W = white):');
  for (final row in map) {
    print(row
        .map((p) => '${p < 0 ? 'W' : 'B'}${(p.abs() * 9).round()}')
        .join(' '));
  }
  print('');

  final floating = getFloatingStones(board);
  print('Floating stones: '
      '${floating.map(board.stringifyVertex).join(', ')}');

  final dead = guess(board, finished: true, iterations: 200, seed: 42);
  print('Guessed dead stones: '
      '${dead.map(board.stringifyVertex).join(', ')}');
}
