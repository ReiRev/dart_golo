import './property.dart';
import './property_identifier.dart';

/// Properties of this type concentrate on the current position.
/// Setup properties must not be mixed with move properties within
/// a node.
class SetupPropertyIdentifier extends PropertyIdentifier {
  const SetupPropertyIdentifier._(String value) : super(value);
}
