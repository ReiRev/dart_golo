// ignore_for_file: lines_longer_than_80_chars
import 'package:golo/golo.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';
import './data.dart' as data;

void main() {
  group('Board', () {
    group('constructor', () {
      test('creates board', () {
        final board = Board([
          [null, null, null],
          [null, null, null]
        ]);
        expect(board.width, 3);
        expect(board.height, 2);

        for (var x = 0; x < board.width; x++) {
          for (var y = 0; y < board.height; y++) {
            expect(board.get((x: x, y: y)), null);
          }
        }

        expect(board.getCaptures(Stone.black), 0);
        expect(board.getCaptures(Stone.white), 0);
      });

      test('throws error with un-uniform board size', () {
        expect(
            () => Board([
                  [null, null, null],
                  [null, null],
                  [null, null, null]
                ]),
            throwsA(isA<ArgumentError>()));
      });
    });

    group('creates board from dimension', () {
      test('with width and height', () {
        final board = Board.fromDimension(5, 4);
        expect(board.width, 5);
        expect(board.height, 4);
      });

      test('with width', () {
        final board = Board.fromDimension(5);
        expect(board.width, 5);
        expect(board.height, 5);
      });
    });

    group('has', () {
      test('should return true when vertex is on board', () {
        final board = Board.fromDimension(19);
        expect(board.has((x: 0, y: 0)), true);
        expect(board.has((x: 13, y: 18)), true);
        expect(board.has((x: 5, y: 4)), true);
      });

      test('should return false when vertex is not on board', () {
        final board = Board.fromDimension(19);
        expect(board.has((x: -1, y: -1)), false);
        expect(board.has((x: 5, y: -1)), false);
        expect(board.has((x: board.width, y: 0)), false);
        expect(board.has((x: board.width, y: board.height)), false);
      });
    });

    test('clear', () {
      final board = Board.fromDimension(9, 9);
      board.set(
        (x: 0, y: 0),
        Stone.black,
      ).set(
        (x: 1, y: 1),
        Stone.white,
      ).set(
        (x: 3, y: 5),
        Stone.black,
      );
      board.clear();
      expect(
          DeepCollectionEquality()
              .equals(board.state, Board.fromDimension(9, 9).state),
          true);
    });

    group('makeMove', () {
      test('should throw error for moves outside the board', () {
        final board = Board.fromDimension(19);
        expect(
          () => board
              .makeMove((x: -1, y: 0), Stone.black, preventOutOfBoard: true),
          throwsA(
            isA<IllegalMoveException>().having(
              (e) => e.reason,
              'reason',
              IllegalMoveReason.outOfBoard,
            ),
          ),
        );
        expect(
          () => board
              .makeMove((x: 19, y: 0), Stone.white, preventOutOfBoard: true),
          throwsA(
            isA<IllegalMoveException>().having(
              (e) => e.reason,
              'reason',
              IllegalMoveReason.outOfBoard,
            ),
          ),
        );
        expect(
          () => board
              .makeMove((x: 0, y: -1), Stone.black, preventOutOfBoard: true),
          throwsA(
            isA<IllegalMoveException>().having(
              (e) => e.reason,
              'reason',
              IllegalMoveReason.outOfBoard,
            ),
          ),
        );
        expect(
          () => board
              .makeMove((x: 0, y: 19), Stone.white, preventOutOfBoard: true),
          throwsA(
            isA<IllegalMoveException>().having(
              (e) => e.reason,
              'reason',
              IllegalMoveReason.outOfBoard,
            ),
          ),
        );
      });
      test('should not mutate board', () {
        final board = Board.fromDimension(19);
        board.makeMove((x: 5, y: 5), Stone.black);

        expect(
          DeepCollectionEquality()
              .equals(board.state, Board.fromDimension(19).state),
          true,
        );
      });

      test('should make a move', () {
        final board = Board.fromDimension(19);
        final move = board.makeMove((x: 5, y: 5), Stone.black);
        board.set((x: 5, y: 5), Stone.black);

        expect(
          DeepCollectionEquality().equals(board.state, move.state),
          true,
        );
      });

      test('should remove captured stones', () {
        var board = Board.fromDimension(19);
        final black = [
          (x: 0, y: 1),
          (x: 1, y: 0),
          (x: 1, y: 2),
          (x: 2, y: 0),
          (x: 2, y: 2),
        ];
        final white = [
          (x: 1, y: 1),
          (x: 2, y: 1),
        ];
        for (final v in black) {
          board.set(v, Stone.black);
        }
        for (final v in white) {
          board.set(v, Stone.white);
        }

        final move = board.makeMove((x: 3, y: 1), Stone.black);

        expect(move.get((x: 3, y: 1)), Stone.black);
        for (final v in black) {
          expect(move.get(v), Stone.black);
        }
        for (final v in white) {
          expect(move.get(v), null);
        }

        board = Board.fromDimension(19);
        board.set((x: 0, y: 1), Stone.black).set((x: 0, y: 0), Stone.white);
        final move2 = board.makeMove((x: 1, y: 0), Stone.black);
        expect(move2.get((x: 0, y: 0)), null);
        expect(move2.get((x: 1, y: 0)), Stone.black);
        expect(move2.get((x: 0, y: 1)), Stone.black);
      });

      test('should count captures correctly', () {
        var board = Board.fromDimension(19);
        final black = [
          (x: 0, y: 1),
          (x: 1, y: 0),
          (x: 1, y: 2),
          (x: 2, y: 0),
          (x: 2, y: 2),
        ];
        final white = [
          (x: 1, y: 1),
          (x: 2, y: 1),
        ];
        for (final v in black) {
          board.set(v, Stone.black);
        }
        for (final v in white) {
          board.set(v, Stone.white);
        }
        final move = board.makeMove((x: 3, y: 1), Stone.black);
        expect(move.getCaptures(Stone.white), 0);
        expect(move.getCaptures(Stone.black), white.length);

        board = Board.fromDimension(19);
        board.set((x: 0, y: 1), Stone.black).set((x: 0, y: 0), Stone.white);
        final move2 = board.makeMove((x: 1, y: 0), Stone.black);
        expect(move2.getCaptures(Stone.white), 0);
        expect(move2.getCaptures(Stone.black), 1);
      });

      test('should handle suicide correctly', () {
        final board = Board.fromDimension(19);
        for (final v in [
          (x: 0, y: 1),
          (x: 1, y: 0),
          (x: 1, y: 2),
          (x: 2, y: 0),
          (x: 2, y: 2),
          (x: 3, y: 1),
        ]) {
          board.set(v, Stone.black);
        }
        board.set((x: 1, y: 1), Stone.white);
        final move = board.makeMove((x: 2, y: 1), Stone.white);
        expect(move.get((x: 1, y: 1)), null);
        expect(move.get((x: 2, y: 1)), null);
        expect(move.get((x: 3, y: 1)), Stone.black);
        expect(move.get((x: 1, y: 2)), Stone.black);
      });

      test('should prevent suicide if desired', () {
        final board = Board.fromDimension(19);
        for (final v in [
          (x: 0, y: 1),
          (x: 1, y: 0),
          (x: 1, y: 2),
          (x: 2, y: 0),
          (x: 2, y: 2),
          (x: 3, y: 1),
        ]) {
          board.set(v, Stone.black);
        }
        board.set((x: 1, y: 1), Stone.white);
        expect(
          () => board.makeMove((x: 2, y: 1), Stone.white, preventSuicide: true),
          throwsA(isA<IllegalMoveException>()),
        );
      });

      test('should handle stone overwrites correctly', () {
        final board = Board.fromDimension(19);
        for (final v in [
          (x: 10, y: 9),
          (x: 10, y: 10),
          (x: 10, y: 11),
        ]) {
          board.set(v, Stone.black);
        }
        for (final v in [
          (x: 10, y: 8),
          (x: 9, y: 9),
          (x: 11, y: 9),
        ]) {
          board.set(v, Stone.white);
        }
        final move = board.makeMove((x: 10, y: 10), Stone.white);
        expect(move.get((x: 10, y: 10)), Stone.white);
        expect(move.get((x: 10, y: 9)), null);
        expect(move.get((x: 10, y: 11)), Stone.black);
      });

      test('should prevent stone overwrites if desired', () {
        final board = Board.fromDimension(19);
        for (final v in [
          (x: 10, y: 9),
          (x: 10, y: 10),
          (x: 10, y: 11),
        ]) {
          board.set(v, Stone.black);
        }
        for (final v in [
          (x: 10, y: 8),
          (x: 9, y: 9),
          (x: 11, y: 9),
        ]) {
          board.set(v, Stone.white);
        }

        expect(
          () => board
              .makeMove((x: 10, y: 10), Stone.white, preventOverwrite: true),
          throwsA(isA<IllegalMoveException>()),
        );
      });

      test('should prevent ko if desired', () {
        var board = Board.fromDimension(19);
        final black = [
          (x: 0, y: 1),
          (x: 1, y: 0),
          (x: 1, y: 2),
          (x: 2, y: 1),
        ];
        final white = [
          (x: 2, y: 0),
          (x: 2, y: 2),
          (x: 3, y: 1),
        ];
        for (final v in black) {
          board.set(v, Stone.black);
        }
        for (final v in white) {
          board.set(v, Stone.white);
        }
        final move = board.makeMove((x: 1, y: 1), Stone.white);
        expect(
          () => move.makeMove((x: 2, y: 1), Stone.black, preventKo: true),
          throwsA(isA<IllegalMoveException>()),
        );
      });
    });

    test('isSquare', () {
      final board = Board.fromDimension(15, 16);
      expect(board.isSquare(), false);

      expect(data.board.isSquare(), true);
    });

    test('isEmpty', () {
      final board = Board.fromDimension(15, 16);
      expect(board.isEmpty(), true);

      expect(data.board.isEmpty(), false);
    });

    group('isValid', () {
      test('should return true for valid board arrangements', () {
        final board = Board.fromDimension(19);
        expect(board.isValid(), true);

        board.set((x: 1, y: 1), Stone.black).set((x: 1, y: 2), Stone.white);
        expect(board.isValid(), true);
      });

      test('should return false for non-valid board arrangements', () {
        var board = Board.fromDimension(19);
        for (final xy in [
          [1, 0],
          [0, 1],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.black);
        }
        board.set((x: 0, y: 0), Stone.white);
        expect(board.isValid(), false);

        board = Board.fromDimension(19);
        for (final xy in [
          [0, 1],
          [1, 0],
          [1, 2],
          [2, 0],
          [2, 2],
          [3, 1],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.black);
        }
        for (final xy in [
          [1, 1],
          [2, 1],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.white);
        }
        expect(board.isValid(), false);
      });
    });

    group('getDistance', () {
      test('should compute Manhattan distance', () {
        final board = Board.fromDimension(19);
        expect(board.getDistance((x: 1, y: 2), (x: 8, y: 4)), 9);
        expect(board.getDistance((x: -1, y: -2), (x: 8, y: 4)), 15);
      });
    });

    group('getNeighbors', () {
      test('should return neighbors for vertices in the middle', () {
        final board = Board.fromDimension(19);
        expect(
          DeepCollectionEquality().equals(
            board.getNeighbors((x: 1, y: 1)),
            [
              (x: 0, y: 1),
              (x: 2, y: 1),
              (x: 1, y: 0),
              (x: 1, y: 2),
            ],
          ),
          true,
        );
      });

      test('should return neighbors for vertices on the side', () {
        final board = Board.fromDimension(19);
        expect(
          DeepCollectionEquality().equals(
            board.getNeighbors((x: 1, y: 0)),
            [
              (x: 0, y: 0),
              (x: 2, y: 0),
              (x: 1, y: 1),
            ],
          ),
          true,
        );
      });

      test('should return neighbors for vertices in the corner', () {
        final board = Board.fromDimension(19);
        expect(
          DeepCollectionEquality().equals(
            board.getNeighbors((x: 0, y: 0)),
            [
              (x: 1, y: 0),
              (x: 0, y: 1),
            ],
          ),
          true,
        );
      });

      test('should return empty list for vertices not on board', () {
        final board = Board.fromDimension(19);
        expect(
          DeepCollectionEquality().equals(
            board.getNeighbors((x: -1, y: -1)),
            [],
          ),
          true,
        );
      });
    });

    group('getConnectedComponent', () {
      test('should be able to return the chain of a vertex', () {
        final board = Board.fromDimension(19);
        for (final xy in [
          [0, 1],
          [1, 0],
          [1, 2],
          [2, 0],
          [2, 2],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.black);
        }
        for (final xy in [
          [1, 1],
          [2, 1],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.white);
        }

        expect(
          UnorderedIterableEquality().equals(
            board.getConnectedComponent(
              (x: 1, y: 1),
              (v) => board.get(v) == Stone.white,
            ),
            [(x: 1, y: 1), (x: 2, y: 1)],
          ),
          true,
        );
      });

      test('should be able to return the stone connected component of a vertex',
          () {
        final board = Board.fromDimension(19);
        for (final xy in [
          [0, 1],
          [1, 0],
          [1, 2],
          [2, 0],
          [2, 2],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.black);
        }
        for (final xy in [
          [1, 1],
          [2, 1],
        ]) {
          board.set((x: xy[0], y: xy[1]), Stone.white);
        }

        expect(
          UnorderedIterableEquality().equals(
            board.getConnectedComponent(
              (x: 1, y: 1),
              (v) => board.get(v) != null,
            ),
            [
              (x: 0, y: 1),
              (x: 1, y: 0),
              (x: 1, y: 1),
              (x: 1, y: 2),
              (x: 2, y: 0),
              (x: 2, y: 1),
              (x: 2, y: 2),
            ],
          ),
          true,
        );
      });
    });

    group('getRelatedChains', () {
      test('should return empty for isolated empty vertex', () {
        expect(
          DeepCollectionEquality().equals(
            data.board.getRelatedChains((x: 0, y: 0)),
            [],
          ),
          true,
        );
      });

      test('should return related chains for sample board', () {
        expect(
          UnorderedIterableEquality().equals(
            data.board.getRelatedChains((x: 3, y: 0)),
            [
              (x: 3, y: 0),
              (x: 2, y: 1),
              (x: 4, y: 1),
              (x: 4, y: 0),
              (x: 5, y: 0),
              (x: 4, y: 2),
              (x: 3, y: 2),
              (x: 2, y: 2),
              (x: 4, y: 3),
              (x: 5, y: 3),
              (x: 4, y: 4),
              (x: 2, y: 5),
              (x: 5, y: 5),
              (x: 6, y: 5),
              (x: 6, y: 4),
              (x: 4, y: 6),
              (x: 3, y: 6),
              (x: 2, y: 7),
              (x: 2, y: 8),
              (x: 2, y: 9),
              (x: 2, y: 10),
              (x: 1, y: 10),
              (x: 0, y: 10),
              (x: 0, y: 11),
              (x: 3, y: 10),
              (x: 2, y: 11),
              (x: 4, y: 11),
              (x: 5, y: 11),
              (x: 6, y: 11),
              (x: 7, y: 11),
              (x: 8, y: 11),
              (x: 9, y: 11),
              (x: 9, y: 10),
              (x: 7, y: 10),
              (x: 7, y: 9),
              (x: 6, y: 9),
              (x: 5, y: 9),
              (x: 8, y: 9),
              (x: 8, y: 8),
              (x: 7, y: 7),
              (x: 8, y: 7),
              (x: 8, y: 12),
              (x: 8, y: 13),
              (x: 8, y: 14),
              (x: 9, y: 14),
              (x: 10, y: 15),
              (x: 9, y: 15),
              (x: 8, y: 16),
              (x: 7, y: 17),
              (x: 7, y: 18),
              (x: 6, y: 18),
              (x: 5, y: 18),
              (x: 4, y: 18),
              (x: 4, y: 17),
              (x: 8, y: 18),
              (x: 10, y: 18),
              (x: 11, y: 18),
              (x: 10, y: 17),
              (x: 9, y: 17),
              (x: 10, y: 16),
              (x: 11, y: 16),
              (x: 4, y: 12),
              (x: 3, y: 8),
            ],
          ),
          true,
        );
      });
    });

    group('(has|get)Liberties', () {
      test('should return the liberties of the chain of the given vertex', () {
        final board = Board.fromDimension(19);
        board.set((x: 1, y: 1), Stone.white).set((x: 2, y: 1), Stone.white);
        expect(
          UnorderedIterableEquality().equals(
            board.getLiberties((x: 1, y: 1)),
            [
              (x: 0, y: 1),
              (x: 1, y: 0),
              (x: 1, y: 2),
              (x: 2, y: 0),
              (x: 2, y: 2),
              (x: 3, y: 1),
            ],
          ),
          true,
        );
        expect(board.hasLiberties((x: 1, y: 1)), true);
        expect(
          DeepCollectionEquality().equals(
            board.getLiberties((x: 1, y: 2)),
            [],
          ),
          true,
        );
        expect(board.hasLiberties((x: 1, y: 2)), false);
      });

      test('should return empty list for a vertex not on the board', () {
        final board = Board.fromDimension(19);
        expect(
          DeepCollectionEquality().equals(
            board.getLiberties((x: -1, y: -1)),
            [],
          ),
          true,
        );
        expect(board.hasLiberties((x: -1, y: -1)), false);
      });
    });

    test('clone', () {
      final board = Board.fromDimension(19);
      for (final xy in [
        [0, 1],
        [1, 0],
        [1, 2],
        [2, 0],
        [2, 2],
      ]) {
        board.set((x: xy[0], y: xy[1]), Stone.black);
      }
      for (final xy in [
        [1, 1],
        [2, 1],
      ]) {
        board.set((x: xy[0], y: xy[1]), Stone.white);
      }

      final clone = board.clone();

      expect(identical(board.state, clone.state), false);
      expect(
        DeepCollectionEquality().equals(board.state, clone.state),
        true,
      );
    });

    group('diff', () {
      test('should compute differences between boards', () {
        final board1 = Board.fromDimension(9, 9);
        final board2 = board1.makeMove((x: 3, y: 3), Stone.black).set(
            (x: 4, y: 4), Stone.black).set((x: 3, y: 4), Stone.black);

        expect(
          DeepCollectionEquality().equals(
            board1.diff(board2),
            board2.diff(board1),
          ),
          true,
        );

        final expected = [
          (x: 3, y: 3),
          (x: 3, y: 4),
          (x: 4, y: 4),
        ];
        expect(
          UnorderedIterableEquality().equals(board1.diff(board2), expected),
          true,
        );

        final board3 = Board.fromDimension(8, 9);
        expect(board1.diff(board3), board3.diff(board1));
        expect(board1.diff(board3), null);
      });
    });

    group('stringifyVertex', () {
      test('should stringify vertex to Go coordinates', () {
        expect(data.board.stringifyVertex((x: 3, y: 3)), 'D16');
        expect(data.board.stringifyVertex((x: 16, y: 14)), 'R5');
        expect(data.board.stringifyVertex((x: -1, y: 14)), '');
        expect(data.board.stringifyVertex((x: 0, y: 19)), '');
      });
    });

    group('parseVertex', () {
      test('should parse Go coordinates to vertex', () {
        expect(data.board.parseVertex('d16'), (x: 3, y: 3));
        expect(data.board.parseVertex('R5'), (x: 16, y: 14));
        expect(data.board.parseVertex('R'), null);
        expect(data.board.parseVertex('Z3'), null);
        expect(data.board.parseVertex('pass'), null);
        expect(data.board.parseVertex(''), null);
      });
    });

    group('getHandicapPlacement', () {
      test('should return empty array for small boards', () {
        expect(
          DeepCollectionEquality().equals(
            Board.fromDimension(6, 19).getHandicapPlacement(9),
            [],
          ),
          true,
        );
        expect(
          DeepCollectionEquality().equals(
            Board.fromDimension(6, 6).getHandicapPlacement(9),
            [],
          ),
          true,
        );
      });

      test('should not return tengen for even dimensions', () {
        final square = Board.fromDimension(8, 8).getHandicapPlacement(9);
        final portrait = Board.fromDimension(8, 11).getHandicapPlacement(9);
        final landscape = Board.fromDimension(11, 8).getHandicapPlacement(9);

        expect(square.any((v) => v.x == 4 && v.y == 4), false);
        expect(portrait.any((v) => v.x == 4 && v.y == 5), false);
        expect(landscape.any((v) => v.x == 5 && v.y == 4), false);
      });

      test('should return tengen for odd dimensions', () {
        final square = Board.fromDimension(9, 9).getHandicapPlacement(9);
        final portrait = Board.fromDimension(9, 11).getHandicapPlacement(9);
        final landscape = Board.fromDimension(11, 9).getHandicapPlacement(9);

        expect(square.any((v) => v.x == 4 && v.y == 4), true);
        expect(portrait.any((v) => v.x == 4 && v.y == 5), true);
        expect(landscape.any((v) => v.x == 5 && v.y == 4), true);
      });
    });
  });
}
