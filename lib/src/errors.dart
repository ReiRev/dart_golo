class IllegalMoveError extends Error {
  final String message;

  IllegalMoveError(this.message);

  @override
  String toString() {
    return 'IllegalMoveError: $message';
  }
}
