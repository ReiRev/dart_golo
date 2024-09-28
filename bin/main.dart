import 'package:golo/golo.dart';
import 'dart:io';

void main() {
  print('Welcome to Golo!');
  // input board size
  print('Enter board size:');
  final input = stdin.readLineSync();
  if (input == null) {
    return;
  }
  final boardSize = int.tryParse(input);
  final game = Game(boardSize: boardSize ?? 19);
  print(game);
  Player player = Player.black;
  while (true) {
    print('Player $player, enter x y:');
    final input = stdin.readLineSync();
    if (input == null) {
      break;
    }
    final parts = input.split(' ');
    if (parts.length != 2) {
      break;
    }
    final x = int.tryParse(parts[0]);
    final y = int.tryParse(parts[1]);
    if (x == null || y == null) {
      break;
    }
    // check error
    try {
      game.play(player, x, y);
      player = player.opponent;
    } catch (e) {
      print(e);
    }
    print(game);
  }
}
