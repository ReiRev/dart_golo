import 'package:golo/golo.dart';

/// Converts a `data[y][x]` sign grid (1 = black, -1 = white, 0 = empty)
/// into a [Board].
Board boardFromSigns(List<List<int>> data) {
  return Board([
    for (final row in data)
      [
        for (final sign in row)
          switch (sign) {
            1 => Stone.black,
            -1 => Stone.white,
            _ => null,
          }
      ]
  ]);
}
