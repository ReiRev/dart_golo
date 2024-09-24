// import 'dart:convert';
// import 'dart:typed_data';

// // sealed class Player implements Enum {
// //   static const Player black = Player._('black');
// //   static const Player white = Player._('white');

// //   const Player._(String value) : super(value);
// // }

// class Board {
//   static int passLoc = 0;

//   /// The size of the board.

//   /// The number of non pass moves made by each player.
//   late Map<Player, int> moves;

//   Board({
//     this.size = 19,
//   }) {
//     arrSize = (size + 1) * (size + 2) + 1;
//     dy = size + 1;
//     adjOffsets = [-dy, -1, 1, dy];
//     diagOffsets = [-dy - 1, -dy + 1, dy - 1, dy + 1];

//     player = Player.black;
//     // initial value is zero
//     board = List.filled(arrSize, CoordinateStatus.empty);
//     // TODO: Make linked list class
//     groupHeadIndices = Uint16List(arrSize);
//     groupStoneCounts = Uint16List(arrSize);
//     groupLibertyCounts = Uint16List(arrSize);
//     groupNextIndices = Uint16List(arrSize);
//     groupPrevIndices = Uint16List(arrSize);
//     simpleKoPoint = null;
//     captures = {Player.black: 0, Player.white: 0};
//     moves = {Player.black: 0, Player.white: 0};

//     for (int i = -1; i < size; i++) {
//       board[loc(i, -1)] = CoordinateStatus.wall;
//       board[loc(i, size)] = CoordinateStatus.wall;
//       board[loc(-1, i)] = CoordinateStatus.wall;
//       board[loc(size, i)] = CoordinateStatus.wall;
//     }

//     // Catch errors easily.
//     groupHeadIndices[0] = -1;
//     groupNextIndices[0] = -1;
//     groupPrevIndices[0] = -1;
//   }

//   Player get opponent => player == Player.black ? Player.white : Player.black;

//   /// Returns the index of the location (x, y) in the board array.
//   int loc(int x, int y) {
//     return (x + 1) + dy * (y + 1);
//   }

//   int locX(loc) => (loc % dy) - 1;

//   int locY(loc) => (loc / dy) - 1;

//   bool isAdjacent(int loc1, int loc2) {
//     return adjOffsets.any((offset) => loc1 == offset + loc2);
//   }

//   int geLibertyCount(int loc) {
//     if (board[loc] == CoordinateStatus.empty ||
//         board[loc] == CoordinateStatus.wall) {
//       return 0;
//     }
//     return groupLibertyCounts[groupHeadIndices[loc]];
//   }

//   bool isSipleEye(int loc) {
//     if (adjOffsets.any((offset) =>
//         // TODO: better implementation? I don't want to use .status
//         board[loc + offset] != player.status &&
//         board[loc + offset] != CoordinateStatus.wall)) {
//       return false;
//     }
//     int opponentCorners = 0;
//     for (var offset in diagOffsets) {
//       if (board[loc + offset] == opponent.status) {
//         opponentCorners++;
//       }
//     }
//     if (opponentCorners >= 2) {
//       return false;
//     }
//     if (opponentCorners <= 0) {
//       return true;
//     }

//     if (adjOffsets
//         .any((offset) => board[loc + offset] == CoordinateStatus.wall)) {
//       return false;
//     }

//     return true;
//   }

//   bool isOnBoard(int loc) {
//     return loc >= 0 && loc < arrSize && board[loc] != CoordinateStatus.wall;
//   }

//   bool wouldBeSingleStoneSuicide(Player player, int loc) {
//     // If empty, not suicide
//     if (adjOffsets
//         .any((offset) => board[loc + offset] == CoordinateStatus.empty)) {
//       return false;
//     }
//     // If capture, not suicide
//     if (adjOffsets.any((offset) =>
//         board[loc + offset] == opponent.status &&
//         groupLibertyCounts[groupHeadIndices[loc + offset]] == 1)) {
//       return false;
//     }
//     // If connects to own stone, then not single stone suicide
//     if (adjOffsets.any((offset) => board[offset + loc] == player.status)) {
//       return false;
//     }
//     return true;
//   }

//   bool wouldBeSuicide(Player player, int loc) {
//     // If empty, not suicide
//     if (adjOffsets
//         .any((offset) => board[loc + offset] == CoordinateStatus.empty)) {
//       return false;
//     }
//     // If capture, not suicide
//     if (adjOffsets.any((offset) =>
//         board[loc + offset] == opponent.status &&
//         groupLibertyCounts[groupHeadIndices[loc + offset]] == 1)) {
//       return false;
//     }
//     // If connects to own stone, then not single stone suicide
//     if (adjOffsets.any((offset) =>
//         board[offset + loc] == player.status &&
//         groupLibertyCounts[groupHeadIndices[offset + loc]] > 1)) {
//       return false;
//     }
//     return true;
//   }

//   bool wouldBeLegal(Player player, int loc) {
//     if (loc == passLoc) {
//       return true;
//     }
//     if (!isOnBoard(loc)) {
//       return false;
//     }
//     if (board[loc] != CoordinateStatus.empty) {
//       return false;
//     }
//     if (wouldBeSingleStoneSuicide(player, loc)) {
//       return false;
//     }
//     if (loc == simpleKoPoint) {
//       return false;
//     }
//     return true;
//   }

//   void play(Player player, int loc) {
//     if (loc != passLoc) {
//       if (!isOnBoard(loc)) {
//         throw IllegalMoveError("Location is outside of the board.");
//       }
//       if (board[loc] != CoordinateStatus.empty) {
//         throw IllegalMoveError("Location is not empty.");
//       }
//       if (wouldBeSingleStoneSuicide(player, loc)) {
//         throw IllegalMoveError("Move would be illegal single stone suicide");
//       }
//       if (loc == simpleKoPoint) {
//         throw IllegalMoveError("Move would be illegal simple ko recapture");
//       }
//     }
//     playUnsafe(player, loc);
//   }

//   void playUnsafe(Player player, int loc) {
//     if (loc == passLoc) {
//       simpleKoPoint = null;
//       this.player = opponent;
//     } else {
//       addUnsafe(player, loc);
//       player = opponent;
//     }
//   }

//   void addUnsafe(Player player, int loc) {}

//   @override
//   String toString() {
//     String result = "";
//     for (int y = 0; y < size; y++) {
//       // " 1  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  ⚫\n"
//       result += (y + 1).toString().padLeft(2, ' ');
//       for (int x = 0; x < size; x++) {
//         switch (board[loc(x, y)]) {
//           case CoordinateStatus.black:
//             result += "  ⚫";
//           case CoordinateStatus.white:
//             result += "  ⚪";
//           case CoordinateStatus.empty:
//             result += "  .";
//           case CoordinateStatus.wall:
//             result += "  #";
//         }
//       }
//       result += "\n";
//     }

//     // "    A  B  C  D  E  F  G  H  J  K  L  M  N  O  P  Q  R  S  T"
//     // add use 'A'.codeUnitAt(0)
//     result +=
//         "    ${List.generate(size, (index) => String.fromCharCode('A'.codeUnitAt(0) + index)).join("  ")}";

//     return result;
//   }
// }
