import 'node.dart';

/// Manages SGF node graph and data (no Board snapshots).
class SgfTree {
  final Map<int, Node> _nodesById = <int, Node>{};
  final Map<int, int?> _parentOf = <int, int?>{};

  final List<int> rootNodes = <int>[];

  int? _cursor;

  int _nextId = 0;

  SgfTree();

  /// Adds a root node and returns its ID.
  int addRoot(Node node) {
    final id = _nextId++;
    _nodesById[id] = node;
    rootNodes.add(id);
    _parentOf[id] = null;
    _cursor ??= id;
    return id;
  }

  /// Adds [node] as a child; defaults to current cursor.
  int addChild(Node node, {int? parentId}) {
    final pid = parentId ?? _cursor;
    if (pid == null) {
      throw StateError('No parent to attach child to (cursor is null)');
    }
    if (!_nodesById.containsKey(pid)) {
      throw StateError('Parent node $pid does not exist');
    }
    final id = _nextId++;
    _nodesById[id] = node;
    final parent = _nodesById[pid]!;
    parent.children.add(id);
    _parentOf[id] = pid;
    return id;
  }

  Node? nodeById(int id) => _nodesById[id];

  int? get cursor => _cursor;
  int? get cursorId => _cursor;

  void moveTo(int id) {
    if (_nodesById.containsKey(id)) _cursor = id;
  }

  List<int> get nextChildren {
    final cur = _cursor;
    if (cur == null) return const [];
    final n = _nodesById[cur];
    if (n == null) return const [];
    return List<int>.from(n.children);
  }

  void goNext() {
    final children = nextChildren;
    if (children.isNotEmpty) _cursor = children.first;
  }

  void goNextAt(int i) {
    final children = nextChildren;
    if (i >= 0 && i < children.length) _cursor = children[i];
  }

  void goBack() {
    final cur = _cursor;
    if (cur == null) return;
    _cursor = _parentOf[cur] ?? _cursor;
  }

  void goSibling() {
    final cur = _cursor;
    if (cur == null) return;
    final parentId = _parentOf[cur];
    final siblings = parentId == null
        ? rootNodes
        : (_nodesById[parentId]?.children ?? const <int>[]);
    if (siblings.isEmpty) return;
    final idx = siblings.indexOf(cur);
    final nextIdx = (idx + 1) % siblings.length;
    _cursor = siblings[nextIdx];
  }

  int? parentOf(int id) => _parentOf[id];

  Map<String, List<String>> get data {
    final cur = _cursor;
    if (cur == null) return {};
    return _nodesById[cur]?.data ?? {};
  }

  Map<String, List<String>> dataAt(int id) => _nodesById[id]?.data ?? {};

  void add(String propId, List<String> value) {
    final cur = _cursor;
    if (cur == null) return;
    final n = _nodesById[cur];
    if (n == null) return;
    n.data[propId] = List<String>.from(value);
  }

  // Board operations are managed by BoardTree.

  String toSgf({String linebreak = '\n', String indent = '  '}) {
    final buf = StringBuffer();

    String totalIndent(int level) => linebreak.isEmpty ? '' : indent * level;
    bool isUpperIdent(String id) => id.toUpperCase() == id;
    String escapeValue(String s) =>
        s.replaceAll('\\', r'\\').replaceAll(']', r'\]');

    void writeNode(Node node, int level) {
      if (node.data.isNotEmpty) {
        buf.write(totalIndent(level));
        buf.write(';');
        for (final entry in node.data.entries) {
          final id = entry.key;
          if (!isUpperIdent(id)) continue;
          final values = entry.value;
          buf.write(id);
          if (values.isEmpty) {
            buf.write('[]');
          } else {
            for (final v in values) {
              buf.write('[');
              buf.write(escapeValue(v));
              buf.write(']');
            }
          }
        }
        buf.write(linebreak);
      }

      final children = node.children;
      if (children.length > 1) {
        buf.write(totalIndent(level));
        for (final childId in children) {
          final child = _nodesById[childId];
          if (child == null) continue;
          buf.write('(');
          buf.write(linebreak);
          writeNode(child, level + 1);
          buf.write(totalIndent(level));
          buf.write(')');
        }
        buf.write(linebreak);
      } else if (children.length == 1) {
        final child = _nodesById[children.first];
        if (child != null) writeNode(child, level);
      }
    }

    if (rootNodes.isNotEmpty) {
      for (final rootId in rootNodes) {
        final root = _nodesById[rootId];
        if (root == null) continue;
        buf.write(totalIndent(0));
        buf.write('(');
        buf.write(linebreak);
        writeNode(root, 1);
        buf.write(totalIndent(0));
        buf.write(')');
      }
      buf.write(linebreak);
    }

    return buf.toString();
  }
}
