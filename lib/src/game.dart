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
    _rootNode.data['GM'] = ['1'];
    // SGF format.
    _rootNode.data['FF'] = ['4'];
    // Charset
    _rootNode.data['CA'] = ['UTF-8'];
    // Application (Name:Version)
    _rootNode.data['AP'] = ['Dart Golo'];
    final w = _currentBoard.width;
    final h = _currentBoard.height;
    final sz = w == h ? '$w' : '$w:$h';
    _rootNode.data['SZ'] = [sz];
  }

  Board get board => _currentBoard.clone();

  Stone get currentPlayer => _currentPlayer;

  String? _getMeta(String key) {
    final values = _rootNode.data[key];
    return (values != null && values.isNotEmpty) ? values.first : null;
  }

  void _setMeta(String key, String? value) {
    if (value == null || value.isEmpty) {
      _rootNode.data.remove(key);
    } else {
      _rootNode.data[key] = [value];
    }
  }

  // ---- Common root metadata accessors ----
  /// SGF `RU`: Ruleset name. Examples: `Japanese`, `Chinese`, `AGA`.
  String? get rule => _getMeta('RU');
  set rule(String? value) => _setMeta('RU', value);

  /// SGF `AP`: Application name and version (e.g. `Name:Version`). Default is `Dart Golo`.
  String? get application => _getMeta('AP');
  set application(String? value) => _setMeta('AP', value);

  /// SGF `CA`: Charset for SimpleText/Text (e.g. `UTF-8`).
  String? get charset => _getMeta('CA');
  set charset(String? value) => _setMeta('CA', value);

  /// SGF `EV`: Event/tournament name.
  String? get event => _getMeta('EV');
  set event(String? value) => _setMeta('EV', value);

  /// SGF `RO`: Round information (e.g. `Game 1`, `Final`).
  String? get round => _getMeta('RO');
  set round(String? value) => _setMeta('RO', value);

  /// SGF `PC`: Place/location.
  String? get place => _getMeta('PC');
  set place(String? value) => _setMeta('PC', value);

  /// SGF `DT`: Date(s) of the game.
  String? get date => _getMeta('DT');
  set date(String? value) => _setMeta('DT', value);

  // Players, ranks, teams, countries
  /// SGF `PB`: Black player name.
  String? get playerBlack => _getMeta('PB');
  set playerBlack(String? value) => _setMeta('PB', value);

  /// SGF `PW`: White player name.
  String? get playerWhite => _getMeta('PW');
  set playerWhite(String? value) => _setMeta('PW', value);

  /// SGF `BR`: Black rank (e.g. `9d`, `1k`, `6p`).
  String? get blackRank => _getMeta('BR');
  set blackRank(String? value) => _setMeta('BR', value);

  /// SGF `WR`: White rank.
  String? get whiteRank => _getMeta('WR');
  set whiteRank(String? value) => _setMeta('WR', value);

  /// SGF `BT`: Black team name.
  String? get blackTeam => _getMeta('BT');
  set blackTeam(String? value) => _setMeta('BT', value);

  /// SGF `WT`: White team name.
  String? get whiteTeam => _getMeta('WT');
  set whiteTeam(String? value) => _setMeta('WT', value);

  /// Non-standard: Black country/region. Not defined in SGF FF[4].
  String? get blackCountry => _getMeta('BC');
  set blackCountry(String? value) => _setMeta('BC', value);

  /// Non-standard: White country/region. Not defined in SGF FF[4].
  String? get whiteCountry => _getMeta('WC');
  set whiteCountry(String? value) => _setMeta('WC', value);

  // Game info
  /// SGF `GN`: Game name/title.
  String? get name => _getMeta('GN');
  set name(String? value) => _setMeta('GN', value);

  /// SGF `GC`: Game comment (free text).
  String? get comment => _getMeta('GC');
  set comment(String? value) => _setMeta('GC', value);

  /// SGF `AN`: Annotator/author of comments.
  String? get annotator => _getMeta('AN');
  set annotator(String? value) => _setMeta('AN', value);

  /// SGF `CP`: Copyright notice.
  String? get copyright => _getMeta('CP');
  set copyright(String? value) => _setMeta('CP', value);

  /// SGF `SO`: Source (book, journal, URL, etc.).
  String? get source => _getMeta('SO');
  set source(String? value) => _setMeta('SO', value);

  // Result, Komi, Handicap, Overtime and time settings
  /// SGF `RE`: Result. Examples: `B+R`, `W+0.5`, `Void`, `?`.
  String? get result => _getMeta('RE');
  set result(String? value) => _setMeta('RE', value);

  /// SGF `KM`: Komi (real value, e.g. `7.5`).
  String? get komi => _getMeta('KM');
  set komi(String? value) => _setMeta('KM', value);

  /// SGF `HA`: Handicap count (number of handicap stones).
  String? get handicap => _getMeta('HA');
  set handicap(String? value) => _setMeta('HA', value);

  /// SGF `OT`: Overtime settings (free text, e.g. `3x60 byo-yomi`).
  String? get overtime => _getMeta('OT');
  set overtime(String? value) => _setMeta('OT', value);

  /// SGF `TM`: Main time limit in seconds.
  String? get time => _getMeta('TM');
  set time(String? value) => _setMeta('TM', value);

  /// Non-standard: Byo-yomi periods count. Prefer describing in `OT` for portability.
  String? get byoYomiPeriods => _getMeta('LC');
  set byoYomiPeriods(String? value) => _setMeta('LC', value);

  /// Non-standard: Byo-yomi period length. Prefer describing in `OT` for portability.
  String? get byoYomiLength => _getMeta('LT');
  set byoYomiLength(String? value) => _setMeta('LT', value);

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
