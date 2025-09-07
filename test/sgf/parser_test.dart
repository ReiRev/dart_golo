import 'dart:io';
import 'package:golo/sgf.dart';
import 'package:golo/golo.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  group('Parser', () {
    test('should parse multiple nodes', () {
      final parsed = Parser().parse('(;B[aa]SZ[19];AB[cc][dd:ee])');
      final expected = Node(
        0,
        null,
        {
          'B': ['aa'],
          'SZ': ['19'],
        },
        [
          Node(
            1,
            0,
            {
              'AB': ['cc', 'dd:ee'],
            },
            [],
          )
        ],
      );
      expect(DeepCollectionEquality().equals(parsed[0], expected), true);
    });

    test('should not omit CA property', () {
      final parsed = Parser().parse('(;B[aa]CA[UTF-8])');
      final expected = Node(
        0,
        null,
        {
          'B': ['aa'],
          'CA': ['UTF-8'],
        },
        [],
      );
      expect(DeepCollectionEquality().equals(parsed[0], expected), true);
    });

    test('should parse variations', () {
      final parsed = Parser().parse('(;B[hh](;W[ii])(;W[hi]C[h]))');
      final expected = Node(
        0,
        null,
        {
          'B': ['hh'],
        },
        [
          Node(
            1,
            0,
            {
              'W': ['ii'],
            },
            [],
          ),
          Node(
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
      expect(DeepCollectionEquality().equals(parsed[0], expected), true);
    });

    test('should emit onNodeCreated correctly', () {
      final nodes = <Node>[];

      Parser().parse('(;B[hh](;W[ii])(;W[hi];C[h]))', onNodeCreated: (node) {
        nodes.add(Node(node.id, node.parentId, node.data, []));
      });

      final expected = [
        Node(0, null, {
          'B': ['hh'],
        }, []),
        Node(1, 0, {
          'W': ['ii'],
        }, []),
        Node(2, 0, {
          'W': ['hi'],
        }, []),
        Node(3, 2, {
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
      final expected = Node(
        0,
        null,
        {
          'CP': ['hello'],
        },
        [
          Node(1, 0, {
            'W': ['ii'],
          }, []),
          Node(2, 0, {
            'W': ['hi'],
            'C': ['h'],
          }, []),
        ],
      );
      expect(DeepCollectionEquality().equals(parsed[0], expected), true);
    });

    test('should parse a relatively complex file', () {
      final filePath = 'test/sgf/files/complex.sgf';
      final contents = File(filePath).readAsStringSync();
      final trees = Parser().parse(contents);
      expect(trees.length, 1);
    });

    test('should be able to parse nodes outside a game', () {
      final trees1 = Parser().parse(';B[hh];W[ii]');
      final trees2 = Parser().parse('(;B[hh];W[ii])');
      expect(DeepCollectionEquality().equals(trees1, trees2), true);
    });

    test('should be able to correctly parse a game that misses initial ;', () {
      final trees1 = Parser().parse('B[hh];W[ii]');
      final trees2 = Parser().parse('(B[hh];W[ii])');
      final trees3 = Parser().parse('(;B[hh];W[ii])');
      expect(DeepCollectionEquality().equals(trees1, trees3), true);
      expect(DeepCollectionEquality().equals(trees2, trees3), true);
    });

    test('should ignore empty variations', () {
      final parsed = Parser().parse('(;B[hh]()(;W[ii])()(;W[hi]C[h]))');
      final expected = Node(
        0,
        null,
        {
          'B': ['hh'],
        },
        [
          Node(1, 0, {
            'W': ['ii'],
          }, []),
          Node(2, 0, {
            'W': ['hi'],
            'C': ['h'],
          }, []),
        ],
      );
      expect(DeepCollectionEquality().equals(parsed[0], expected), true);
    });
  });
}
