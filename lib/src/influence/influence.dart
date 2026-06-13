/// Static heuristics for estimating influence maps on Go positions.
///
/// Ported from "@sabaki/influence" (MIT, © Yichuan Shen),
/// https://github.com/SabakiHQ/influence. The upstream functions operate on a
/// 2D sign grid (`data[y][x]`, 1 = black, -1 = white, 0 = empty); here they
/// take a [Board] and convert it to that grid internally, preserving the
/// original algorithms and default constants exactly.
///
/// The file layout mirrors upstream `src/`: this library aggregates the parts
/// (cf. `main.js`); see `helper.dart`, `area_map.dart`,
/// `nearest_neighbor_map.dart`, `radiance_map.dart`, and `influence_map.dart`.
library;

import 'dart:math' as math;

import '../board.dart';

part 'helper.dart';
part 'area_map.dart';
part 'nearest_neighbor_map.dart';
part 'radiance_map.dart';
part 'influence_map.dart';
