import 'package:golo/sgf.dart';
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
  });
}
