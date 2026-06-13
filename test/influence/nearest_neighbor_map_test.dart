// Ported from "@sabaki/influence" (tests/nearestNeighborMap.test.js).

import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  test('should return same dimensions of input data', () {
    final result = nearestNeighborMap(boardFromSigns(unfinished), 1);

    expect(result.length, unfinished.length);
    expect(result[0].length, unfinished[0].length);
  });

  test('only stone positions of the same color should have value 0', () {
    const sign = -1;
    final result = nearestNeighborMap(boardFromSigns(unfinished), sign);

    for (var y = 0; y < unfinished.length; y++) {
      for (var x = 0; x < unfinished[0].length; x++) {
        if (unfinished[y][x] == sign) {
          expect(result[y][x], 0);
        } else {
          expect(result[y][x], isNot(0));
        }
      }
    }
  });
}
