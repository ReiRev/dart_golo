import 'go_board.dart';

/// Game-side node holding SGF properties and child IDs.
/// Parent links are managed by `SgfTree`.
class Node {
  Map<String, List<String>> data = {};
  List<int> children;

  Node(this.data, this.children);

  /// First value of SGF property [key], or `null`.
  String? get(String key) {
    final values = data[key];
    return (values != null && values.isNotEmpty) ? values.first : null;
  }

  /// Sets SGF property [key] to a single [value]; removes when null/empty.
  void set(String key, String? value) {
    if (value == null || value.isEmpty) {
      data.remove(key);
    } else {
      data[key] = [value];
    }
  }

  /// Adds move for [color] at [vertex] (`B`/`W`).
  void addStone(Stone color, Vertex vertex) {
    final key = color == Stone.black ? 'B' : 'W';
    data[key] = [_toSgfCoord(vertex)];
  }

  /// Adds a pass for [color] (empty `B`/`W`).
  void addPass(Stone color) {
    final key = color == Stone.black ? 'B' : 'W';
    data[key] = [''];
  }

  void addBlack(Vertex vertex) => addStone(Stone.black, vertex);
  void addWhite(Vertex vertex) => addStone(Stone.white, vertex);

  /// Move node.
  Node.move(Stone color, Vertex vertex)
      : data = <String, List<String>>{},
        children = <int>[] {
    addStone(color, vertex);
  }

  /// Pass node.
  Node.pass(Stone color)
      : data = <String, List<String>>{},
        children = <int>[] {
    addPass(color);
  }

  /// Black move node.
  Node.black(Vertex vertex)
      : data = <String, List<String>>{},
        children = <int>[] {
    addStone(Stone.black, vertex);
  }

  /// White move node.
  Node.white(Vertex vertex)
      : data = <String, List<String>>{},
        children = <int>[] {
    addStone(Stone.white, vertex);
  }

  // SGF coordinate string (e.g., aa, dp).
  static String _toSgfCoord(Vertex v) {
    String c(int n) => String.fromCharCode('a'.codeUnitAt(0) + n);
    return '${c(v.x)}${c(v.y)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Node) return false;
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
    var h = 0;
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
