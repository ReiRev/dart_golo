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
}
