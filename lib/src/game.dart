import 'sgf_tree.dart';
import 'board.dart';
import 'node.dart';
import 'board_tree.dart';
import 'sgf/parser.dart';
import 'sgf/recursive_node.dart';

class Game {
  SgfTree _sgfTree;
  late final BoardTree _boardTree;
  late final int _rootId;
  late int _currentId;
  Stone _currentPlayer = Stone.black;

  /// Creates a new game with a configurable board size.
  ///
  /// - [width]: board width. Defaults to 19.
  /// - [height]: board height. When omitted, a square board is created.
  Game({int width = 19, int? height}) : _sgfTree = SgfTree() {
    _rootId = _sgfTree.addRoot(Node({}, []));
    _currentId = _rootId;
    _boardTree = BoardTree();

    final initialBoard = Board.fromDimension(width, height);
    _boardTree.init(_rootId, initialBoard.clone());

    _sgfTree.nodeById(_rootId)!.set('GM', '1');
    _sgfTree.nodeById(_rootId)!.set('FF', '4');
    _sgfTree.nodeById(_rootId)!.set('CA', 'UTF-8');
    _sgfTree.nodeById(_rootId)!.set('AP', 'Dart Golo');
    final w = initialBoard.width;
    final h = initialBoard.height;
    final sz = w == h ? '$w' : '$w:$h';
    _sgfTree.nodeById(_rootId)!.set('SZ', sz);
  }

  /// Returns a snapshot of the board at the node with [nodeId].
  /// Throws [StateError] if no snapshot is recorded for [nodeId].
  Board boardAt(int nodeId) {
    final b = _boardTree[nodeId];
    if (b == null) {
      throw StateError('No board snapshot for nodeId=$nodeId');
    }
    return b.clone();
  }

  Board get board => boardAt(_currentId);

  Stone get currentPlayer => _currentPlayer;

  // ---- Common root metadata accessors ----
  /// SGF `RU`: Ruleset name. Examples: `Japanese`, `Chinese`, `AGA`.
  String? get rule => _sgfTree.nodeById(_rootId)!.get('RU');
  set rule(String? value) => _sgfTree.nodeById(_rootId)!.set('RU', value);

  /// SGF `AP`: Application name and version (e.g. `Name:Version`). Default is `Dart Golo`.
  String? get application => _sgfTree.nodeById(_rootId)!.get('AP');
  set application(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('AP', value);

  /// SGF `CA`: Charset for SimpleText/Text (e.g. `UTF-8`).
  String? get charset => _sgfTree.nodeById(_rootId)!.get('CA');
  set charset(String? value) => _sgfTree.nodeById(_rootId)!.set('CA', value);

  /// SGF `EV`: Event/tournament name.
  String? get event => _sgfTree.nodeById(_rootId)!.get('EV');
  set event(String? value) => _sgfTree.nodeById(_rootId)!.set('EV', value);

  /// SGF `RO`: Round information (e.g. `Game 1`, `Final`).
  String? get round => _sgfTree.nodeById(_rootId)!.get('RO');
  set round(String? value) => _sgfTree.nodeById(_rootId)!.set('RO', value);

  /// SGF `PC`: Place/location.
  String? get place => _sgfTree.nodeById(_rootId)!.get('PC');
  set place(String? value) => _sgfTree.nodeById(_rootId)!.set('PC', value);

  /// SGF `DT`: Date(s) of the game.
  String? get date => _sgfTree.nodeById(_rootId)!.get('DT');
  set date(String? value) => _sgfTree.nodeById(_rootId)!.set('DT', value);

  // Players, ranks, teams, countries
  /// SGF `PB`: Black player name.
  String? get playerBlack => _sgfTree.nodeById(_rootId)!.get('PB');
  set playerBlack(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('PB', value);

  /// SGF `PW`: White player name.
  String? get playerWhite => _sgfTree.nodeById(_rootId)!.get('PW');
  set playerWhite(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('PW', value);

  /// SGF `BR`: Black rank (e.g. `9d`, `1k`, `6p`).
  String? get blackRank => _sgfTree.nodeById(_rootId)!.get('BR');
  set blackRank(String? value) => _sgfTree.nodeById(_rootId)!.set('BR', value);

  /// SGF `WR`: White rank.
  String? get whiteRank => _sgfTree.nodeById(_rootId)!.get('WR');
  set whiteRank(String? value) => _sgfTree.nodeById(_rootId)!.set('WR', value);

  /// SGF `BT`: Black team name.
  String? get blackTeam => _sgfTree.nodeById(_rootId)!.get('BT');
  set blackTeam(String? value) => _sgfTree.nodeById(_rootId)!.set('BT', value);

  /// SGF `WT`: White team name.
  String? get whiteTeam => _sgfTree.nodeById(_rootId)!.get('WT');
  set whiteTeam(String? value) => _sgfTree.nodeById(_rootId)!.set('WT', value);

  /// Non-standard: Black country/region. Not defined in SGF FF[4].
  String? get blackCountry => _sgfTree.nodeById(_rootId)!.get('BC');
  set blackCountry(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('BC', value);

  /// Non-standard: White country/region. Not defined in SGF FF[4].
  String? get whiteCountry => _sgfTree.nodeById(_rootId)!.get('WC');
  set whiteCountry(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('WC', value);

  // Game info
  /// SGF `GN`: Game name/title.
  String? get name => _sgfTree.nodeById(_rootId)!.get('GN');
  set name(String? value) => _sgfTree.nodeById(_rootId)!.set('GN', value);

  /// SGF `GC`: Game comment (free text).
  String? get comment => _sgfTree.nodeById(_rootId)!.get('GC');
  set comment(String? value) => _sgfTree.nodeById(_rootId)!.set('GC', value);

  /// SGF `AN`: Annotator/author of comments.
  String? get annotator => _sgfTree.nodeById(_rootId)!.get('AN');
  set annotator(String? value) => _sgfTree.nodeById(_rootId)!.set('AN', value);

  /// SGF `CP`: Copyright notice.
  String? get copyright => _sgfTree.nodeById(_rootId)!.get('CP');
  set copyright(String? value) => _sgfTree.nodeById(_rootId)!.set('CP', value);

  /// SGF `SO`: Source (book, journal, URL, etc.).
  String? get source => _sgfTree.nodeById(_rootId)!.get('SO');
  set source(String? value) => _sgfTree.nodeById(_rootId)!.set('SO', value);

  // Result, Komi, Handicap, Overtime and time settings
  /// SGF `RE`: Result. Examples: `B+R`, `W+0.5`, `Void`, `?`.
  String? get result => _sgfTree.nodeById(_rootId)!.get('RE');
  set result(String? value) => _sgfTree.nodeById(_rootId)!.set('RE', value);

  /// SGF `KM`: Komi (real value, e.g. `7.5`).
  String? get komi => _sgfTree.nodeById(_rootId)!.get('KM');
  set komi(String? value) => _sgfTree.nodeById(_rootId)!.set('KM', value);

  /// SGF `HA`: Handicap count (number of handicap stones).
  String? get handicap => _sgfTree.nodeById(_rootId)!.get('HA');
  set handicap(String? value) => _sgfTree.nodeById(_rootId)!.set('HA', value);

  /// SGF `OT`: Overtime settings (free text, e.g. `3x60 byo-yomi`).
  String? get overtime => _sgfTree.nodeById(_rootId)!.get('OT');
  set overtime(String? value) => _sgfTree.nodeById(_rootId)!.set('OT', value);

  /// SGF `TM`: Main time limit in seconds.
  String? get time => _sgfTree.nodeById(_rootId)!.get('TM');
  set time(String? value) => _sgfTree.nodeById(_rootId)!.set('TM', value);

  /// Non-standard: Byo-yomi periods count. Prefer describing in `OT` for portability.
  String? get byoYomiPeriods => _sgfTree.nodeById(_rootId)!.get('LC');
  set byoYomiPeriods(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('LC', value);

  /// Non-standard: Byo-yomi period length. Prefer describing in `OT` for portability.
  String? get byoYomiLength => _sgfTree.nodeById(_rootId)!.get('LT');
  set byoYomiLength(String? value) =>
      _sgfTree.nodeById(_rootId)!.set('LT', value);

  /// Plays a move for the current player at [vertex].
  ///
  /// - Enforces basic rules (out-of-board, overwrite, suicide, ko) and throws
  ///   [IllegalMoveException] when violated.
  /// - Updates the internal SGF tree by appending a node to the current line.
  void play(Vertex vertex) {
    final node = Node.move(_currentPlayer, vertex);
    final newId = _sgfTree.addChild(node, parentId: _currentId);
    _boardTree.moveTo(_currentId);
    _boardTree.commitMove(
      newId,
      _currentPlayer,
      vertex,
      preventOutOfBoard: true,
      preventOverwrite: true,
      preventSuicide: true,
      preventKo: true,
    );
    _sgfTree.moveTo(newId);
    _currentId = newId;
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  /// Passes the current player's turn.
  void pass() {
    final node = Node.pass(_currentPlayer);
    final newId = _sgfTree.addChild(node, parentId: _currentId);
    _boardTree.moveTo(_currentId);
    _boardTree.commitPass(newId, _currentPlayer);
    _sgfTree.moveTo(newId);
    _currentId = newId;
    _currentPlayer = _currentPlayer == Stone.black ? Stone.white : Stone.black;
  }

  /// Stringify this game to SGF text using the internal game tree.
  String toSgf({String linebreak = '\n', String indent = '  '}) {
    return _sgfTree.toSgf(linebreak: linebreak, indent: indent);
  }

  /// Creates a game from SGF text, following only the main line (first-child path).
  ///
  /// - Size (SZ) is respected if present; otherwise defaults to 19x19.
  /// - Root setup stones (AB/AW/AE) are applied.
  /// - Variations are ignored; only the first-child chain is imported.
  factory Game.fromSgf(String text) {
    final parsed = Parser().parse(text);
    final root = parsed.id < 0
        ? (parsed.children.isNotEmpty ? parsed.children.first : null)
        : parsed;
    if (root == null) {
      throw StateError('No SGF game trees found');
    }

    final size = _parseSize(root.data['SZ']);
    final game = Game(width: size.$1, height: size.$2);

    // Merge root metadata, excluding move properties.
    for (final entry in root.data.entries) {
      final key = entry.key;
      if (key == 'B' || key == 'W') continue;
      game._sgfTree.nodeById(game._rootId)!.data[key] =
          List<String>.from(entry.value);
    }

    // Apply root setup stones to initial board.
    final rootBoard = game._boardTree[game._rootId]!;
    _applySetup(root.data, rootBoard);
    game._boardTree[game._rootId] = rootBoard;

    // Walk main line and apply moves/passes.
    final mainline = <RecursiveNode>[];
    {
      RecursiveNode? cur = root;
      while (cur != null) {
        mainline.add(cur);
        cur = cur.children.isNotEmpty ? cur.children.first : null;
      }
    }
    for (var i = 0; i < mainline.length; i++) {
      final node = mainline[i];
      // Skip metadata-only nodes with no move.
      final hasB = node.data['B'] != null;
      final hasW = node.data['W'] != null;
      if (!hasB && !hasW) continue;

      final isBlack = hasB;
      final values = node.data[isBlack ? 'B' : 'W']!;
      final coord = values.isNotEmpty ? values.first : '';

      // Ensure turn matches the node color.
      game._currentPlayer = isBlack ? Stone.black : Stone.white;

      if (coord.isEmpty) {
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
        game._sgfTree.nodeById(game._currentId)!.set('C', comment);
      }
    }

    return game;
  }

  bool get canUndo => _currentId != _rootId;

  /// Undo the last move/pass, moving back to the parent node.
  ///
  /// - Returns a clone of the board after undo on success.
  /// - Returns `null` if already at the root (nothing to undo).
  Board? undo() {
    if (!canUndo) return null;
    final undone = _sgfTree.nodeById(_currentId)!;
    final parentId = _sgfTree.parentOf(_currentId);
    if (parentId == null) return null;

    // Determine undone color from node data.
    Stone? undoneColor;
    if (undone.data.containsKey('B')) {
      undoneColor = Stone.black;
    } else if (undone.data.containsKey('W')) {
      undoneColor = Stone.white;
    }

    _currentId = parentId;
    if (undoneColor != null) {
      _currentPlayer = undoneColor;
    }
    return boardAt(_currentId);
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

  static void _applySetup(Map<String, List<String>> data, Board board) {
    void apply(String key, Stone? stone) {
      final vals = data[key];
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
}
