import 'package:equatable/equatable.dart';

import 'property_identifier.dart';

class Property extends Equatable {
  /// SGF Properties (FF[4])

  final PropertyIdentifier identifier;
  final Object _value;

  get value => _value;

  Property({
    required this.identifier,
    required Object value,
  }) : _value = value;

  @override
  String toString() {
    return "${identifier.value}[$_value]";
  }

  @override
  List<Object?> get props => [identifier, _value];
}
