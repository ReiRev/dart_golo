import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

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
