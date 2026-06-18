// Ported from "@sabaki/influence" (tests/influenceMap.test.js).

import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  test('should return same dimensions of input data', () {
    final result = influenceMap(boardFromSigns(unfinished));

    expect(unfinished.length, result.length);
    expect(unfinished[0].length, result[0].length);
  });

  test('should have same sign as stones on stone vertices', () {
    final result = influenceMap(boardFromSigns(unfinished));

    for (var y = 0; y < unfinished.length; y++) {
      for (var x = 0; x < unfinished[0].length; x++) {
        if (unfinished[y][x] == 0) continue;
        expect(result[y][x], unfinished[y][x]);
      }
    }
  });

  test('should return a number between -1 and 1', () {
    final result = influenceMap(boardFromSigns(unfinished));

    expect(
        result.every((row) => row.every(((v) => -1 <= v && v <= 1))), isTrue);
  });

  test('should return -1, 0, 1 if discrete is set to true', () {
    final result = influenceMap(boardFromSigns(unfinished), discrete: true);

    expect(result.every((row) => row.every(((v) => [-1, 0, 1].contains(v)))),
        isTrue);
  });

  test('a stone at 3 3 should control the corner', () {
    final board =
        boardFromSigns([for (var i = 0; i < 19; i++) List<int>.filled(19, 0)]);
    board.set((x: 2, y: 2), Stone.black);
    board.set((x: 16, y: 16), Stone.white);

    final result = influenceMap(board, discrete: true);
    final corner = [
      [0, 0],
      [1, 0],
      [2, 0],
      [1, 1],
      [2, 1],
    ];
    expect(
      corner.every((p) {
        final x = p[0];
        final y = p[1];
        return result[y][x] == 1 && result[x][y] == 1;
      }),
      isTrue,
    );
  });

  test('should not have holes or single point areas', () {
    final result = influenceMap(boardFromSigns(middle), discrete: true);

    for (var y = 0; y < middle.length; y++) {
      for (var x = 0; x < middle[0].length; x++) {
        if (middle[y][x] != 0) continue;

        final neighbors = [
          [x - 1, y],
          [x + 1, y],
          [x, y - 1],
          [x, y + 1],
        ].where((p) {
          final i = p[0];
          final j = p[1];
          return j >= 0 && j < result.length && i >= 0 && i < result[j].length;
        }).toList();

        if (neighbors.isEmpty) continue;

        final sign =
            result[y][x] == 0 ? result[neighbors[0][1]][neighbors[0][0]] : 0;

        if (result[y][x] == 0 && sign == 0) continue;

        expect(
          neighbors.map((p) => result[p[1]][p[0]]).toList(),
          isNot(neighbors.map((_) => sign).toList()),
        );
      }
    }
  });
}
