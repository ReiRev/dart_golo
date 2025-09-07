import 'dart:collection';
import 'node.dart';

/// A typed, list-like container of root nodes.
class GameTree extends ListBase<Node> {
  final List<Node> _nodes;

  GameTree(List<Node> nodes) : _nodes = List<Node>.from(nodes);

  @override
  int get length => _nodes.length;

  @override
  set length(int newLength) => _nodes.length = newLength;

  @override
  Node operator [](int index) => _nodes[index];

  @override
  void operator []=(int index, Node value) => _nodes[index] = value;

  /// Stringifies this game tree (or forest) into SGF text.
  ///
  /// - [linebreak]: line separator to use (default: `\n`). When empty,
  ///   indentation is suppressed and everything is concatenated without
  ///   whitespace (useful for compact output).
  /// - [indent]: indentation unit (default: two spaces).
  String toSgf({String linebreak = '\n', String indent = '  '}) {
    final buf = StringBuffer();

    String totalIndent(int level) => linebreak.isEmpty ? '' : indent * level;

    bool _isUpperIdent(String id) => id.toUpperCase() == id;

    String _escapeValue(String s) {
      return s.replaceAll('\\', r'\\').replaceAll(']', r'\]');
    }

    void writeNode(Node node, int level) {
      if (node.data.isNotEmpty) {
        buf.write(totalIndent(level));
        buf.write(';');

        for (final entry in node.data.entries) {
          final id = entry.key;
          if (!_isUpperIdent(id)) continue;

          final values = entry.value;
          buf.write(id);
          if (values.isEmpty) {
            buf.write('[]');
          } else {
            for (final v in values) {
              buf.write('[');
              buf.write(_escapeValue(v));
              buf.write(']');
            }
          }
        }
        buf.write(linebreak);
      }

      final children = node.children;
      if (children.length > 1 || (children.isNotEmpty && level == 0)) {
        buf.write(totalIndent(level));
        for (final child in children) {
          buf.write('(');
          buf.write(linebreak);
          writeNode(child, level + 1);
          buf.write(totalIndent(level));
          buf.write(')');
        }
        buf.write(linebreak);
      } else if (children.length == 1) {
        // Linear continuation: keep same indentation level.
        writeNode(children[0], level);
      }
    }

    if (_nodes.isNotEmpty) {
      final pseudoRoot = Node(-1, null, {}, List<Node>.from(_nodes));
      if (pseudoRoot.children.isNotEmpty) {
        final children = pseudoRoot.children;
        buf.write(totalIndent(0));
        for (final child in children) {
          buf.write('(');
          buf.write(linebreak);
          writeNode(child, 1);
          buf.write(totalIndent(0));
          buf.write(')');
        }
        buf.write(linebreak);
      }
    }

    return buf.toString();
  }
}
