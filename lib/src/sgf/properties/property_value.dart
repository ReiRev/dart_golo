import 'package:equatable/equatable.dart';

class PropertyValue extends Equatable {
  final Object value;

  const PropertyValue(this.value);

  @override
  List<Object?> get props => [value];
}

// class MovePropertyValue extends Equatable {
//   String value;

//   // Todo: validation
//   MovePropertyValue(this.value);

//   @override
//   List<Object?> get props => [value];
// }
