import 'package:golo/sgf.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  group('Tokenizer', () {
    test('should track source position correctly', () {
      const contents = '(;B[aa]SZ[19]\n;AB[cc]\n[dd:ee])';
      final len = contents.length - 1;
      final actual = const TokenIterable(contents).toList();
      final expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propIdent, 'B', 0, 2, 2, 2 / len),
        Token(TokenType.cValueType, '[aa]', 0, 3, 3, 3 / len),
        Token(TokenType.propIdent, 'SZ', 0, 7, 7, 7 / len),
        Token(TokenType.cValueType, '[19]', 0, 9, 9, 9 / len),
        Token(TokenType.semicolon, ';', 1, 0, 14, 14 / len),
        Token(TokenType.propIdent, 'AB', 1, 1, 15, 15 / len),
        Token(TokenType.cValueType, '[cc]', 1, 3, 17, 17 / len),
        Token(TokenType.cValueType, '[dd:ee]', 2, 0, 22, 22 / len),
        Token(TokenType.parenthesis, ')', 2, 7, 29, 29 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });
  });
}
