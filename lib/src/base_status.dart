// This is only for enabling comparison between Player and CoordinateStatus.
abstract class BaseStatus {
  final int value;

  @override
  int get hashCode => value;

  const BaseStatus(this.value);

  @override
  bool operator ==(Object other) {
    if (other is BaseStatus) {
      return value == other.value;
    }
    throw ArgumentError('Invalid argument type');
  }
}
