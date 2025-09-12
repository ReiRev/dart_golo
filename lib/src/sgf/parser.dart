import 'token.dart';
import 'recursive_node.dart';

/// Callback that generates node IDs (default: 0,1,2,...).
typedef IdGenerator = int Function();

/// Callback invoked whenever a node is finalized/created.
typedef NodeCallback = void Function(RecursiveNode node);

/// Unescapes SGF backslash-escaping.
String _unescapeSgfValue(String s) {
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '\\' && i + 1 < s.length) {
      i += 1;
      buf.write(s[i]);
    } else {
      buf.write(ch);
    }
  }
  return buf.toString();
}

/// Lightweight parser that converts SGF into a node tree.
///
/// - `;` starts a node, `(` and `)` denote variation start/end.
/// - Property identifiers are normalized by extracting uppercase letters only.
/// - Property values are the text inside `[...]` with SGF escapes unescaped.
/// - Unexpected characters result in a [StateError].
class Parser {
  /// Parses [text] and returns the root [RecursiveNode].
  ///
  /// If the input is a parenthesized game or contains multiple top-level
  /// variations, a dummy anchor (with negative `id`) is returned and its
  /// `children` represent top-level roots.
  RecursiveNode parse(
    String text, {
    IdGenerator? getId,
    NodeCallback? onNodeCreated,
  }) {
    getId ??= (() {
      var id = 0;
      return () => id++;
    })();
    onNodeCreated ??= (_) {};

    final tokens = TokenIterator(text);
    final root = _parseTokens(
      tokens,
      null,
      getId: getId,
      onNodeCreated: onNodeCreated,
    );

    return root ?? RecursiveNode(-1, null, {}, []);
  }

  /// Recursive-descent parsing of a sequence/variation.
  /// Returns the anchor node (dummy with negative `id` at top level).
  RecursiveNode? _parseTokens(
    Peekable<Token> tokens,
    int? parentId, {
    required IdGenerator getId,
    required NodeCallback onNodeCreated,
  }) {
    RecursiveNode? anchor;
    RecursiveNode? node;
    List<String>? property;

    while (true) {
      final tok = tokens.peek();
      if (tok == null) break;
      final type = tok.type;
      final value = tok.value;
      final row = tok.row;
      final col = tok.col;

      if (type == TokenType.parenthesis && value == '(') break;
      if (type == TokenType.parenthesis && value == ')') {
        if (node != null) onNodeCreated(node);
        return anchor;
      }

      if (type == TokenType.semicolon || node == null) {
        final lastNode = node;
        node = RecursiveNode(
          getId(),
          lastNode == null ? parentId : lastNode.id,
          {},
          [],
        );
        if (lastNode != null) {
          onNodeCreated(lastNode);
          lastNode.children.add(node);
        } else {
          anchor = node;
        }
      }

      if (type == TokenType.semicolon) {
      } else if (type == TokenType.propertyIdentifier) {
        if (node != null) {
          final v = value;
          final upper = v.toUpperCase();
          String identifier;
          if (v == upper) {
            identifier = v;
          } else {
            final buf = StringBuffer();
            for (var i = 0; i < v.length; i++) {
              final ch = v[i];
              if (ch.toUpperCase() == ch) buf.write(ch);
            }
            identifier = buf.toString();
          }
          if (identifier.isNotEmpty) {
            node.data.putIfAbsent(identifier, () => <String>[]);
            property = node.data[identifier]!;
          } else {
            property = null;
          }
        }
      } else if (type == TokenType.propertyValue) {
        if (property != null) {
          final inner = value.substring(1, value.length - 1);
          property.add(_unescapeSgfValue(inner));
        }
      } else if (type == TokenType.invalid) {
        throw StateError('Unexpected token at ${row + 1}:${col + 1}');
      } else {
        throw StateError(
            "Unexpected token type '${type.name}' at ${row + 1}:${col + 1}");
      }

      tokens.next();
    }

    if (node == null) {
      anchor = node = RecursiveNode(-1, null, {}, []);
    } else {
      onNodeCreated(node);
    }

    while (true) {
      final tok = tokens.peek();
      if (tok == null) break;
      final type = tok.type;
      final value = tok.value;

      if (type == TokenType.parenthesis && value == '(') {
        tokens.next();
        final child = _parseTokens(
          tokens,
          node.id < 0 ? null : node.id,
          getId: getId,
          onNodeCreated: onNodeCreated,
        );
        if (child != null) {
          node.children.add(child);
        }
      } else if (type == TokenType.parenthesis && value == ')') {
        break;
      }

      tokens.next();
    }

    return anchor;
  }
}
