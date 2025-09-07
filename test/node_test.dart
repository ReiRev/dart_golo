import 'package:test/test.dart';
import 'package:golo/sgf.dart';
import 'package:golo/golo.dart';

void main() {
  group('Node helpers', () {
    test('Node.move creates B move with SGF coords', () {
      final n = Node.move(1, 0, Stone.black, (x: 3, y: 3));
      expect(n.id, 1);
      expect(n.parentId, 0);
      expect(n.data['B'], isNotNull);
      expect(n.data['B']!.first, 'dd');
      expect(n.data['W'], isNull);
    });

    test('Node.move creates W move with SGF coords', () {
      final n = Node.move(2, 1, Stone.white, (x: 4, y: 3));
      expect(n.data['W']!.first, 'ed');
      expect(n.data['B'], isNull);
    });

    test('Node.black/Node.white named constructors', () {
      final b = Node.black(5, 0, (x: 3, y: 3));
      expect(b.data['B']!.first, 'dd');
      expect(b.parentId, 0);
      final w = Node.white(6, 5, (x: 4, y: 3));
      expect(w.data['W']!.first, 'ed');
      expect(w.parentId, 5);
    });

    test('Node.pass creates empty value for color', () {
      final bpass = Node.pass(3, 2, Stone.black);
      expect(bpass.data['B']!.first, '');
      final wpass = Node.pass(4, 3, Stone.white);
      expect(wpass.data['W']!.first, '');
    });

    test('addStone/addBlack/addWhite mutate node data correctly', () {
      final n = Node(10, 0, {}, []);
      n.addBlack((x: 1, y: 2));
      expect(n.data['B']!.first, 'bc');
      n.addWhite((x: 0, y: 0));
      expect(n.data['W']!.first, 'aa');
      n.addStone(Stone.white, (x: 2, y: 1));
      expect(n.data['W']!.first, 'cb');
    });
  });
}
