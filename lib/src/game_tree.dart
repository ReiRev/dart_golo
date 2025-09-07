import 'dart:collection';

/// A node in an SGF game tree.
///
/// - [id]: Unique node ID. Internal dummy anchors use a negative ID.
/// - [parentId]: Parent node ID. Nodes directly under the root may have `null`.
/// - [data]: Map of SGF properties. Keys are identifiers (e.g. `B`, `W`, `AB`, `SZ`),
///   values are arrays holding zero or more values for that property.
/// - [children]: Variations (branches) represented as child nodes.
class Node {
  int id;
  int? parentId;
  Map<String, List<String>> data;
  List<Node> children;

  Node(this.id, this.parentId, this.data, this.children);

  /// Returns the first value of the SGF property [key], or `null` if absent.
  String? get(String key) {
    final values = data[key];
    return (values != null && values.isNotEmpty) ? values.first : null;
  }

  /// Sets the SGF property [key] to a single [value].
  /// If [value] is `null` or empty, removes the property.
  void set(String key, String? value) {
    if (value == null || value.isEmpty) {
      data.remove(key);
    } else {
      data[key] = [value];
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Node) return false;
    if (id != other.id || parentId != other.parentId) return false;
    if (data.length != other.data.length) return false;
    for (final key in data.keys) {
      final a = data[key];
      final b = other.data[key];
      if (a == null || b == null) return false;
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
    }
    if (children.length != other.children.length) return false;
    for (var i = 0; i < children.length; i++) {
      if (children[i] != other.children[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var h = Object.hash(id, parentId);
    for (final key in data.keys) {
      h = Object.hash(h, key);
      final list = data[key]!;
      for (final v in list) {
        h = Object.hash(h, v);
      }
    }
    for (final c in children) {
      h = Object.hash(h, c);
    }
    return h;
  }
}

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
}
