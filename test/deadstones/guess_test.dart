import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

  // Upstream (SabakiHQ/deadstones @ 764f5c0) used `t.assert(value, msg)`, which
  // only checks truthiness, so it never actually detected mutation. We verify
  // properly via clone/diff.
  test('should not mutate board data', () {
    final before = finishedBoard.clone();

    guess(finishedBoard, finished: true, seed: 42);

    expect(finishedBoard.diff(before), isEmpty);
  });

  test('should detect some dead stones from unfinished games', () {
    final dead = guess(unfinishedBoard, seed: 42);

    expect(dead, isNotEmpty);
  });

  test('should detect floating stones from finished games', () {
    final dead = guess(finishedBoard, finished: true, seed: 42);
    final floating = getFloatingStones(finishedBoard);

    expect(floating.every(dead.contains), isTrue);
  });
}
