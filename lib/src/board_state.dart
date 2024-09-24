import 'coordinate_status.dart';
import 'player.dart';
import 'errors.dart';

class BoardState {
  final int boardSize;
  static int passLoc = 0;

  /// The board represented as a flattened list.
  late final List<CoordinateStatus> flattenedBoard;
  late final int arrSize;
  late final int dy;

  /// The offsets to the adjacent points of the flattened list.
  late final List<int> adjOffsets;

  /// The offsets to the diagonal points of the flattened list.
  late final List<int> diagOffsets;

  late List<int> groupHeadIndices;
  late List<int> groupStoneCounts;
  late List<int> groupLibertyCounts;
  late List<int> groupNextIndices;
  late List<int> groupPrevIndices;

  int? simpleKoPoint;

  BoardState({
    required this.boardSize,
  }) {
    arrSize = (boardSize + 1) * (boardSize + 2) + 1;
    flattenedBoard = List.filled(arrSize, CoordinateStatus.empty);
    dy = boardSize + 1;
    adjOffsets = [-dy, -1, 1, dy];
    diagOffsets = [-dy - 1, -dy + 1, dy - 1, dy + 1];

    simpleKoPoint = null;

    groupHeadIndices = List.filled(arrSize, 0);
    groupStoneCounts = List.filled(arrSize, 0);
    groupLibertyCounts = List.filled(arrSize, 0);
    groupNextIndices = List.filled(arrSize, 0);
    groupPrevIndices = List.filled(arrSize, 0);

    for (int i = -1; i < boardSize; i++) {
      flattenedBoard[loc(i, -1)] = CoordinateStatus.wall;
      flattenedBoard[loc(i, boardSize)] = CoordinateStatus.wall;
      flattenedBoard[loc(-1, i)] = CoordinateStatus.wall;
      flattenedBoard[loc(boardSize, i)] = CoordinateStatus.wall;
    }

    // Catch errors easily.
    groupHeadIndices[0] = -1;
    groupNextIndices[0] = -1;
    groupPrevIndices[0] = -1;
  }

  /// Returns the index of the location (x, y) in the flattenedBoard array.
  int loc(int x, int y) {
    return (x + 1) + dy * (y + 1);
  }

  bool isOnBoard(int loc) {
    return loc >= 0 &&
        loc < arrSize &&
        flattenedBoard[loc] != CoordinateStatus.wall;
  }

  bool wouldBeSingleStoneSuicide(Player player, int loc) {
    // If empty, not suicide
    if (adjOffsets.any(
        (offset) => flattenedBoard[loc + offset] == CoordinateStatus.empty)) {
      return false;
    }
    // If capture, not suicide
    if (adjOffsets.any((offset) =>
        flattenedBoard[loc + offset] == player.opponent &&
        groupLibertyCounts[groupHeadIndices[loc + offset]] == 1)) {
      return false;
    }
    // If connects to own stone, then not single stone suicide
    if (adjOffsets.any((offset) => flattenedBoard[offset + loc] == player)) {
      return false;
    }
    return true;
  }

  bool wouldBeSuicide(Player player, int loc) {
    // If empty, not suicide
    if (adjOffsets.any(
        (offset) => flattenedBoard[loc + offset] == CoordinateStatus.empty)) {
      return false;
    }
    // If capture, not suicide
    if (adjOffsets.any((offset) =>
        flattenedBoard[loc + offset] == player.opponent &&
        groupLibertyCounts[groupHeadIndices[loc + offset]] == 1)) {
      return false;
    }
    // If connects to own stone, then not single stone suicide
    if (adjOffsets.any((offset) =>
        flattenedBoard[offset + loc] == player.opponent &&
        groupLibertyCounts[groupHeadIndices[offset + loc]] > 1)) {
      return false;
    }
    return true;
  }

  bool isGroupAdjacent(int head, int loc) {
    return adjOffsets.any((offset) => groupHeadIndices[loc + offset] == head);
  }

  void mergeUnsafe(int loc0, int loc1) {
    // Can be simpler using UnionFind?
    int parent, child;
    if (groupStoneCounts[groupHeadIndices[loc0]] >=
        groupStoneCounts[groupHeadIndices[loc1]]) {
      parent = loc0;
      child = loc1;
    } else {
      child = loc1;
      parent = loc0;
    }

    int phead = groupHeadIndices[parent];
    int chead = groupHeadIndices[child];
    if (phead == chead) {
      return;
    }

    // Walk the child group assigning the new head and simultaneously counting liberties
    int newStoneCount = groupStoneCounts[phead] + groupStoneCounts[chead];
    int newLiberties = groupLibertyCounts[phead];
    int loc = child;
    while (true) {
      adjOffsets.forEach((offset) {
        int adj = loc + offset;
        if (flattenedBoard[adj] == CoordinateStatus.empty &&
            !isGroupAdjacent(phead, adj)) {
          newLiberties += 1;
        }
      });
      // Now assign the new parent head to take over the child (this also prevents double-counting liberties)
      groupHeadIndices[loc] = phead;

      loc = groupNextIndices[loc];
      if (loc == child) {
        break;
      }
    }

    // Zero out the old head
    groupStoneCounts[chead] = 0;
    groupLibertyCounts[chead] = 0;

    // Update the new head
    groupStoneCounts[phead] = newStoneCount;
    groupLibertyCounts[phead] = newLiberties;

    // Combine the linked lists
    int plast = groupPrevIndices[phead];
    int clast = groupPrevIndices[chead];
    groupNextIndices[clast] = phead;
    groupNextIndices[plast] = chead;
    groupPrevIndices[chead] = plast;
    groupPrevIndices[phead] = clast;
  }

  void removeUnsafe(int group) {
    int head = groupHeadIndices[group];
    Player player = flattenedBoard[group].player;
    Player opponent = player.opponent;

    // Walk all the stones in the group and delete them
    int loc = group;
    while (true) {
      // Add a liberty to all surrounding opposing groups, taking care to avoid double counting.
      int adj0 = loc + adjOffsets[0];
      int adj1 = loc + adjOffsets[1];
      int adj2 = loc + adjOffsets[2];
      int adj3 = loc + adjOffsets[3];
      if (flattenedBoard[adj0] == opponent) {
        groupLibertyCounts[groupHeadIndices[adj0]] += 1;
      }
      if (flattenedBoard[adj1] == opponent) {
        if (groupHeadIndices[adj1] != groupHeadIndices[adj0]) {
          groupLibertyCounts[groupHeadIndices[adj1]] += 1;
        }
      }
      if (flattenedBoard[adj2] == opponent) {
        if (groupHeadIndices[adj2] != groupHeadIndices[adj0] &&
            groupHeadIndices[adj2] != groupHeadIndices[adj1]) {
          groupLibertyCounts[groupHeadIndices[adj2]] += 1;
        }
      }
      if (flattenedBoard[adj3] == opponent) {
        if (groupHeadIndices[adj3] != groupHeadIndices[adj0] &&
            groupHeadIndices[adj3] != groupHeadIndices[adj1] &&
            groupHeadIndices[adj3] != groupHeadIndices[adj2]) {
          groupLibertyCounts[groupHeadIndices[adj3]] += 1;
        }
      }

      int nextLoc = groupNextIndices[loc];

      // Zero out all the stuff
      flattenedBoard[loc] = CoordinateStatus.empty;
      groupHeadIndices[loc] = 0;
      groupNextIndices[loc] = 0;
      groupPrevIndices[loc] = 0;

      // Advance around the linked list
      loc = nextLoc;
      if (loc == group) {
        break;
      }
    }
  }

  void addUnsafe(Player player, int loc) {
    flattenedBoard[loc] = CoordinateStatus.fromPlayer(player);

    groupHeadIndices[loc] = loc;
    groupStoneCounts[loc] = 1;
    int liberties = 0;
    adjOffsets.forEach((offset) {
      if (flattenedBoard[loc + offset] == CoordinateStatus.empty) {
        liberties += 1;
      }
    });
    groupLibertyCounts[loc] = liberties;
    groupNextIndices[loc] = loc;
    groupPrevIndices[loc] = loc;

    // Fill surrounding liberties of all adjacent groups
    // Carefully avoid double counting
    int adj0 = loc + adjOffsets[0];
    int adj1 = loc + adjOffsets[1];
    int adj2 = loc + adjOffsets[2];
    int adj3 = loc + adjOffsets[3];
    if (flattenedBoard[adj0] == CoordinateStatus.black ||
        flattenedBoard[adj0] == CoordinateStatus.white) {
      groupLibertyCounts[groupHeadIndices[adj0]] -= 1;
    }
    if (flattenedBoard[adj1] == CoordinateStatus.black ||
        flattenedBoard[adj1] == CoordinateStatus.white) {
      if (groupHeadIndices[adj1] != groupHeadIndices[adj0]) {
        groupLibertyCounts[groupHeadIndices[adj1]] -= 1;
      }
    }
    if (flattenedBoard[adj2] == CoordinateStatus.black ||
        flattenedBoard[adj2] == CoordinateStatus.white) {
      if (groupHeadIndices[adj2] != groupHeadIndices[adj0] &&
          groupHeadIndices[adj2] != groupHeadIndices[adj1]) {
        groupLibertyCounts[groupHeadIndices[adj2]] -= 1;
      }
    }
    if (flattenedBoard[adj3] == CoordinateStatus.black ||
        flattenedBoard[adj3] == CoordinateStatus.white) {
      if (groupHeadIndices[adj3] != groupHeadIndices[adj0] &&
          groupHeadIndices[adj3] != groupHeadIndices[adj1] &&
          groupHeadIndices[adj3] != groupHeadIndices[adj2]) {
        groupLibertyCounts[groupHeadIndices[adj3]] -= 1;
      }
    }

    // Merge groups
    for (var offset in adjOffsets) {
      if (flattenedBoard[loc + offset] == CoordinateStatus.fromPlayer(player)) {
        mergeUnsafe(loc, loc + offset);
      }
    }

    // Resolve captures
    int opponentStoneCaptures = 0;
    int caploc = 0;
    for (var offset in adjOffsets) {
      if (flattenedBoard[loc + offset] == player.opponent &&
          groupLibertyCounts[groupHeadIndices[loc + offset]] == 0) {
        // Capture the stones
        opponentStoneCaptures +=
            groupStoneCounts[groupHeadIndices[loc + offset]];
        caploc = loc + offset;
        removeUnsafe(loc + offset);
      }
    }

    // Suicide
    // TODO: do this in Game class
    // int playerStoneCaptures = 0;
    if (groupLibertyCounts[groupHeadIndices[loc]] == 0) {
      // playerStoneCaptures += groupStoneCounts[groupHeadIndices[loc]];
      removeUnsafe(loc);
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
        groupStoneCounts[groupHeadIndices[loc]] == 1 &&
        groupLibertyCounts[groupHeadIndices[loc]] == 1) {
      simpleKoPoint = caploc;
    } else {
      simpleKoPoint = null;
    }
  }

  void playUnsafe(Player player, int loc) {
    if (loc == passLoc) {
      simpleKoPoint = null;
    } else {
      addUnsafe(player, loc);
    }
  }

  void play(Player player, int loc) {
    if (loc != passLoc) {
      if (!isOnBoard(loc)) {
        throw IllegalMoveError("Location is outside of the board.");
      }
      if (flattenedBoard[loc] != CoordinateStatus.empty) {
        throw IllegalMoveError("Location is not empty.");
      }
      if (wouldBeSingleStoneSuicide(player, loc)) {
        throw IllegalMoveError("Move would be illegal single stone suicide");
      }
      if (loc == simpleKoPoint) {
        throw IllegalMoveError("Move would be illegal simple ko recapture");
      }
    }
    playUnsafe(player, loc);
  }
}
