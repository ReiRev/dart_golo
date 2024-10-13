import './property.dart';
import './property_identifier.dart';
import './property_value.dart';

class RootPropertyIdentifier extends PropertyIdentifier {
  const RootPropertyIdentifier._(String value) : super(value);

  /// Provides the name and version number of the application used
  /// to create this [gametree](https://www.red-bean.com/sgf/sgf4.html#ebnf-def).
  /// The name should be unique and must not be changed for
  /// different versions of the same program.
  /// The version number itself may be of any kind, but the format
  /// used must ensure that by using an ordinary string-compare,
  /// one is able to tell if the version is lower or higher
  /// than another version number.
  // Here's the list of known applications and their names:
  /// Application		     System	  Name
  /// ---------------------------  -----------  --------------------
  /// [CGoban:1.6.2]		     Unix	  CGoban
  /// [Hibiscus:2.1]		     Windows 95   Hibiscus Go Editor
  /// [IGS:5.0]				  Internet Go Server
  /// [Many Faces of Go:10.0]      Windows 95   The Many Faces of Go
  /// [MGT:?]			     DOS/Unix	  MGT
  /// [NNGS:?]		     Unix	  No Name Go Server
  /// [Primiview:3.0]   	     Amiga OS3.0  Primiview
  /// [SGB:?]			     Macintosh	  Smart Game Board
  /// [SmartGo:1.0]		     Windows	  SmartGo
  static const RootPropertyIdentifier application =
      RootPropertyIdentifier._('AP');

  /// Provides the used charset for SimpleText and Text type.
  static const RootPropertyIdentifier charset = RootPropertyIdentifier._('CA');

  /// Defines the used file format. For difference between those
  /// formats have a look at the [history](https://www.red-bean.com/sgf/ff1_3/sgfhistory.html) of SGF.
  /// Note: only supported file formats are 4, which are widely used now.
  static const RootPropertyIdentifier fileFormat =
      RootPropertyIdentifier._('FF');

  /// Defines the type of game, which is stored in the current
  /// gametree. The property should help applications
  /// to reject games, they cannot handle.
  /// Valid numbers are: Go = 1
  static const RootPropertyIdentifier gameType = RootPropertyIdentifier._('GM');

  /// Defines how variations should be shown (this is needed to
  /// synchronize the comments with the variations). If ST is omitted
  /// viewers should offer the possibility to change the mode online.
  /// Basically most programs show variations in two ways:
  /// as markup on the board (if the variation contains a move)
  /// and/or as a list (in a separate window).
  /// The style number consists two options.
  /// 1) show variations of successor node (children) (value: 0)
  /// show variations of current node   (siblings) (value: 1)
  /// affects markup & list
  /// 2) do board markup         (value: 0)
  /// no (auto-) board markup (value: 2)
  /// affects markup only.
  /// Using no board markup could be used in problem collections
  /// or if variations are marked by subsequent properties.
  /// Viewers should take care, that the automatic variation
  /// board markup DOESN'T overwrite any markup of other
  /// properties.
  /// The  final number is calculated by adding the values of each
  /// option.	Example: 3 = no board markup/variations of current node
  /// 1 = board markup/variations of current node
  static const RootPropertyIdentifier style = RootPropertyIdentifier._('ST');

  /// Defines the size of the board. If only a single value
  /// is given, the board is a square; with two numbers given,
  /// rectangular boards are possible.
  /// If a rectangular board is specified, the first number specifies
  /// the number of columns, the second provides the number of rows.
  /// Square boards must not be defined using the compose type
  /// value;: e.g. SZ[19:19] is illegal.
  /// The valid range for SZ is any size greater or equal to 1x1.
  /// For Go games the maximum size is limited to 52x52.
  /// Default value: game specific
  ///  for Go: 19 (square board)
  /// for Chess: 8 (square board)
  static const RootPropertyIdentifier boardSize =
      RootPropertyIdentifier._('SZ');
}

/// Root properties may only appear in root nodes. Root nodes are
/// the first nodes of [gametrees](https://www.red-bean.com/sgf/sgf4.html#ebnf-def), which are direct descendants from a
/// [collection](https://www.red-bean.com/sgf/sgf4.html#ebnf-def) (i.e. not gametrees within other gametrees).
/// They define some global 'attributes' such as board-size, kind
/// of game, used file format etc.
class RootProperty extends Property {
  RootProperty({
    required RootPropertyIdentifier identifier,
    required PropertyValue value,
  }) : super(
          identifier: identifier,
          value: value,
        );
}
