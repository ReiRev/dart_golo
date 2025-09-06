/// Minimal utilities for tokenizing and parsing SGF (Smart Game Format).
///
/// The primary entry point is [Parser], which converts SGF text into a `Node`
/// tree. `Token` and `TokenIterator` provide lower-level APIs used by the
/// parser.
library golo_sgf;

export 'src/sgf/token.dart';
export 'src/sgf/node.dart';
export 'src/sgf/parser.dart';
