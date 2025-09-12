import 'package:test/test.dart';
import 'package:golo/golo.dart';

void main() {
  group('SgfTree', () {
    group('addRoot', () {
      test('adds a root node and sets cursor if null', () {
        final tree = SgfTree();
        final id = tree.addRoot(Node({}, []));
        expect(tree.rootNodes, [id]);
        expect(tree.cursorId, id);
        final id2 = tree.addRoot(Node({}, []));
        expect(tree.rootNodes, [id, id2]);
        expect(tree.cursorId, id);
      });
    });

    group('addChild', () {
      test('adds to specified parent', () {
        final tree = SgfTree();
        final root = tree.addRoot(Node({}, []));
        final child = tree.addChild(
            Node({
              'C': ['hello']
            }, []),
            parentId: root);
        expect(tree.nodeById(root)!.children, [child]);
        expect(tree.parentOf(child), root);
      });

      test('adds to cursor when parentId omitted', () {
        final tree = SgfTree();
        final root = tree.addRoot(Node({}, []));
        tree.moveTo(root);
        final child = tree.addChild(Node({}, []));
        expect(tree.nodeById(root)!.children, [child]);
      });
    });

    // Board snapshots are handled by BoardTree; no Map interface here.

    group('nodeById', () {
      test('returns the node for id', () {
        final tree = SgfTree();
        final root = tree.addRoot(Node({
          'GN': ['name']
        }, []));
        expect(tree.nodeById(root)!.data['GN']!.first, 'name');
      });
    });

    group('cursor', () {
      test('moveTo changes cursor when id exists', () {
        final tree = SgfTree();
        final a = tree.addRoot(Node({}, []));
        final b = tree.addRoot(Node({}, []));
        tree.moveTo(b);
        expect(tree.cursorId, b);
        tree.moveTo(999);
        expect(tree.cursorId, b);
      });
    });

    group('navigation', () {
      test('next/goNext/goNextAt/goBack', () {
        final tree = SgfTree();
        final root = tree.addRoot(Node({}, []));
        final c1 = tree.addChild(Node({}, []), parentId: root);
        final c2 = tree.addChild(Node({}, []), parentId: root);
        tree.moveTo(root);
        expect(tree.nextChildren, [c1, c2]);
        tree.goNext();
        expect(tree.cursorId, c1);
        tree.moveTo(root);
        tree.goNextAt(1);
        expect(tree.cursorId, c2);
        tree.goBack();
        expect(tree.cursorId, root);
      });

      test('goSibling cycles siblings and roots', () {
        final tree = SgfTree();
        final r1 = tree.addRoot(Node({}, []));
        final r2 = tree.addRoot(Node({}, []));
        final r3 = tree.addRoot(Node({}, []));
        tree.moveTo(r1);
        tree.goSibling();
        expect(tree.cursorId, r2);
        tree.goSibling();
        expect(tree.cursorId, r3);
        tree.goSibling();
        expect(tree.cursorId, r1);

        final c1 = tree.addChild(Node({}, []), parentId: r1);
        final c2 = tree.addChild(Node({}, []), parentId: r1);
        tree.moveTo(c1);
        tree.goSibling();
        expect(tree.cursorId, c2);
        tree.goSibling();
        expect(tree.cursorId, c1);
      });
    });

    group('parentOf', () {
      test('returns parent id or null for root', () {
        final tree = SgfTree();
        final r = tree.addRoot(Node({}, []));
        final c = tree.addChild(Node({}, []), parentId: r);
        expect(tree.parentOf(r), isNull);
        expect(tree.parentOf(c), r);
      });
    });

    group('data/dataAt/add', () {
      test('edits data at cursor and by id', () {
        final tree = SgfTree();
        final r = tree.addRoot(Node({}, []));
        tree.moveTo(r);
        tree.add('C', ['hello']);
        expect(tree.data['C']!.first, 'hello');
        expect(tree.dataAt(r)['C']!.first, 'hello');
      });
    });

    // Note: SgfTree no longer exposes addStone/addPass helpers.

    // Board application is handled by Game/BoardTree tests.

    group('toSgf', () {
      test('should stringify single game tree with parenthesis', () {
        final tree = SgfTree();
        final rootId = tree.addRoot(Node({
          'B': ['aa'],
          'SZ': ['19']
        }, []));
        tree.addChild(
            Node({
              'AB': ['cc', 'dd:ee']
            }, []),
            parentId: rootId);
        expect(
          tree.toSgf(),
          '''(\n  ;B[aa]SZ[19]\n  ;AB[cc][dd:ee]\n)\n''',
        );
      });

      test('should stringify multiple game trees with correct indentation', () {
        final tree = SgfTree();
        final r1 = tree.addRoot(Node({
          'B': ['aa'],
          'SZ': ['19']
        }, []));
        tree.addChild(
            Node({
              'AB': ['cc', 'dd:ee']
            }, []),
            parentId: r1);

        final r2 = tree.addRoot(Node({
          'CP': ['Copyright']
        }, []));
        tree.addChild(
            Node({
              'B': ['ab']
            }, []),
            parentId: r2);
        tree.addChild(
            Node({
              'W': ['ac']
            }, []),
            parentId: r2);
        expect(
          tree.toSgf(),
          '''(\n  ;B[aa]SZ[19]\n  ;AB[cc][dd:ee]\n)(\n  ;CP[Copyright]\n  (\n    ;B[ab]\n  )(\n    ;W[ac]\n  )\n)\n''',
        );
      });

      test('should respect line break option', () {
        final tree = SgfTree();
        final r1 = tree.addRoot(Node({
          'B': ['aa'],
          'SZ': ['19']
        }, []));
        tree.addChild(
            Node({
              'AB': ['cc', 'dd:ee']
            }, []),
            parentId: r1);

        final r2 = tree.addRoot(Node({
          'CP': ['Copyright']
        }, []));
        tree.addChild(
            Node({
              'B': ['ab']
            }, []),
            parentId: r2);
        tree.addChild(
            Node({
              'W': ['ac']
            }, []),
            parentId: r2);

        final s = tree.toSgf(linebreak: '');
        expect(
          s,
          '(;B[aa]SZ[19];AB[cc][dd:ee])(;CP[Copyright](;B[ab])(;W[ac]))',
        );
      });
    });
  });
}
