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

  /// Returns the depth (distance from the root) of [id]. Root depth is zero.
  int depthOf(int id) {
    if (!_nodesById.containsKey(id)) {
      throw StateError('No such node: id=$id');
    }
    var depth = 0;
    var cur = id;
    while (true) {
      final parent = _parentOf[cur];
      if (parent == null) return depth;
      depth++;
      cur = parent;
    }
  }

  /// Depth of the cursor node, or null when the cursor is unset.
  int? get currentDepth => _cursor == null ? null : depthOf(_cursor!);

  /// Maximum depth across the entire tree.
  int get depth {
    if (rootNodes.isEmpty) return 0;

    int maxDepth = 0;

    int traverse(int id, int accDepth) {
      final node = _nodesById[id];
      if (node == null || node.children.isEmpty) {
        return accDepth;
      }
      var localMax = accDepth;
      for (final childId in node.children) {
        final childDepth = traverse(childId, accDepth + 1);
        if (childDepth > localMax) {
          localMax = childDepth;
        }
      }
      return localMax;
    }

    for (final rootId in rootNodes) {
      final depthFromRoot = traverse(rootId, 0);
      if (depthFromRoot > maxDepth) {
        maxDepth = depthFromRoot;
      }
    }

    return maxDepth;
  }

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

  /// Removes nodes starting from [id].
  ///
  /// - When [includeSelf] is true, removes the node [id] itself and its entire
  ///   subtree, detaching it from its parent (or from roots when it is a root).
  /// - When [includeSelf] is false, keeps [id] and removes all its descendants
  ///   (clears its children list).
  /// - Returns the list of removed node IDs (in no particular order).
  /// - If [id] does not exist, returns an empty list.
  List<int> removeFrom(int id, {bool includeSelf = true}) {
    if (!_nodesById.containsKey(id)) return const <int>[];

    // Collect subtree ids (including [id]).
    final toRemove = <int>[];
    void dfs(int nid) {
      final n = _nodesById[nid];
      if (n == null) return;
      for (final c in n.children) {
        dfs(c);
      }
      toRemove.add(nid);
    }

    dfs(id);

    final keepSelf = !includeSelf;
    if (keepSelf) {
      // Keep the node itself; only remove its descendants.
      toRemove.remove(id);
      // Clear children relations from the kept node.
      final self = _nodesById[id];
      self?.children.clear();
    } else {
      // Detach from parent lists or roots.
      final pid = _parentOf[id];
      if (pid != null) {
        final p = _nodesById[pid];
        p?.children.removeWhere((e) => e == id);
      } else {
        rootNodes.removeWhere((e) => e == id);
      }
    }

    // Preserve parent (for cursor update) before removing ids.
    final parentBefore = _parentOf[id];

    // Remove nodes and parent links.
    for (final rid in toRemove) {
      _nodesById.remove(rid);
      _parentOf.remove(rid);
    }

    // Update cursor if it was inside the removed set.
    if (_cursor != null && toRemove.contains(_cursor)) {
      _cursor = keepSelf ? id : parentBefore;
    }

    return toRemove;
  }

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
