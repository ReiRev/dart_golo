import '../node.dart';
import '../go_board.dart';

/// SGF-specific recursive node used by the parser.
///
/// This class currently mirrors the behavior of [Node] without changing
/// implementation details. It exists to decouple SGF-related structures from
/// game-related ones, allowing future divergence without API breakage.
class RecursiveNode extends Node {
  RecursiveNode(
    int id,
    int? parentId,
    Map<String, List<String>> data,
    List<Node> children,
  ) : super(id, parentId, data, children);

  /// Named constructor that creates a node representing a move.
  RecursiveNode.move(
    int id,
    int? parentId,
    Stone color,
    Vertex vertex,
  ) : super(id, parentId, <String, List<String>>{}, <Node>[]) {
    addStone(color, vertex);
  }

  /// Named constructor that creates a node representing a pass.
  RecursiveNode.pass(
    int id,
    int? parentId,
    Stone color,
  ) : super(id, parentId, <String, List<String>>{}, <Node>[]) {
    addPass(color);
  }

  /// Named constructor for a Black move node.
  RecursiveNode.black(
    int id,
    int? parentId,
    Vertex vertex,
  ) : super(id, parentId, <String, List<String>>{}, <Node>[]) {
    addStone(Stone.black, vertex);
  }

  /// Named constructor for a White move node.
  RecursiveNode.white(
    int id,
    int? parentId,
    Vertex vertex,
  ) : super(id, parentId, <String, List<String>>{}, <Node>[]) {
    addStone(Stone.white, vertex);
  }
}
