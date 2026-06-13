import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

  test('should not mutate board data', () {
    final before = finishedBoard.clone();

    getProbabilityMap(finishedBoard, iterations: 50, seed: 42);

    expect(finishedBoard.diff(before), isEmpty);
  });

  test('should contain values between -1 and 1', () {
    final map = getProbabilityMap(unfinishedBoard, iterations: 50, seed: 42);

    expect(map.every((row) => row.every((x) => -1 <= x && x <= 1)), isTrue);
  });
}
