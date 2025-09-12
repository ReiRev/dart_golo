import 'dart:io';
import 'package:golo/sgf.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  group('Parser', () {
    test('should parse multiple nodes', () {
      final parsed = Parser().parse('(;B[aa]SZ[19];AB[cc][dd:ee])');
      final expected = RecursiveNode(
        0,
        null,
        {
          'B': ['aa'],
          'SZ': ['19'],
        },
        [
          RecursiveNode(
            1,
            0,
            {
              'AB': ['cc', 'dd:ee'],
            },
            [],
          )
        ],
      );
      expect(DeepCollectionEquality().equals(parsed.children.first, expected), true);
    });

    test('should not omit CA property', () {
      final parsed = Parser().parse('(;B[aa]CA[UTF-8])');
      final expected = RecursiveNode(
        0,
        null,
        {
          'B': ['aa'],
          'CA': ['UTF-8'],
        },
        [],
      );
      expect(DeepCollectionEquality().equals(parsed.children.first, expected), true);
    });

    test('should parse variations', () {
      final parsed = Parser().parse('(;B[hh](;W[ii])(;W[hi]C[h]))');
      final expected = RecursiveNode(
        0,
        null,
        {
          'B': ['hh'],
        },
        [
          RecursiveNode(
            1,
            0,
            {
              'W': ['ii'],
            },
            [],
          ),
          RecursiveNode(
            2,
            0,
            {
              'W': ['hi'],
              'C': ['h'],
            },
            [],
          ),
        ],
      );
      expect(DeepCollectionEquality().equals(parsed.children.first, expected), true);
    });

    test('should emit onNodeCreated correctly', () {
      final nodes = <RecursiveNode>[];

      Parser().parse('(;B[hh](;W[ii])(;W[hi];C[h]))', onNodeCreated: (node) {
        nodes.add(RecursiveNode(node.id, node.parentId, node.data, []));
      });

      final expected = [
        RecursiveNode(0, null, {
          'B': ['hh'],
        }, []),
        RecursiveNode(1, 0, {
          'W': ['ii'],
        }, []),
        RecursiveNode(2, 0, {
          'W': ['hi'],
        }, []),
        RecursiveNode(3, 2, {
          'C': ['h'],
        }, []),
      ];

      expect(DeepCollectionEquality().equals(nodes, expected), true);
    });

    test('should convert lower case properties', () {
      // https://www.red-bean.com/sgf/sgf4.html
      // Property-identifiers are defined as keywords using only uppercase letters.
      final parsed = Parser()
          .parse('(;CoPyright[hello](;White[ii])(;White[hi]Comment[h]))');
      final expected = RecursiveNode(
        0,
        null,
        {
          'CP': ['hello'],
        },
        [
          RecursiveNode(1, 0, {
            'W': ['ii'],
          }, []),
          RecursiveNode(2, 0, {
            'W': ['hi'],
            'C': ['h'],
          }, []),
        ],
      );
      expect(DeepCollectionEquality().equals(parsed.children.first, expected), true);
    });

    test('should parse a relatively complex file', () {
      final filePath = 'test/sgf/files/complex.sgf';
      final contents = File(filePath).readAsStringSync();
      final tree = Parser().parse(contents);
      final topLevelCount = tree.id < 0 ? tree.children.length : 1;
      expect(topLevelCount, 1);
    });

    test('should be able to parse nodes outside a game', () {
      final tree1 = Parser().parse(';B[hh];W[ii]');
      final tree2 = Parser().parse('(;B[hh];W[ii])');
      expect(
        DeepCollectionEquality().equals(_normalizeRoot(tree1), _normalizeRoot(tree2)),
        true,
      );
    });

    test('should be able to correctly parse a game that misses initial ;', () {
      final t1 = Parser().parse('B[hh];W[ii]');
      final t2 = Parser().parse('(B[hh];W[ii])');
      final t3 = Parser().parse('(;B[hh];W[ii])');
      expect(
        DeepCollectionEquality().equals(_normalizeRoot(t1), _normalizeRoot(t3)),
        true,
      );
      expect(
        DeepCollectionEquality().equals(_normalizeRoot(t2), _normalizeRoot(t3)),
        true,
      );
    });

    test('should ignore empty variations', () {
      final parsed = Parser().parse('(;B[hh]()(;W[ii])()(;W[hi]C[h]))');
      final expected = RecursiveNode(
        0,
        null,
        {
          'B': ['hh'],
        },
        [
          RecursiveNode(1, 0, {
            'W': ['ii'],
          }, []),
          RecursiveNode(2, 0, {
            'W': ['hi'],
            'C': ['h'],
          }, []),
        ],
      );
      expect(DeepCollectionEquality().equals(parsed.children.first, expected), true);
    });
  });
}

RecursiveNode _normalizeRoot(RecursiveNode tree) {
  return tree.id < 0 && tree.children.isNotEmpty ? tree.children.first : tree;
}
