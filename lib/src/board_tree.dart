import 'dart:collection';
import 'board.dart';

/// Stores canonical Board snapshots keyed by node IDs.
/// Agnostic of tree structure; exposes a cloning Map interface.
class BoardTree extends MapBase<int, Board> {
  final Map<int, Board> _boardsById = <int, Board>{};
  int? _cursor;

  int? get cursorId => _cursor;

  /// Returns a clone of the Board at the current cursor, or null if unset.
  Board? get cursor => _cursor == null ? null : _boardsById[_cursor!]?.clone();

  /// Initialize snapshot for [id] and set cursor if not set.
  void init(int id, Board board) {
    this[id] = board;
    _cursor ??= id;
  }

  /// Move cursor to [id]. The id does not need to have a snapshot yet.
  void moveTo(int id) {
    _cursor = id;
  }

  @override
  Board? operator [](Object? key) {
    if (key is! int) return null;
    final b = _boardsById[key];
    return b?.clone();
  }

  @override
  void operator []=(int key, Board value) {
    _boardsById[key] = value.clone();
  }

  @override
  void clear() {
    _boardsById.clear();
  }

  @override
  Iterable<int> get keys => _boardsById.keys;

  @override
  Board? remove(Object? key) {
    if (key is! int) return null;
    final b = _boardsById.remove(key);
    return b?.clone();
  }

  /// Apply a legal move on the current cursor's board and record snapshot at [newId].
  /// Returns the new Board snapshot after the move and moves the cursor to [newId].
  Board commitMove(
    int newId,
    Stone color,
    Vertex vertex, {
    bool preventOutOfBoard = true,
    bool preventOverwrite = true,
    bool preventSuicide = true,
    bool preventKo = true,
  }) {
    final pid = _cursor;
    if (pid == null) {
      throw StateError('No cursor set for commitMove');
    }
    final parentBoard = _boardsById[pid];
    if (parentBoard == null) {
      throw StateError('No board snapshot for cursorId=$pid');
    }

    final newBoard = parentBoard.makeMove(
      vertex,
      color,
      preventOutOfBoard: preventOutOfBoard,
      preventOverwrite: preventOverwrite,
      preventSuicide: preventSuicide,
      preventKo: preventKo,
    );

    this[newId] = newBoard;
    moveTo(newId);
    return newBoard.clone();
  }

  /// Commit a pass on the current cursor's board and record snapshot at [newId].
  /// Returns the Board snapshot (identical to the parent's board) and moves cursor.
  Board commitPass(int newId, Stone color) {
    final pid = _cursor;
    if (pid == null) {
      throw StateError('No cursor set for commitPass');
    }
    final parentBoard = _boardsById[pid];
    if (parentBoard == null) {
      throw StateError('No board snapshot for cursorId=$pid');
    }
    this[newId] = parentBoard;
    moveTo(newId);
    return parentBoard.clone();
  }
}
