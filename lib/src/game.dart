import 'game_tree.dart';
import 'go_board.dart';
import 'node.dart';
import 'sgf/parser.dart';

class Game {
  Board _currentBoard;
  GameTree _gameTree;
  late final Node _rootNode;
  late Node _currentNode;
  Stone _currentPlayer = Stone.black;
  int _nextNodeId = 1;
  final Map<int, Board> _boardHistory = <int, Board>{};
  final Map<int, Node> _nodesById = <int, Node>{};

  /// Creates a new game with a configurable board size.
  ///
  /// - [width]: board width. Defaults to 19.
  /// - [height]: board height. When omitted, a square board is created.
  Game({int width = 19, int? height})
      : _currentBoard = Board.fromDimension(width, height),
        _gameTree = GameTree([Node(0, null, {}, [])]) {
    _rootNode = _gameTree[0];
    _currentNode = _gameTree[0];
    // Record initial empty board snapshot at root node id.
    _boardHistory[_rootNode.id] = _currentBoard.clone();
    _nodesById[_rootNode.id] = _rootNode;

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

  /// Returns a snapshot of the board at the node with [nodeId].
  /// Throws [StateError] if no snapshot is recorded for [nodeId].
  Board boardAt(int nodeId) {
    final b = _boardHistory[nodeId];
    if (b == null) {
      throw StateError('No board snapshot for nodeId=$nodeId');
    }
    return b.clone();
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
    final node = Node.move(
      _nextNodeId++,
      _currentNode.id,
      _currentPlayer,
      vertex,
    );
    _currentNode.children.add(node);
    _currentNode = node;
    // Record snapshot for this node.
    _boardHistory[node.id] = _currentBoard.clone();
    _nodesById[node.id] = node;

    // Alternate player.
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  /// Passes the current player's turn.
  void pass() {
    final node = Node.pass(
      _nextNodeId++,
      _currentNode.id,
      _currentPlayer,
    );
    _currentNode.children.add(node);
    _currentNode = node;
    // Record snapshot (same position) for this node as well.
    _boardHistory[node.id] = _currentBoard.clone();
    _nodesById[node.id] = node;
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  // SGF coordinate conversion is handled by Node helpers.

  /// Stringify this game to SGF text using the internal game tree.
  String toSgf({String linebreak = '\n', String indent = '  '}) {
    return _gameTree.toSgf(linebreak: linebreak, indent: indent);
  }

  /// Creates a game from SGF text, following only the main line (first-child path).
  ///
  /// - Size (SZ) is respected if present; otherwise defaults to 19x19.
  /// - Root setup stones (AB/AW/AE) are applied.
  /// - Variations are ignored; only the first-child chain is imported.
  factory Game.fromSgf(String text) {
    final trees = Parser().parse(text);
    if (trees.isEmpty) {
      throw StateError('No SGF game trees found');
    }

    final root = trees[0];
    final size = _parseSize(root.data['SZ']);
    final game = Game(width: size.$1, height: size.$2);

    // Merge root metadata, excluding move properties (B/W).
    for (final entry in root.data.entries) {
      final key = entry.key;
      if (key == 'B' || key == 'W') continue;
      game._rootNode.data[key] = List<String>.from(entry.value);
    }

    // Apply root setup stones to initial board and refresh snapshot.
    _applySetup(root, game._currentBoard);
    game._boardHistory[game._rootNode.id] = game._currentBoard.clone();

    // Walk main line and apply moves/passes.
    final mainline = _extractMainline(root);
    for (var i = 0; i < mainline.length; i++) {
      final node = mainline[i];
      // Skip the initial root metadata-only node if it has no move.
      final hasB = node.data['B'] != null;
      final hasW = node.data['W'] != null;
      if (!hasB && !hasW) continue;

      final isBlack = hasB;
      final values = node.data[isBlack ? 'B' : 'W']!;
      final coord = values.isNotEmpty ? values.first : '';

      // Ensure turn matches the node color.
      game._currentPlayer = isBlack ? Stone.black : Stone.white;

      if (coord.isEmpty) {
        // Pass move
        game.pass();
      } else {
        final v = _vertexFromSgf(coord);
        if (v != null) {
          game.play(v);
        }
      }

      // Preserve move comment if present.
      final cvals = node.data['C'];
      final comment = (cvals != null && cvals.isNotEmpty) ? cvals.first : null;
      if (comment != null && comment.isNotEmpty) {
        game._currentNode.set('C', comment);
      }
    }

    return game;
  }

  bool get canUndo => _currentNode.id != _rootNode.id;

  /// Undo the last move/pass, moving back to the parent node.
  ///
  /// - Returns a clone of the board after undo on success.
  /// - Returns `null` if already at the root (nothing to undo).
  Board? undo() {
    if (!canUndo) return null;
    final undone = _currentNode;
    final parentId = undone.parentId;
    if (parentId == null) return null;
    final parent = _nodesById[parentId] ?? _rootNode;

    // Determine undone color from node data (B or W)
    Stone? undoneColor;
    if (undone.data.containsKey('B')) {
      undoneColor = Stone.black;
    } else if (undone.data.containsKey('W')) {
      undoneColor = Stone.white;
    }

    _currentNode = parent;
    _currentBoard = boardAt(parent.id);
    if (undoneColor != null) {
      _currentPlayer = undoneColor;
    }
    return _currentBoard.clone();
  }

  static (int, int) _parseSize(List<String>? values) {
    if (values == null || values.isEmpty) return (19, 19);
    final v = values.first.trim();
    if (v.isEmpty) return (19, 19);
    if (v.contains(':')) {
      final parts = v.split(':');
      final w = int.tryParse(parts[0]);
      final h = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (w == null || h == null) return (19, 19);
      return (w, h);
    }
    final n = int.tryParse(v);
    if (n == null) return (19, 19);
    return (n, n);
  }

  static void _applySetup(Node node, Board board) {
    void apply(String key, Stone? stone) {
      final vals = node.data[key];
      if (vals == null) return;
      for (final raw in vals) {
        for (final v in _expandPoint(raw)) {
          if (board.has(v)) board.set(v, stone);
        }
      }
    }

    apply('AB', Stone.black);
    apply('AW', Stone.white);
    apply('AE', null);
  }

  static Iterable<Vertex> _expandPoint(String s) sync* {
    final t = s.trim();
    if (t.isEmpty) return;
    if (!t.contains(':')) {
      final v = _vertexFromSgf(t);
      if (v != null) yield v;
      return;
    }
    final parts = t.split(':');
    if (parts.length != 2) return;
    final a = _vertexFromSgf(parts[0]);
    final b = _vertexFromSgf(parts[1]);
    if (a == null || b == null) return;
    final minX = a.x <= b.x ? a.x : b.x;
    final maxX = a.x >= b.x ? a.x : b.x;
    final minY = a.y <= b.y ? a.y : b.y;
    final maxY = a.y >= b.y ? a.y : b.y;
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        yield (x: x, y: y);
      }
    }
  }

  static Vertex? _vertexFromSgf(String s) {
    if (s.length < 2) return null;
    final x = s.codeUnitAt(0) - 97; // 'a' => 0
    final y = s.codeUnitAt(1) - 97;
    return (x: x, y: y);
  }

  static List<Node> _extractMainline(Node root) {
    final list = <Node>[];
    Node? cur = root;
    while (cur != null) {
      list.add(cur);
      cur = cur.children.isNotEmpty ? cur.children.first : null;
    }
    return list;
  }
}
