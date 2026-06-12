import 'dart:math';

import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

  test('should not mutate board data', () {
    final pseudo = PseudoBoard.fromBoard(finishedBoard);
    final before = List.of(pseudo.data);

    playTillEnd(pseudo, -1, Random(42));

    expect(pseudo.data, before);
  });

  test('should not have empty vertices', () {
    final pseudo = PseudoBoard.fromBoard(unfinishedBoard);
    final finished = playTillEnd(pseudo, 1, Random(42));

    expect(finished.data.every((s) => s == 1 || s == -1), isTrue);
  });
}
