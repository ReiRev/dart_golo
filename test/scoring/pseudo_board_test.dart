import 'package:golo/golo.dart';
import 'package:test/test.dart';

import 'data.dart';

void main() {
  final finishedBoard = boardFromSigns(finishedGameData);

  group('PseudoBoard', () {
    test('fromBoard maps stones to signs', () {
      final pseudo = PseudoBoard.fromBoard(finishedBoard);

      expect(pseudo.width, 19);
      expect(pseudo.height, 19);
      expect(pseudo.data, finishedGameData.expand((row) => row).toList());
    });

    test('flat index and vertex conversions are inverses', () {
      final pseudo = PseudoBoard.fromBoard(finishedBoard);

      expect(pseudo.vertexToIndex((x: 3, y: 2)), 2 * 19 + 3);
      expect(pseudo.indexToVertex(2 * 19 + 3), (x: 3, y: 2));

      for (var v = 0; v < pseudo.data.length; v++) {
        expect(pseudo.vertexToIndex(pseudo.indexToVertex(v)), v);
      }
    });

    test('get returns null out of board and set ignores out of board', () {
      final pseudo = PseudoBoard([0, 1, -1, 0], 2);

      expect(pseudo.get(1), 1);
      expect(pseudo.get(-1), isNull);
      expect(pseudo.get(4), isNull);

      pseudo.set(-1, 1);
      pseudo.set(4, 1);
      expect(pseudo.data, [0, 1, -1, 0]);
    });

    test('getNeighbors stays on the board', () {
      final pseudo = PseudoBoard(List.filled(9, 0), 3);

      expect(pseudo.getNeighbors(0), unorderedEquals([1, 3]));
      expect(pseudo.getNeighbors(4), unorderedEquals([1, 3, 5, 7]));
      expect(pseudo.getNeighbors(8), unorderedEquals([5, 7]));
    });

    test('getChain and hasLiberties', () {
      // . X X
      // X O .
      // . O .
      final pseudo = PseudoBoard([0, 1, 1, 1, -1, 0, 0, -1, 0], 3);

      expect(pseudo.getChain(1), unorderedEquals([1, 2]));
      expect(pseudo.getChain(4), unorderedEquals([4, 7]));
      expect(pseudo.hasLiberties(4), isTrue);
      expect(pseudo.hasLiberties(1), isTrue);

      pseudo.set(5, 1);
      pseudo.set(8, 1);
      pseudo.set(6, 1);
      expect(pseudo.hasLiberties(4), isFalse);
    });

    test('getConnectedComponent collects vertices by sign', () {
      // . X X
      // X O .
      // . O .
      final pseudo = PseudoBoard([0, 1, 1, 1, -1, 0, 0, -1, 0], 3);

      expect(pseudo.getConnectedComponent(4, {-1, 0}),
          unorderedEquals([4, 5, 6, 7, 8]));
    });

    test('makePseudoMove rejects filling an own eye', () {
      // X X .
      // X . X
      // . X X
      final pseudo = PseudoBoard([1, 1, 0, 1, 0, 1, 0, 1, 1], 3);

      expect(pseudo.makePseudoMove(4, 1), isNull);
      expect(pseudo.data, [1, 1, 0, 1, 0, 1, 0, 1, 1]);
    });

    test('makePseudoMove rolls back suicide', () {
      // O O .
      // O . O
      // . O O
      final pseudo = PseudoBoard([-1, -1, 0, -1, 0, -1, 0, -1, -1], 3);

      expect(pseudo.makePseudoMove(4, 1), isNull);
      expect(pseudo.data, [-1, -1, 0, -1, 0, -1, 0, -1, -1]);
    });

    test('makePseudoMove captures dead neighbors', () {
      // . X O
      // X O O
      // O O .
      final pseudo = PseudoBoard([0, 1, -1, 1, -1, -1, -1, -1, 0], 3);

      final freed = pseudo.makePseudoMove(0, -1);

      expect(freed, unorderedEquals([1, 3]));
      expect(pseudo.data, [-1, 0, -1, 0, -1, -1, -1, -1, 0]);
    });
  });
}
