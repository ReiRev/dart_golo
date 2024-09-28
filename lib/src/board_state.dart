import 'coordinate_status.dart';
import 'player.dart';
import 'errors.dart';

class BoardState {
  final int _boardSize;

  /// The size of the board.
  int get boardSize => _boardSize;

  static final int _passLoc = 0;

  /// The board represented as a flattened list.
  late final List<CoordinateStatus> _flattenedBoard;
  late final int _arrSize;
  late final int _dy;

  /// The offsets to the adjacent points of the flattened list.
  late final List<int> _adjOffsets;

  /// The offsets to the diagonal points of the flattened list.
  // late final List<int> _diagOffsets;

  late List<int> _groupHeadIndices;
  late List<int> _groupStoneCounts;
  late List<int> _groupLibertyCounts;
  late List<int> _groupNextIndices;
  late List<int> _groupPrevIndices;

  int? _simpleKoPoint;
  int get simpleKoPoint => _simpleKoPoint!;

  BoardState({
    required int boardSize,
  }) : _boardSize = boardSize {
    _arrSize = (boardSize + 1) * (boardSize + 2) + 1;
    _flattenedBoard = List.filled(_arrSize, CoordinateStatus.empty);
    _dy = boardSize + 1;
    _adjOffsets = [-_dy, -1, 1, _dy];
    // _diagOffsets = [-_dy - 1, -_dy + 1, _dy - 1, _dy + 1];

    _simpleKoPoint = null;

    _groupHeadIndices = List.filled(_arrSize, 0);
    _groupStoneCounts = List.filled(_arrSize, 0);
    _groupLibertyCounts = List.filled(_arrSize, 0);
    _groupNextIndices = List.filled(_arrSize, 0);
    _groupPrevIndices = List.filled(_arrSize, 0);

    for (int i = -1; i < boardSize; i++) {
      _flattenedBoard[_loc(i, -1)] = CoordinateStatus.wall;
      _flattenedBoard[_loc(i, boardSize)] = CoordinateStatus.wall;
      _flattenedBoard[_loc(-1, i)] = CoordinateStatus.wall;
      _flattenedBoard[_loc(boardSize, i)] = CoordinateStatus.wall;
    }

    // Catch errors easily.
    _groupHeadIndices[0] = -1;
    _groupNextIndices[0] = -1;
    _groupPrevIndices[0] = -1;
  }

  CoordinateStatus at(int x, int y) {
    return _flattenedBoard[_loc(x, y)];
  }

  /// Returns the index of the location (x, y) in the _flattenedBoard array.
  int _loc(int x, int y) {
    return (x + 1) + _dy * (y + 1);
  }

  bool _isOnBoard(int loc) {
    return loc >= 0 &&
        loc < _arrSize &&
        _flattenedBoard[loc] != CoordinateStatus.wall;
  }

  bool _wouldBeSingleStoneSuicide(Player player, int loc) {
    // If empty, not suicide
    if (_adjOffsets.any(
        (offset) => _flattenedBoard[loc + offset] == CoordinateStatus.empty)) {
      return false;
    }
    // If capture, not suicide
    if (_adjOffsets.any((offset) =>
        _flattenedBoard[loc + offset] == player.opponent &&
        _groupLibertyCounts[_groupHeadIndices[loc + offset]] == 1)) {
      return false;
    }
    // If connects to own stone, then not single stone suicide
    if (_adjOffsets.any((offset) => _flattenedBoard[offset + loc] == player)) {
      return false;
    }
    return true;
  }

  // bool _wouldBeSuicide(Player player, int loc) {
  //   // If empty, not suicide
  //   if (_adjOffsets.any(
  //       (offset) => _flattenedBoard[loc + offset] == CoordinateStatus.empty)) {
  //     return false;
  //   }
  //   // If capture, not suicide
  //   if (_adjOffsets.any((offset) =>
  //       _flattenedBoard[loc + offset] == player.opponent &&
  //       _groupLibertyCounts[_groupHeadIndices[loc + offset]] == 1)) {
  //     return false;
  //   }
  //   // If connects to own stone, then not single stone suicide
  //   if (_adjOffsets.any((offset) =>
  //       _flattenedBoard[offset + loc] == player.opponent &&
  //       _groupLibertyCounts[_groupHeadIndices[offset + loc]] > 1)) {
  //     return false;
  //   }
  //   return true;
  // }

  bool _isGroupAdjacent(int head, int loc) {
    return _adjOffsets.any((offset) => _groupHeadIndices[loc + offset] == head);
  }

  void _mergeUnsafe(int loc0, int loc1) {
    // Can be simpler using UnionFind?
    int parent, child;
    if (_groupStoneCounts[_groupHeadIndices[loc0]] >=
        _groupStoneCounts[_groupHeadIndices[loc1]]) {
      parent = loc0;
      child = loc1;
    } else {
      child = loc1;
      parent = loc0;
    }

    int phead = _groupHeadIndices[parent];
    int chead = _groupHeadIndices[child];
    if (phead == chead) {
      return;
    }

    // Walk the child group assigning the new head and simultaneously counting liberties
    int newStoneCount = _groupStoneCounts[phead] + _groupStoneCounts[chead];
    int newLiberties = _groupLibertyCounts[phead];
    int loc = child;
    while (true) {
      for (var offset in _adjOffsets) {
        int adj = loc + offset;
        if (_flattenedBoard[adj] == CoordinateStatus.empty &&
            !_isGroupAdjacent(phead, adj)) {
          newLiberties += 1;
        }
      }
      // Now assign the new parent head to take over the child (this also prevents double-counting liberties)
      _groupHeadIndices[loc] = phead;

      loc = _groupNextIndices[loc];
      if (loc == child) {
        break;
      }
    }

    // Zero out the old head
    _groupStoneCounts[chead] = 0;
    _groupLibertyCounts[chead] = 0;

    // Update the new head
    _groupStoneCounts[phead] = newStoneCount;
    _groupLibertyCounts[phead] = newLiberties;

    // Combine the linked lists
    int plast = _groupPrevIndices[phead];
    int clast = _groupPrevIndices[chead];
    _groupNextIndices[clast] = phead;
    _groupNextIndices[plast] = chead;
    _groupPrevIndices[chead] = plast;
    _groupPrevIndices[phead] = clast;
  }

  void _removeUnsafe(int group) {
    // int head = _groupHeadIndices[group];
    Player player = _flattenedBoard[group].player;
    Player opponent = player.opponent;

    // Walk all the stones in the group and delete them
    int loc = group;
    while (true) {
      // Add a liberty to all surrounding opposing groups, taking care to avoid double counting.
      int adj0 = loc + _adjOffsets[0];
      int adj1 = loc + _adjOffsets[1];
      int adj2 = loc + _adjOffsets[2];
      int adj3 = loc + _adjOffsets[3];
      if (_flattenedBoard[adj0] == opponent) {
        _groupLibertyCounts[_groupHeadIndices[adj0]] += 1;
      }
      if (_flattenedBoard[adj1] == opponent) {
        if (_groupHeadIndices[adj1] != _groupHeadIndices[adj0]) {
          _groupLibertyCounts[_groupHeadIndices[adj1]] += 1;
        }
      }
      if (_flattenedBoard[adj2] == opponent) {
        if (_groupHeadIndices[adj2] != _groupHeadIndices[adj0] &&
            _groupHeadIndices[adj2] != _groupHeadIndices[adj1]) {
          _groupLibertyCounts[_groupHeadIndices[adj2]] += 1;
        }
      }
      if (_flattenedBoard[adj3] == opponent) {
        if (_groupHeadIndices[adj3] != _groupHeadIndices[adj0] &&
            _groupHeadIndices[adj3] != _groupHeadIndices[adj1] &&
            _groupHeadIndices[adj3] != _groupHeadIndices[adj2]) {
          _groupLibertyCounts[_groupHeadIndices[adj3]] += 1;
        }
      }

      int nextLoc = _groupNextIndices[loc];

      // Zero out all the stuff
      _flattenedBoard[loc] = CoordinateStatus.empty;
      _groupHeadIndices[loc] = 0;
      _groupNextIndices[loc] = 0;
      _groupPrevIndices[loc] = 0;

      // Advance around the linked list
      loc = nextLoc;
      if (loc == group) {
        break;
      }
    }
  }

  void _addUnsafe(Player player, int loc) {
    _flattenedBoard[loc] = CoordinateStatus.fromPlayer(player);

    _groupHeadIndices[loc] = loc;
    _groupStoneCounts[loc] = 1;
    int liberties = 0;
    for (var offset in _adjOffsets) {
      if (_flattenedBoard[loc + offset] == CoordinateStatus.empty) {
        liberties += 1;
      }
    }
    _groupLibertyCounts[loc] = liberties;
    _groupNextIndices[loc] = loc;
    _groupPrevIndices[loc] = loc;

    // Fill surrounding liberties of all adjacent groups
    // Carefully avoid double counting
    int adj0 = loc + _adjOffsets[0];
    int adj1 = loc + _adjOffsets[1];
    int adj2 = loc + _adjOffsets[2];
    int adj3 = loc + _adjOffsets[3];
    if (_flattenedBoard[adj0] == CoordinateStatus.black ||
        _flattenedBoard[adj0] == CoordinateStatus.white) {
      _groupLibertyCounts[_groupHeadIndices[adj0]] -= 1;
    }
    if (_flattenedBoard[adj1] == CoordinateStatus.black ||
        _flattenedBoard[adj1] == CoordinateStatus.white) {
      if (_groupHeadIndices[adj1] != _groupHeadIndices[adj0]) {
        _groupLibertyCounts[_groupHeadIndices[adj1]] -= 1;
      }
    }
    if (_flattenedBoard[adj2] == CoordinateStatus.black ||
        _flattenedBoard[adj2] == CoordinateStatus.white) {
      if (_groupHeadIndices[adj2] != _groupHeadIndices[adj0] &&
          _groupHeadIndices[adj2] != _groupHeadIndices[adj1]) {
        _groupLibertyCounts[_groupHeadIndices[adj2]] -= 1;
      }
    }
    if (_flattenedBoard[adj3] == CoordinateStatus.black ||
        _flattenedBoard[adj3] == CoordinateStatus.white) {
      if (_groupHeadIndices[adj3] != _groupHeadIndices[adj0] &&
          _groupHeadIndices[adj3] != _groupHeadIndices[adj1] &&
          _groupHeadIndices[adj3] != _groupHeadIndices[adj2]) {
        _groupLibertyCounts[_groupHeadIndices[adj3]] -= 1;
      }
    }

    // Merge groups
    for (var offset in _adjOffsets) {
      if (_flattenedBoard[loc + offset] ==
          CoordinateStatus.fromPlayer(player)) {
        _mergeUnsafe(loc, loc + offset);
      }
    }

    // Resolve captures
    int opponentStoneCaptures = 0;
    int caploc = 0;
    for (var offset in _adjOffsets) {
      if (_flattenedBoard[loc + offset] == player.opponent &&
          _groupLibertyCounts[_groupHeadIndices[loc + offset]] == 0) {
        // Capture the stones
        opponentStoneCaptures +=
            _groupStoneCounts[_groupHeadIndices[loc + offset]];
        caploc = loc + offset;
        _removeUnsafe(loc + offset);
      }
    }

    // Suicide
    // TODO: do this in Game class
    // int playerStoneCaptures = 0;
    if (_groupLibertyCounts[_groupHeadIndices[loc]] == 0) {
      // playerStoneCaptures += _groupStoneCounts[_groupHeadIndices[loc]];
      _removeUnsafe(loc);
    }
    // self.num_captures_made[pla] += pla_stones_captured
    // self.num_captures_made[opp] += opp_stones_captured
    // self.num_non_pass_moves_made[pla] += 1

    // Update ko point for legality checking
    // if (
    //     opp_stones_captured == 1
    //     and self.group_stone_count[self.group_head[loc]] == 1
    //     and self.group_liberty_count[self.group_head[loc]] == 1
    // ):
    //     self.simple_ko_point = caploc
    // else:
    //     self.simple_ko_point = None
    if (opponentStoneCaptures == 1 &&
        _groupStoneCounts[_groupHeadIndices[loc]] == 1 &&
        _groupLibertyCounts[_groupHeadIndices[loc]] == 1) {
      _simpleKoPoint = caploc;
    } else {
      _simpleKoPoint = null;
    }
  }

  void _playUnsafe(Player player, int loc) {
    if (loc == _passLoc) {
      _simpleKoPoint = null;
    } else {
      _addUnsafe(player, loc);
    }
  }

  void _play(Player player, int loc) {
    if (loc != _passLoc) {
      if (!_isOnBoard(loc)) {
        throw IllegalMoveError("Location is outside of the board.");
      }
      if (_flattenedBoard[loc] != CoordinateStatus.empty) {
        throw IllegalMoveError("Location is not empty.");
      }
      if (_wouldBeSingleStoneSuicide(player, loc)) {
        throw IllegalMoveError("Move would be illegal single stone suicide");
      }
      if (loc == _simpleKoPoint) {
        throw IllegalMoveError("Move would be illegal simple ko recapture");
      }
    }
    _playUnsafe(player, loc);
  }

  void play(Player player, int x, int y) {
    _play(player, _loc(x, y));
  }
}
