import 'package:test/test.dart';
import 'package:golo/sgf.dart';
import 'package:golo/src/node.dart';

void main() {
  group('GameTree', () {
    Node n(int id) => Node(id, null, {}, []);

    test('constructs from nodes and supports indexing', () {
      final nodes = [n(0), n(1), n(2)];
      final tree = GameTree(nodes);
      expect(tree.length, 3);
      expect(tree[0].id, 0);
      expect(tree[1].id, 1);
      expect(tree[2].id, 2);
      tree[1] = n(42);
      expect(tree[1].id, 42);
    });

    test('is independent of original list mutations', () {
      final orig = [n(0), n(1)];
      final tree = GameTree(orig);
      expect(tree.length, 2);
      expect(tree[0].id, 0);
      orig[0] = n(99);
      orig.add(n(2));
      expect(tree.length, 2);
      expect(tree[0].id, 0);
      tree[1] = n(77);
      expect(orig[1].id, 1);
    });

    test('supports shrinking via length setter', () {
      final tree = GameTree([n(0), n(1), n(2)]);
      expect(tree.length, 3);
      tree.length = 1;
      expect(tree.length, 1);
      expect(tree[0].id, 0);
      expect(() => tree[1], throwsRangeError);
    });
  });

  group('toSGF', () {
    final singleTree = GameTree([
      Node(0, null, {
        'B': ['aa'],
        'SZ': ['19'],
      }, [
        Node(1, 0, {
          'AB': ['cc', 'dd:ee']
        }, [])
      ]),
    ]);

    final tree = GameTree([
      Node(0, null, {
        'B': ['aa'],
        'SZ': ['19'],
      }, [
        Node(1, 0, {
          'AB': ['cc', 'dd:ee']
        }, [])
      ]),
      Node(2, null, {
        'CP': ['Copyright'],
      }, [
        Node(3, 2, {
          'B': ['ab']
        }, []),
        Node(4, 2, {
          'W': ['ac']
        }, []),
      ]),
    ]);

    test(
      'should stringify single game tree with parenthesis',
      () {
        expect(
          singleTree.toSgf(),
          '''(
  ;B[aa]SZ[19]
  ;AB[cc][dd:ee]
)
''',
        );
      },
    );

    test(
      'should stringify multiple game trees with correct indentation',
      () {
        expect(
          tree.toSgf(),
          '''(
  ;B[aa]SZ[19]
  ;AB[cc][dd:ee]
)(
  ;CP[Copyright]
  (
    ;B[ab]
  )(
    ;W[ac]
  )
)
''',
        );
      },
    );

    test('should respect line break option', () {
      final s = tree.toSgf(linebreak: '');
      expect(
        s,
        '(;B[aa]SZ[19];AB[cc][dd:ee])(;CP[Copyright](;B[ab])(;W[ac]))',
      );
    });

    test('should ignore mixed case node properties', () {
      expect(
        GameTree([
          Node(10, null, {
            'B': ['ab'],
            'board': ['should ignore'],
          }, [])
        ]),
        ';B[ab]\n',
      );
    });
  });
}
