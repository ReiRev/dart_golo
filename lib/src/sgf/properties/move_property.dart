import './property.dart';
import './property_identifier.dart';
import './property_value.dart';

/// Move properties
class MovePropertyIdentifier extends PropertyIdentifier {
  const MovePropertyIdentifier._(super.value);

  /// [reference](https://www.red-bean.com/sgf/properties.html#B)
  ///
  /// Execute a black move. This is one of the most used properties
  /// in actual [collections](https://www.red-bean.com/sgf/sgf4.html#ebnf-def).
  /// As long as the given move is syntactically correct it should be executed.
  /// It doesn't matter if the move itself is illegal
  /// (e.g. recapturing a ko in a Go game).
  /// Have a look at [how to execute a Go-move](https://www.red-bean.com/sgf/go.html#execute%20move).
  /// B and W properties must not be mixed within a node.
  static const MovePropertyIdentifier black = MovePropertyIdentifier._('B');

  /// [reference](https://www.red-bean.com/sgf/properties.html#W)
  ///
  /// Execute a white move. This is one of the most used properties
  /// in actual [collections](https://www.red-bean.com/sgf/sgf4.html#ebnf-def).
  /// As long as the given move is syntactically correct it should be executed.
  /// It doesn't matter if the move itself is illegal
  /// (e.g. recapturing a ko in a Go game).
  /// Have a look at [how to execute a Go-move](https://www.red-bean.com/sgf/go.html#execute%20move).
  /// B and W properties must not be mixed within a node.
  static const MovePropertyIdentifier white = MovePropertyIdentifier._('W');

  /// [reference](https://www.red-bean.com/sgf/properties.html#KO)
  ///
  /// Execute a given move (B or W) even it's illegal. This is
  /// an optional property, SGF viewers themselves should execute
  /// ALL moves. It's purpose is to make it easier for other
  /// applications (e.g. computer-players) to deal with illegal
  /// moves. A KO property without a black or white move within
  /// the; same node is illegal.
  static const MovePropertyIdentifier ko = MovePropertyIdentifier._('KO');

  /// [reference](https://www.red-bean.com/sgf/properties.html#MN)
  /// Sets the move number to the given value, i.e. a move
  /// specified in this node has exactly this move-number. This
  /// can be useful for variations or printing.
  static const MovePropertyIdentifier moveNumber =
      MovePropertyIdentifier._('MN');
}

/// Properties of this type concentrate on the move made, not on
/// the position arrived at by this move.
/// Move properties must not be mixed with setup properties within
/// the same node.
/// Note: it's bad style to have move properties in root nodes.
/// (it isn't forbidden though)
class MoveProperty extends Property {
  MoveProperty({
    required MovePropertyIdentifier identifier,
    required PropertyValue value,
  }) : super(
          identifier: identifier,
          value: value,
        );
}
