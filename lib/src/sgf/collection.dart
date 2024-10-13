import 'package:equatable/equatable.dart';

import './node.dart';
import './properties/properties.dart';

class Collection extends Equatable {
  late final List<Node> nodes;

  Collection({List<Node>? nodes}) {
    this.nodes = nodes ?? [];
  }

  factory Collection.fromString(String sgf) {
    // String cleaned = sgf.replaceAll(RegExp(r'\s'), '');
    List<Node> nodesStack = [];
    // The children of this will be a root node.
    Node currentNode = Node();
    String propertyIdentifier = '';
    String propertyValue = '';
    bool isReadingPropertyValue = false;
    for (final String char in sgf.split('')) {
      switch (char) {
        case '(':
          nodesStack.add(currentNode);
          break;
        case ')':
          currentNode = nodesStack.removeLast();
        case ';':
          // new node
          Node newNode = Node();
          currentNode.children.add(newNode);
          currentNode = newNode;
        case '[':
          isReadingPropertyValue = true;
          break;
        case ']':
          isReadingPropertyValue = false;
          currentNode.properties.add(
            Property(
              identifier: PropertyIdentifier(
                propertyIdentifier.replaceAll(RegExp(r'\s'), ''),
              ),
              value: propertyValue,
            ),
          );
          propertyIdentifier = '';
          propertyValue = '';
          break;
        default:
          if (isReadingPropertyValue) {
            propertyValue += char;
          } else {
            propertyIdentifier += char;
          }
          break;
      }
      // print("$char, $propertyIdentifier, $propertyValue");
      print("$currentNode");
    }
    var children = currentNode.children;
    print("$children");
    return Collection(nodes: currentNode.children);
  }

  @override
  List<Object?> get props => [nodes];
}
