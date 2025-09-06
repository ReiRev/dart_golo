import 'package:golo/src/game_tree.dart';
import 'package:golo/src/go_board.dart';

class Game {
  Board _currentBoard;
  GameTree _gameTree;
  late final Node _rootNode;
  late Node _currentNode;

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
  // Rules
  String? get rule => _getMeta('RU');
  set rule(String? value) => _setMeta('RU', value);

  // Application, Charset, File format, Game type
  String? get application => _getMeta('AP');
  set application(String? value) => _setMeta('AP', value);
  String? get charset => _getMeta('CA');
  set charset(String? value) => _setMeta('CA', value);
  String? get fileFormat => _getMeta('FF');
  set fileFormat(String? value) => _setMeta('FF', value);
  String? get gameType => _getMeta('GM');
  set gameType(String? value) => _setMeta('GM', value);

  // Event, Round, Place, Date(s)
  String? get event => _getMeta('EV');
  set event(String? value) => _setMeta('EV', value);
  String? get round => _getMeta('RO');
  set round(String? value) => _setMeta('RO', value);
  String? get place => _getMeta('PC');
  set place(String? value) => _setMeta('PC', value);
  String? get date => _getMeta('DT');
  set date(String? value) => _setMeta('DT', value);

  // Players, ranks, teams, countries
  String? get playerBlack => _getMeta('PB');
  set playerBlack(String? value) => _setMeta('PB', value);
  String? get playerWhite => _getMeta('PW');
  set playerWhite(String? value) => _setMeta('PW', value);
  String? get blackRank => _getMeta('BR');
  set blackRank(String? value) => _setMeta('BR', value);
  String? get whiteRank => _getMeta('WR');
  set whiteRank(String? value) => _setMeta('WR', value);
  String? get blackTeam => _getMeta('BT');
  set blackTeam(String? value) => _setMeta('BT', value);
  String? get whiteTeam => _getMeta('WT');
  set whiteTeam(String? value) => _setMeta('WT', value);
  String? get blackCountry => _getMeta('BC');
  set blackCountry(String? value) => _setMeta('BC', value);
  String? get whiteCountry => _getMeta('WC');
  set whiteCountry(String? value) => _setMeta('WC', value);

  // Game info
  String? get name => _getMeta('GN');
  set name(String? value) => _setMeta('GN', value);
  String? get comment => _getMeta('GC');
  set comment(String? value) => _setMeta('GC', value);
  String? get annotator => _getMeta('AN');
  set annotator(String? value) => _setMeta('AN', value);
  String? get copyright => _getMeta('CP');
  set copyright(String? value) => _setMeta('CP', value);
  String? get source => _getMeta('SO');
  set source(String? value) => _setMeta('SO', value);

  // Result, Komi, Handicap, Overtime and time settings
  String? get result => _getMeta('RE');
  set result(String? value) => _setMeta('RE', value);
  String? get komi => _getMeta('KM');
  set komi(String? value) => _setMeta('KM', value);
  String? get handicap => _getMeta('HA');
  set handicap(String? value) => _setMeta('HA', value);
  String? get overtime => _getMeta('OT');
  set overtime(String? value) => _setMeta('OT', value);
  String? get time => _getMeta('TM');
  set time(String? value) => _setMeta('TM', value);
  String? get byoYomiPeriods => _getMeta('LC');
  set byoYomiPeriods(String? value) => _setMeta('LC', value);
  String? get byoYomiLength => _getMeta('LT');
  set byoYomiLength(String? value) => _setMeta('LT', value);
}
