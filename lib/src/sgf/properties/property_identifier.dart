import 'package:equatable/equatable.dart';

class PropertyIdentifier extends Equatable {
  final String value;

  const PropertyIdentifier(this.value);

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
