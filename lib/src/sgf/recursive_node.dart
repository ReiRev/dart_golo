import '../go_board.dart';

/// SGF-specific recursive node used by the parser.
///
/// Standalone structure for SGF trees. Not tied to game.Node.
class RecursiveNode {
  int id;
  int? parentId;
  Map<String, List<String>> data;
  List<RecursiveNode> children;

  RecursiveNode(this.id, this.parentId, this.data, this.children);

  String? get(String key) {
    final values = data[key];
    return (values != null && values.isNotEmpty) ? values.first : null;
    }

  void set(String key, String? value) {
    if (value == null || value.isEmpty) {
      data.remove(key);
    } else {
      data[key] = [value];
    }
  }

  void addStone(Stone color, Vertex vertex) {
    final key = color == Stone.black ? 'B' : 'W';
    data[key] = [_toSgfCoord(vertex)];
  }

  void addPass(Stone color) {
    final key = color == Stone.black ? 'B' : 'W';
    data[key] = [''];
  }

  void addBlack(Vertex vertex) => addStone(Stone.black, vertex);

  void addWhite(Vertex vertex) => addStone(Stone.white, vertex);

  RecursiveNode.move(this.id, this.parentId, Stone color, Vertex vertex)
      : data = <String, List<String>>{},
        children = <RecursiveNode>[] {
    addStone(color, vertex);
  }

  RecursiveNode.pass(this.id, this.parentId, Stone color)
      : data = <String, List<String>>{},
        children = <RecursiveNode>[] {
    addPass(color);
  }

  RecursiveNode.black(this.id, this.parentId, Vertex vertex)
      : data = <String, List<String>>{},
        children = <RecursiveNode>[] {
    addStone(Stone.black, vertex);
  }

  RecursiveNode.white(this.id, this.parentId, Vertex vertex)
      : data = <String, List<String>>{},
        children = <RecursiveNode>[] {
    addStone(Stone.white, vertex);
  }

  static String _toSgfCoord(Vertex v) {
    String c(int n) => String.fromCharCode('a'.codeUnitAt(0) + n);
    return '${c(v.x)}${c(v.y)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecursiveNode) return false;
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
