/// Core data types and APIs for Go (Baduk/Weiqi) board logic.
import 'dart:math';

/// Type of a stone on the board.
enum Stone {
  black,
  white,
}

/// A 0-based board coordinate.
///
/// - [x]: column index from the left, starting at 0
/// - [y]: row index from the top, starting at 0
typedef Vertex = ({int x, int y});

/// Information about Ko (recapture ban).
///
/// - [stone]: the color that is currently forbidden to recapture
/// - [vertex]: the Ko coordinate where recapture is forbidden
typedef KoInfo = ({Stone stone, Vertex vertex});

/// Reasons why a move is considered illegal.
enum IllegalMoveReason { overwrite, ko, suicide, outOfBoard }

/// Exception thrown for illegal moves.
///
/// Contains the [reason], the [vertex] attempted, and the [stone] played.
class IllegalMoveException implements Exception {
  final IllegalMoveReason reason;
  final Vertex vertex;
  final Stone stone;
  const IllegalMoveException(this.reason,
      {required this.vertex, required this.stone});
  @override
  String toString() =>
      'IllegalMoveException(${reason.name} at ${vertex.x},${vertex.y} by $stone)';
}

/// Represents a Go board state and operations.
///
/// The board is stored as a 2D list `state[y][x]` where `null` means empty,
/// and [Stone.black]/[Stone.white] represent stones.
///
/// Note:
/// - The constructor does not defensively copy the provided [state]. If the
///   caller mutates it afterwards, this [Board] will observe the change.
/// - [set] and [clear] mutate this instance. [makeMove] returns a cloned board
///   with the move applied and does not mutate this instance.
class Board {
  /// Two-dimensional board state `state[y][x]`. `null` represents an empty point.
  List<List<Stone?>> state;
  final Map<Stone, int> _captures = {Stone.black: 0, Stone.white: 0};
  KoInfo? _koInfo;

  /// Column labels used by string conversions (letter I is skipped).
  static const alpha = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';

  /// Creates a board from an existing [state].
  ///
  /// - All rows must have the same length; otherwise throws [ArgumentError].
  /// - Width and height must be at most [alpha].length; otherwise throws [ArgumentError].
  /// - If [captures] is provided, initializes capture counts.
  /// - If [koInfo] is provided, sets current Ko information.
  Board(this.state, {Map<Stone, int>? captures, KoInfo? koInfo}) {
    final int height = state.length;
    final int width = state[0].length;
    if (height > alpha.length || width > alpha.length) {
      throw ArgumentError(
          'width or height must not be greater than ${alpha.length}');
    }
    for (final row in state) {
      if (row.length != width) {
        throw ArgumentError('All rows must have the same length');
      }
    }

    if (captures != null) {
      _captures[Stone.black] = captures[Stone.black] ?? 0;
      _captures[Stone.white] = captures[Stone.white] ?? 0;
    }

    if (koInfo != null) {
      _koInfo = koInfo;
    }
  }

  /// Creates an empty board of size [width] × [height].
  /// If [height] is omitted, a square board is created.
  Board.fromDimension(int width, [int? height])
      : this(List.generate(
            height ?? width, (_) => List.generate(width, (_) => null)));

  /// Number of rows (height).
  int get height => state.length;

  /// Number of columns (width).
  int get width => state[0].length;

  /// Returns the stone at [vertex], or `null` if empty or out of board.
  Stone? get(Vertex vertex) => has(vertex) ? state[vertex.y][vertex.x] : null;

  /// Returns whether [vertex] lies on the board (0 ≤ x < width and 0 ≤ y < height).
  bool has(Vertex vertex) =>
      0 <= vertex.x && vertex.x < width && 0 <= vertex.y && vertex.y < height;

  /// Returns whether the board is square.
  bool isSquare() => width == height;

  /// Returns whether the board is empty (all points are `null`).
  bool isEmpty() => state.every((row) => row.every((stone) => stone == null));

  /// Sets [stone] at [vertex]. Use `null` to clear a point.
  ///
  /// This mutates the board. No bounds checking is performed.
  Board set(Vertex vertex, Stone? stone) {
    state[vertex.y][vertex.x] = stone;
    return this;
  }

  /// Returns a new [Board] with [stone] played at [vertex].
  ///
  /// Does not mutate this instance. Captures are removed and tallied.
  /// Parameters control which rule violations should throw [IllegalMoveException]:
  /// - [preventOutOfBoard]: throw if [vertex] is out of board (default false).
  ///   When false and out of board, a cloned board is returned unchanged.
  /// - [preventSuicide]: throw on suicide moves.
  /// - [preventOverwrite]: throw when playing on an occupied point.
  /// - [preventKo]: throw when immediate Ko recapture is forbidden.
  Board makeMove(
    Vertex vertex,
    Stone stone, {
    bool preventOutOfBoard = false,
    bool preventSuicide = false,
    bool preventOverwrite = false,
    bool preventKo = false,
  }) {
    final move = clone();
    if (!has(vertex)) {
      if (preventOutOfBoard) {
        throw IllegalMoveException(
          IllegalMoveReason.outOfBoard,
          vertex: vertex,
          stone: stone,
        );
      }
      return move;
    }

    if (preventOverwrite && move.get(vertex) != null) {
      throw IllegalMoveException(
        IllegalMoveReason.overwrite,
        vertex: vertex,
        stone: stone,
      );
    }

    if (preventKo && _koInfo?.stone == stone && _koInfo?.vertex == vertex) {
      throw IllegalMoveException(
        IllegalMoveReason.ko,
        vertex: vertex,
        stone: stone,
      );
    }

    move.set(vertex, stone);

    final other = stone == Stone.black ? Stone.white : Stone.black;
    final neighbors = move.getNeighbors(vertex);
    final deadStones = <Vertex>[];
    final deadNeighbors = neighbors.where(
      (n) => move.get(n) == other && !move.hasLiberties(n),
    );

    for (final n in deadNeighbors) {
      if (move.get(n) == null) continue;

      final chain = move.getChain(n);
      for (final c in chain) {
        move.state[c.y][c.x] = null;
        move.setCaptures(stone, move.getCaptures(stone) + 1);
        deadStones.add(c);
      }
    }

    final liberties = move.getLiberties(vertex);
    final hasKo = deadStones.length == 1 &&
        liberties.length == 1 &&
        liberties[0] == deadStones[0] &&
        neighbors.every((n) => move.get(n) != stone);

    move._koInfo = hasKo ? (stone: other, vertex: deadStones[0]) : null;

    if (deadStones.isEmpty && liberties.isEmpty) {
      if (preventSuicide) {
        throw IllegalMoveException(
          IllegalMoveReason.suicide,
          vertex: vertex,
          stone: stone,
        );
      }

      final chain = move.getChain(vertex);
      for (final c in chain) {
        move.set(c, null).setCaptures(
              other,
              getCaptures(other),
            );
      }
    }

    return move;
  }

  /// Resets the board to an empty state (keeps dimensions).
  void clear() {
    state = List.generate(height, (_) => List.generate(width, (_) => null));
  }

  /// Returns the number of stones captured by [player].
  int getCaptures(Stone player) {
    return _captures[player] ?? 0;
  }

  /// Sets the capture count for [stone] to [value]. Returns `this` for chaining.
  Board setCaptures(Stone stone, int value) {
    _captures[stone] = value;
    return this;
  }

  /// Returns the connected component (chain) of same-colored stones containing [vertex].
  /// If [vertex] is empty or out of board, returns an empty list.
  List<Vertex> getChain(Vertex vertex) {
    final stone = get(vertex);
    return getConnectedComponent(vertex, (vertex) => get(vertex) == stone);
  }

  /// Returns orthogonal neighbors (up, down, left, right) on the board.
  /// Returns an empty list if [vertex] is out of board.
  List<Vertex> getNeighbors(Vertex vertex) {
    if (!has(vertex)) {
      return [];
    }
    final x = vertex.x;
    final y = vertex.y;
    return [
      (x: x - 1, y: y),
      (x: x + 1, y: y),
      (x: x, y: y - 1),
      (x: x, y: y + 1)
    ].where((vertex) => has(vertex)).toList();
  }

  /// Depth-first search to collect a connected component starting at [vertex]
  /// following the [predicate].
  ///
  /// Returns an empty list if [vertex] is out of board. The optional [result]
  /// is used for recursion and should not be supplied by callers.
  List<Vertex> getConnectedComponent(
    Vertex vertex,
    bool Function(Vertex vertex) predicate, [
    List<Vertex>? result,
  ]) {
    if (!has(vertex)) return [];
    result ??= [vertex];

    // Recursive depth-first search
    for (final vertex_ in getNeighbors(vertex)) {
      if (!predicate(vertex_)) continue;
      final already = result.any((w) => w.x == vertex_.x && w.y == vertex_.y);
      if (already) continue;

      result.add(vertex_);
      getConnectedComponent(vertex_, predicate, result);
    }

    return result;
  }

  /// Returns the unique liberties (adjacent empty points) of the chain at [vertex].
  /// Returns an empty list for out-of-board or empty [vertex].
  List<Vertex> getLiberties(Vertex vertex) {
    if (!has(vertex) || get(vertex) == null) return [];

    final chain = getChain(vertex);
    final Set<Vertex> liberties = {};
    for (final c in chain) {
      for (final nv in getNeighbors(c)) {
        if (get(nv) == null) {
          liberties.add(nv);
        }
      }
    }

    return liberties.toList();
  }

  /// Returns the Manhattan distance between [v1] and [v2].
  int getDistance(Vertex v1, Vertex v2) {
    return (v1.x - v2.x).abs() + (v1.y - v2.y).abs();
  }

  /// Returns whether the chain at [vertex] has at least one liberty.
  /// Returns false for out-of-board or empty [vertex].
  bool hasLiberties(Vertex vertex, [Map<Vertex, bool>? visited]) {
    final stone = get(vertex);
    if (!has(vertex) || stone == null) return false;

    visited ??= <Vertex, bool>{};
    if (visited.containsKey(vertex)) return false;

    final neighbors = getNeighbors(vertex);
    if (neighbors.any((n) => get(n) == null)) return true;

    visited[vertex] = true;

    return neighbors
        .where((n) => get(n) == stone)
        .any((n) => hasLiberties(n, visited));
  }

  /// Returns true if every chain on the board has at least one liberty.
  bool isValid() {
    final Map<Vertex, bool> liberties = {};

    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final vertex = (x: x, y: y);
        if (get(vertex) == null || liberties.containsKey(vertex)) continue;
        if (!hasLiberties(vertex)) return false;

        for (final vertex in getChain(vertex)) {
          liberties[vertex] = true;
        }
      }
    }

    return true;
  }

  /// Returns all stones of the same color as [vertex] that are reachable
  /// through paths consisting of same-colored stones and empty points.
  /// Returns an empty list for out-of-board or empty [vertex].
  List<Vertex> getRelatedChains(Vertex vertex) {
    if (!has(vertex) || get(vertex) == null) return [];

    final stone = get(vertex);
    final area = getConnectedComponent(
      vertex,
      (vertex) {
        final s = get(vertex);
        return s == stone || s == null;
      },
    );

    return area.where((vertex) => get(vertex) == stone).toList();
  }

  /// Returns a new [Board] with optionally replaced [state], [captures], or [koInfo].
  ///
  /// If [state] is omitted, the current [state] is deep-copied.
  Board copyWith({
    List<List<Stone?>>? state,
    Map<Stone, int>? captures,
    KoInfo? koInfo,
  }) {
    return Board(
      state?.map((r) => List<Stone?>.from(r)).toList(growable: false) ??
          this.state.map((r) => List<Stone?>.from(r)).toList(growable: false),
      captures: {...(captures ?? _captures)},
      koInfo: koInfo ?? _koInfo,
    );
  }

  /// Returns a deep copy of this board.
  Board clone() => copyWith();

  /// Returns the list of coordinates that differ from [board],
  /// or `null` if sizes differ.
  List<Vertex>? diff(Board board) {
    if (board.width != width || board.height != height) {
      return null;
    }

    final result = <Vertex>[];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final other = board.get((x: x, y: y));
        if (get((x: x, y: y)) == other) continue;
        result.add((x: x, y: y));
      }
    }
    return result;
  }

  /// Returns candidate handicap placements.
  ///
  /// - [count]: number of desired handicap stones (truncated to available).
  /// - [tygem]: if true, uses Tygem ordering for the first four corners.
  List<Vertex> getHandicapPlacement(int count, {bool tygem = false}) {
    if (min(width, height) <= 6 || count < 2) return [];

    final nearX = width >= 13 ? 3 : 2;
    final nearY = height >= 13 ? 3 : 2;
    final farX = width - nearX - 1;
    final farY = height - nearY - 1;
    final middleX = (width - 1) ~/ 2;
    final middleY = (height - 1) ~/ 2;

    final result = <Vertex>[];
    if (!tygem) {
      result.addAll([
        (x: nearX, y: farY),
        (x: farX, y: nearY),
        (x: farX, y: farY),
        (x: nearX, y: nearY),
      ]);
    } else {
      result.addAll([
        (x: nearX, y: farY),
        (x: farX, y: nearY),
        (x: nearX, y: nearY),
        (x: farX, y: farY),
      ]);
    }

    if (width.isOdd && height.isOdd && width != 7 && height != 7) {
      if (count == 5) result.add((x: middleX, y: middleY));
      result.addAll([
        (x: nearX, y: middleY),
        (x: farX, y: middleY),
      ]);
      if (count == 7) result.add((x: middleX, y: middleY));
      result.addAll([
        (x: middleX, y: nearY),
        (x: middleX, y: farY),
        (x: middleX, y: middleY),
      ]);
    } else if (width.isOdd && width != 7) {
      result.addAll([
        (x: middleX, y: nearY),
        (x: middleX, y: farY),
      ]);
    } else if (height.isOdd && height != 7) {
      result.addAll([
        (x: nearX, y: middleY),
        (x: farX, y: middleY),
      ]);
    }

    return result.take(count).toList();
  }

  /// Converts [vertex] to a Go coordinate string like "D16".
  /// Returns an empty string if [vertex] is out of board.
  String stringifyVertex(Vertex vertex) {
    if (!has(vertex)) return '';
    return '${alpha[vertex.x]}${height - vertex.y}';
  }

  /// Parses a Go coordinate string like "D16" to a [Vertex].
  /// Returns `null` if invalid or out of board.
  Vertex? parseVertex(String coord) {
    if (coord.length < 2) return null;
    final x = alpha.indexOf(coord[0].toUpperCase());
    final n = int.tryParse(coord.substring(1));
    if (n == null) return null;
    final y = height - n;
    final vertex = (x: x, y: y);
    return has(vertex) ? vertex : null;
  }

  /// Returns a human-readable textual representation of the board.
  @override
  String toString() {
    final buf = StringBuffer();
    final labelWidth = height.toString().length;
    String padLeft(String s, int w) => s.padLeft(w);
    String cellSymbol(Stone? s) {
      if (s == null) return '.';
      return s == Stone.black ? 'X' : 'O';
    }

    final header = StringBuffer();
    header.write(' '.padLeft(labelWidth + 1));
    if (width <= alpha.length) {
      for (var x = 0; x < width; x++) {
        header.write(alpha[x]);
        if (x != width - 1) header.write(' ');
      }
    } else {
      for (var x = 1; x <= width; x++) {
        header.write((x % 10).toString());
        if (x != width) header.write(' ');
      }
    }
    buf.writeln(header.toString());
    for (var y = 0; y < height; y++) {
      final rowLabel = (height - y).toString();
      buf.write(padLeft(rowLabel, labelWidth));
      buf.write(' ');
      for (var x = 0; x < width; x++) {
        buf.write(cellSymbol(state[y][x]));
        if (x != width - 1) buf.write(' ');
      }
      buf.write(' ');
      buf.writeln(rowLabel);
    }
    buf.writeln(header.toString());
    return buf.toString();
  }
}
