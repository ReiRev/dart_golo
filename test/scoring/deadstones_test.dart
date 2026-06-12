import 'dart:math';

import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);
  final unfinishedBoard = boardFromSigns(unfinishedGameData);

  group('playTillEnd', () {
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

    test('is deterministic for a given seed', () {
      final pseudo = PseudoBoard.fromBoard(unfinishedBoard);

      expect(playTillEnd(pseudo, 1, Random(5)).data,
          playTillEnd(pseudo, 1, Random(5)).data);
    });
  });

  group('getProbabilityMap', () {
    test('should not mutate board data', () {
      final before = finishedBoard.clone();

      getProbabilityMap(finishedBoard, iterations: 50, seed: 42);

      expect(finishedBoard.diff(before), isEmpty);
    });

    test('should contain values between -1 and 1', () {
      final map = getProbabilityMap(unfinishedBoard, iterations: 50, seed: 42);

      expect(map.length, unfinishedBoard.height);
      expect(map.every((row) => row.length == unfinishedBoard.width), isTrue);
      expect(map.every((row) => row.every((x) => -1 <= x && x <= 1)), isTrue);
    });

    test('is deterministic for a given seed', () {
      expect(getProbabilityMap(unfinishedBoard, iterations: 20, seed: 7),
          getProbabilityMap(unfinishedBoard, iterations: 20, seed: 7));
    });
  });

  group('getFloatingStones', () {
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
  });

  group('guess', () {
    test('should not mutate board data', () {
      final before = finishedBoard.clone();

      guess(finishedBoard, finished: true, seed: 42);

      expect(finishedBoard.diff(before), isEmpty);
    });

    test('should detect some dead stones from unfinished games', () {
      final dead = guess(unfinishedBoard, seed: 42);

      expect(dead, isNotEmpty);
      expect(dead.every((v) => unfinishedBoard.get(v) != null), isTrue);
    });

    test('should detect floating stones from finished games', () {
      final dead = guess(finishedBoard, finished: true, seed: 42);
      final floating = getFloatingStones(finishedBoard);

      expect(floating.every(dead.contains), isTrue);
    });

    test('is deterministic for a given seed', () {
      expect(guess(unfinishedBoard, iterations: 20, seed: 7),
          guess(unfinishedBoard, iterations: 20, seed: 7));
    });
  });
}
