import 'token.dart';
import '../game_tree.dart';

/// Callback that generates node IDs.
/// The default is a simple sequence 0,1,2,...
typedef IdGenerator = int Function();

/// Callback invoked whenever a node is finalized/created.
typedef NodeCallback = void Function(Node node);

/// Unescapes SGF backslash-escaping.
/// A backslash escapes the next single character (including `]`, `\\`, `\n`, etc.).
String _unescapeSgfValue(String s) {
  // SGF escaping: backslash escapes the next character (including ']','\','\n', etc.)
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
  /// Parses [text] and returns the list of root nodes. If the input contains
  /// a parenthesized game, an internal dummy anchor is used (with a negative
  /// `id`) and its children are returned.
  GameTree parse(
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

    if (root == null) return GameTree(const []);
    final nodes = root.id < 0 ? root.children : [root];
    return GameTree(nodes);
  }

  /// Recursive-descent parsing of a sequence/variation.
  ///
  /// [parentId] is the ID of the parent node. Returns the anchor node of the
  /// just-parsed linear sequence; at the top level this may be a dummy anchor
  /// (with a negative `id`).
  Node? _parseTokens(
    Peekable<Token> tokens,
    int? parentId, {
    required IdGenerator getId,
    required NodeCallback onNodeCreated,
  }) {
    Node? anchor;
    Node? node;
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
        node = Node(getId(), lastNode == null ? parentId : lastNode.id, {}, []);
        if (lastNode != null) {
          onNodeCreated(lastNode);
          lastNode.children.add(node);
        } else {
          anchor = node;
        }
      }

      if (type == TokenType.semicolon) {
        // Node start; nothing else to do here.
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
          // Strip the surrounding brackets
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
      // Create a dummy anchor for grouping top-level variations.
      // Use a negative id to distinguish from real nodes (0,1,2,...).
      anchor = node = Node(-1, null, {}, []);
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
