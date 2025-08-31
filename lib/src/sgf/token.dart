class Token {
  final TokenType type;
  final String value;
  final int row, col, pos;
  final double progress;
  const Token(
    this.type,
    this.value,
    this.row,
    this.col,
    this.pos,
    this.progress,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Token &&
            type == other.type &&
            value == other.value &&
            row == other.row &&
            col == other.col &&
            pos == other.pos &&
            progress == other.progress);
  }

  @override
  int get hashCode => Object.hash(type, value, row, col, pos, progress);
}

enum TokenType {
  parenthesis,
  semicolon,
  propIdent,
  cValueType,
  invalid,
}

/// An iterable wrapper that tokenizes the given [text] when iterated.
class TokenIterable extends Iterable<Token> {
  final String text;
  final bool ignoreWhitespace;
  final bool emitInvalid;
  final bool enableProgress;

  const TokenIterable(
    this.text, {
    this.ignoreWhitespace = true,
    this.emitInvalid = true,
    this.enableProgress = true,
  });

  // Reusable regexes
  static final RegExp reWhitespace = RegExp(r"\s+");
  static final RegExp reParen = RegExp(r"[()]");
  static final RegExp reSemicolon = RegExp(r";");
  static final RegExp reProp = RegExp(r"[A-Za-z]+");
  // SGF C value type: [ ... ] allowing escapes (e.g. \], \n), may contain newlines
  static final RegExp reCValue = RegExp(r"\[(?:\\.|[^\]])*\]");

  Iterable<Token> _scan() sync* {
    final text = this.text;
    final len = text.length;
    if (len == 0) return;

    final denom = (len - 1) <= 0 ? 1 : (len - 1);

    int pos = 0;
    int row = 0;
    int col = 0;

    Token makeToken(
      TokenType type,
      String lexeme,
      int startPos,
      int startRow,
      int startCol,
    ) {
      final progress = enableProgress ? (startPos / denom) : 0.0;
      return Token(type, lexeme, startRow, startCol, startPos, progress);
    }

    void advanceByLexeme(String lexeme) {
      for (var i = 0; i < lexeme.length; i++) {
        final ch = lexeme.codeUnitAt(i);
        if (ch == 0x0A) {
          // \n
          row += 1;
          col = 0;
        } else if (ch == 0x0D) {
          // \r (normalize CRLF)
          if (i + 1 < lexeme.length && lexeme.codeUnitAt(i + 1) == 0x0A) {
            i += 1; // consume LF after CR
          }
          row += 1;
          col = 0;
        } else {
          col += 1;
        }
      }
      pos += lexeme.length;
    }

    while (pos < len) {
      final ws = reWhitespace.matchAsPrefix(text, pos);
      if (ws != null) {
        final lex = ws.group(0)!;
        advanceByLexeme(lex);
        if (!ignoreWhitespace) {
          yield makeToken(TokenType.invalid, lex, pos - lex.length, row, col);
        }
        continue;
      }

      final startPos = pos;
      final startRow = row;
      final startCol = col;

      final mParen = reParen.matchAsPrefix(text, pos);
      if (mParen != null) {
        final lex = mParen.group(0)!;
        yield makeToken(
            TokenType.parenthesis, lex, startPos, startRow, startCol);
        advanceByLexeme(lex);
        continue;
      }

      final mSemi = reSemicolon.matchAsPrefix(text, pos);
      if (mSemi != null) {
        final lex = mSemi.group(0)!;
        yield makeToken(TokenType.semicolon, lex, startPos, startRow, startCol);
        advanceByLexeme(lex);
        continue;
      }

      final mProp = reProp.matchAsPrefix(text, pos);
      if (mProp != null) {
        final lex = mProp.group(0)!;
        yield makeToken(TokenType.propIdent, lex, startPos, startRow, startCol);
        advanceByLexeme(lex);
        continue;
      }

      final mC = reCValue.matchAsPrefix(text, pos);
      if (mC != null) {
        final lex = mC.group(0)!;
        yield makeToken(
            TokenType.cValueType, lex, startPos, startRow, startCol);
        advanceByLexeme(lex);
        continue;
      }

      final invalidLex = text[pos];
      if (emitInvalid) {
        yield makeToken(
            TokenType.invalid, invalidLex, startPos, startRow, startCol);
      }
      advanceByLexeme(invalidLex);
    }
  }

  @override
  Iterator<Token> get iterator => _scan().iterator;
}
