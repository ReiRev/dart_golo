import 'package:golo/src/game_tree.dart';
import 'package:golo/src/go_board.dart';

class Game {
  Board _currentBoard;
  GameTree _gameTree;
  late final Node _rootNode;
  late Node _currentNode;
  Stone _currentPlayer = Stone.black;
  int _nextNodeId = 1;

  Game()
      : _currentBoard = Board.fromDimension(19, 19),
        _gameTree = GameTree([Node(0, null, {}, [])]) {
    _rootNode = _gameTree[0];
    _currentNode = _gameTree[0];

    // Initialize root metadata (e.g., board size) once.
    // The type of the game.
    _rootNode.set('GM', '1');
    // SGF format.
    _rootNode.set('FF', '4');
    // Charset
    _rootNode.set('CA', 'UTF-8');
    // Application (Name:Version)
    _rootNode.set('AP', 'Dart Golo');
    final w = _currentBoard.width;
    final h = _currentBoard.height;
    final sz = w == h ? '$w' : '$w:$h';
    _rootNode.set('SZ', sz);
  }

  Board get board => _currentBoard.clone();

  Stone get currentPlayer => _currentPlayer;

  // ---- Common root metadata accessors ----
  /// SGF `RU`: Ruleset name. Examples: `Japanese`, `Chinese`, `AGA`.
  String? get rule => _rootNode.get('RU');
  set rule(String? value) => _rootNode.set('RU', value);

  /// SGF `AP`: Application name and version (e.g. `Name:Version`). Default is `Dart Golo`.
  String? get application => _rootNode.get('AP');
  set application(String? value) => _rootNode.set('AP', value);

  /// SGF `CA`: Charset for SimpleText/Text (e.g. `UTF-8`).
  String? get charset => _rootNode.get('CA');
  set charset(String? value) => _rootNode.set('CA', value);

  /// SGF `EV`: Event/tournament name.
  String? get event => _rootNode.get('EV');
  set event(String? value) => _rootNode.set('EV', value);

  /// SGF `RO`: Round information (e.g. `Game 1`, `Final`).
  String? get round => _rootNode.get('RO');
  set round(String? value) => _rootNode.set('RO', value);

  /// SGF `PC`: Place/location.
  String? get place => _rootNode.get('PC');
  set place(String? value) => _rootNode.set('PC', value);

  /// SGF `DT`: Date(s) of the game.
  String? get date => _rootNode.get('DT');
  set date(String? value) => _rootNode.set('DT', value);

  // Players, ranks, teams, countries
  /// SGF `PB`: Black player name.
  String? get playerBlack => _rootNode.get('PB');
  set playerBlack(String? value) => _rootNode.set('PB', value);

  /// SGF `PW`: White player name.
  String? get playerWhite => _rootNode.get('PW');
  set playerWhite(String? value) => _rootNode.set('PW', value);

  /// SGF `BR`: Black rank (e.g. `9d`, `1k`, `6p`).
  String? get blackRank => _rootNode.get('BR');
  set blackRank(String? value) => _rootNode.set('BR', value);

  /// SGF `WR`: White rank.
  String? get whiteRank => _rootNode.get('WR');
  set whiteRank(String? value) => _rootNode.set('WR', value);

  /// SGF `BT`: Black team name.
  String? get blackTeam => _rootNode.get('BT');
  set blackTeam(String? value) => _rootNode.set('BT', value);

  /// SGF `WT`: White team name.
  String? get whiteTeam => _rootNode.get('WT');
  set whiteTeam(String? value) => _rootNode.set('WT', value);

  /// Non-standard: Black country/region. Not defined in SGF FF[4].
  String? get blackCountry => _rootNode.get('BC');
  set blackCountry(String? value) => _rootNode.set('BC', value);

  /// Non-standard: White country/region. Not defined in SGF FF[4].
  String? get whiteCountry => _rootNode.get('WC');
  set whiteCountry(String? value) => _rootNode.set('WC', value);

  // Game info
  /// SGF `GN`: Game name/title.
  String? get name => _rootNode.get('GN');
  set name(String? value) => _rootNode.set('GN', value);

  /// SGF `GC`: Game comment (free text).
  String? get comment => _rootNode.get('GC');
  set comment(String? value) => _rootNode.set('GC', value);

  /// SGF `AN`: Annotator/author of comments.
  String? get annotator => _rootNode.get('AN');
  set annotator(String? value) => _rootNode.set('AN', value);

  /// SGF `CP`: Copyright notice.
  String? get copyright => _rootNode.get('CP');
  set copyright(String? value) => _rootNode.set('CP', value);

  /// SGF `SO`: Source (book, journal, URL, etc.).
  String? get source => _rootNode.get('SO');
  set source(String? value) => _rootNode.set('SO', value);

  // Result, Komi, Handicap, Overtime and time settings
  /// SGF `RE`: Result. Examples: `B+R`, `W+0.5`, `Void`, `?`.
  String? get result => _rootNode.get('RE');
  set result(String? value) => _rootNode.set('RE', value);

  /// SGF `KM`: Komi (real value, e.g. `7.5`).
  String? get komi => _rootNode.get('KM');
  set komi(String? value) => _rootNode.set('KM', value);

  /// SGF `HA`: Handicap count (number of handicap stones).
  String? get handicap => _rootNode.get('HA');
  set handicap(String? value) => _rootNode.set('HA', value);

  /// SGF `OT`: Overtime settings (free text, e.g. `3x60 byo-yomi`).
  String? get overtime => _rootNode.get('OT');
  set overtime(String? value) => _rootNode.set('OT', value);

  /// SGF `TM`: Main time limit in seconds.
  String? get time => _rootNode.get('TM');
  set time(String? value) => _rootNode.set('TM', value);

  /// Non-standard: Byo-yomi periods count. Prefer describing in `OT` for portability.
  String? get byoYomiPeriods => _rootNode.get('LC');
  set byoYomiPeriods(String? value) => _rootNode.set('LC', value);

  /// Non-standard: Byo-yomi period length. Prefer describing in `OT` for portability.
  String? get byoYomiLength => _rootNode.get('LT');
  set byoYomiLength(String? value) => _rootNode.set('LT', value);

  /// Plays a move for the current player at [vertex].
  ///
  /// - Enforces basic rules (out-of-board, overwrite, suicide, ko) and throws
  ///   [IllegalMoveException] when violated.
  /// - Updates the internal SGF tree by appending a node to the current line.
  void play(Vertex vertex) {
    // Apply the move to produce a new board state.
    _currentBoard = _currentBoard.makeMove(
      vertex,
      _currentPlayer,
      preventOutOfBoard: true,
      preventOverwrite: true,
      preventSuicide: true,
      preventKo: true,
    );

    // Append a node to the current game tree branch.
    final key = _currentPlayer == Stone.black ? 'B' : 'W';
    final sgfCoord = _toSgf(vertex);
    final node = Node(
      _nextNodeId++,
      _currentNode.id,
      {
        key: [sgfCoord]
      },
      [],
    );
    _currentNode.children.add(node);
    _currentNode = node;

    // Alternate player.
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  /// Passes the current player's turn.
  void pass() {
    final key = _currentPlayer == Stone.black ? 'B' : 'W';
    final node = Node(
      _nextNodeId++,
      _currentNode.id,
      {
        key: ['']
      }, // Empty value represents pass in SGF
      [],
    );
    _currentNode.children.add(node);
    _currentNode = node;
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  /// Converts a 0-based vertex to an SGF coordinate string (e.g. aa, dp).
  /// Top-left (0,0) -> 'aa'.
  String _toSgf(Vertex v) {
    String c(int n) => String.fromCharCode('a'.codeUnitAt(0) + n);
    return '${c(v.x)}${c(v.y)}';
  }
}
