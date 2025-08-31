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
        Token(TokenType.propertyIdentifier, 'B', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[aa]', 0, 3, 3, 3 / len),
        Token(TokenType.propertyIdentifier, 'SZ', 0, 7, 7, 7 / len),
        Token(TokenType.propertyValue, '[19]', 0, 9, 9, 9 / len),
        Token(TokenType.semicolon, ';', 1, 0, 14, 14 / len),
        Token(TokenType.propertyIdentifier, 'AB', 1, 1, 15, 15 / len),
        Token(TokenType.propertyValue, '[cc]', 1, 3, 17, 17 / len),
        Token(TokenType.propertyValue, '[dd:ee]', 2, 0, 22, 22 / len),
        Token(TokenType.parenthesis, ')', 2, 7, 29, 29 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });

    test('should take escaping values into account', () {
      var contents = '(;C[hello\\]world];C[hello\\\\];C[hello])';
      var len = contents.length - 1;
      var actual = TokenIterable(contents).toList();
      var expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[hello\\]world]', 0, 3, 3, 3 / len),
        Token(TokenType.semicolon, ';', 0, 17, 17, 17 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 18, 18, 18 / len),
        Token(TokenType.propertyValue, '[hello\\\\]', 0, 19, 19, 19 / len),
        Token(TokenType.semicolon, ';', 0, 28, 28, 28 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 29, 29, 29 / len),
        Token(TokenType.propertyValue, '[hello]', 0, 30, 30, 30 / len),
        Token(TokenType.parenthesis, ')', 0, 37, 37, 37 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);

      contents = '(;C[\\];B[aa];W[bb])';
      len = contents.length - 1;
      actual = TokenIterable(contents).toList();
      expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[\\];B[aa]', 0, 3, 3, 3 / len),
        Token(TokenType.semicolon, ';', 0, 12, 12, 12 / len),
        Token(TokenType.propertyIdentifier, 'W', 0, 13, 13, 13 / len),
        Token(TokenType.propertyValue, '[bb]', 0, 14, 14, 14 / len),
        Token(TokenType.parenthesis, ')', 0, 18, 18, 18 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });

    test('should allow lower case properties', () {
      const contents = '(;CoPyright[blah])';
      final len = contents.length - 1;
      final actual = const TokenIterable(contents).toList();
      final expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propertyIdentifier, 'CoPyright', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[blah]', 0, 11, 11, 11 / len),
        Token(TokenType.parenthesis, ')', 0, 17, 17, 17 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });

    test('should take new lines inside token values into account', () {
      const contents = '(;C[bl\nah])';
      final len = contents.length - 1;
      final actual = const TokenIterable(contents).toList();
      final expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[bl\nah]', 0, 3, 3, 3 / len),
        Token(TokenType.parenthesis, ')', 1, 3, 10, 10 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });

    test('should return invalid tokens', () {
      const contents = '(;C[hi]%[invalid])';
      final len = contents.length - 1;
      final actual = const TokenIterable(contents).toList();
      final expected = [
        Token(TokenType.parenthesis, '(', 0, 0, 0, 0 / len),
        Token(TokenType.semicolon, ';', 0, 1, 1, 1 / len),
        Token(TokenType.propertyIdentifier, 'C', 0, 2, 2, 2 / len),
        Token(TokenType.propertyValue, '[hi]', 0, 3, 3, 3 / len),
        Token(TokenType.invalid, '%', 0, 7, 7, 7 / len),
        Token(TokenType.propertyValue, '[invalid]', 0, 8, 8, 8 / len),
        Token(TokenType.parenthesis, ')', 0, 17, 17, 17 / len),
      ];
      expect(DeepCollectionEquality().equals(actual, expected), isTrue);
    });
  });
}
