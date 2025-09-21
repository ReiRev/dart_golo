import 'package:test/test.dart';
import 'package:golo/golo.dart';

void main() {
  group('BoardTree', () {
    test('stores and clones board snapshots via Map API', () {
      final store = BoardTree();
      final id1 = 1;

      final b = Board.fromDimension(9, 9);
      store[id1] = b;

      // Returned snapshot is a clone
      final snap = store[id1]!;
      snap.set((x: 0, y: 0), Stone.black);
      expect(store[id1]!.get((x: 0, y: 0)), isNull);

      // keys/remove/clear
      expect(store.keys.contains(id1), true);
      final removed = store.remove(id1);
      expect(removed, isNotNull);
      expect(store[id1], isNull);

      final id2 = 2;
      store[id2] = Board.fromDimension(9, 9);
      expect(store[id2], isNotNull);
      store.clear();
      expect(store[id2], isNull);
    });

    test(
        'cursor + commitMove/commitPass operate on current snapshot and new ids',
        () {
      final store = BoardTree();
      final root = 100;
      store.init(root, Board.fromDimension(9, 9));
      store.moveTo(root);

      // Commit a move to new id
      final id1 = 101;
      final b1 = store.commitMove(id1, Stone.black, (x: 3, y: 3));
      expect(store.cursorId, id1);
      expect(b1.get((x: 3, y: 3)), Stone.black);
      expect(store[id1]!.get((x: 3, y: 3)), Stone.black);

      // Commit a pass to another id
      final id2 = 102;
      final b2 = store.commitPass(id2, Stone.white);
      expect(store.cursorId, id2);
      expect(b2.get((x: 3, y: 3)), Stone.black);
      expect(store[id2]!.get((x: 3, y: 3)), Stone.black);
    });
  });
}
