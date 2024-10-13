import 'package:equatable/equatable.dart';

import 'properties/property.dart';

class Node extends Equatable {
  List<Node> children = [];
  List<Property> properties = [];

  Node({List<Node>? children, List<Property>? properties}) {
    this.children = children ?? [];
    this.properties = properties ?? [];
  }

  @override
  List<Object?> get props => [children, properties];
}
