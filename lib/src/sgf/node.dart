class Node {
  int? id;
  int? parentId;
  Map<String, List<String>> data;
  List<Node> children;

  Node(this.id, this.parentId, this.data, this.children);

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
