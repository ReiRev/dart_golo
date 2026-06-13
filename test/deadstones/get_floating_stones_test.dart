import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

  test('should not mutate board data', () {
    final before = finishedBoard.clone();

    getFloatingStones(finishedBoard);

    expect(finishedBoard.diff(before), isEmpty);
  });

  test('finished game', () {
    final floatingStones = getFloatingStones(finishedBoard);

    expect(
        floatingStones,
        unorderedEquals([
          (x: 10, y: 5),
          (x: 13, y: 13),
          (x: 13, y: 14),
          (x: 14, y: 7),
          (x: 18, y: 13),
          (x: 2, y: 13),
          (x: 2, y: 14),
          (x: 5, y: 13),
          (x: 6, y: 13),
          (x: 9, y: 3),
          (x: 9, y: 5),
        ]));
  });

  test('unfinished game', () {
    expect(getFloatingStones(unfinishedBoard), [(x: 0, y: 1)]);
  });
}
