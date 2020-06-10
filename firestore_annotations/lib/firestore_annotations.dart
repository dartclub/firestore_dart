/* Firestore Serializable Annotations */
library firestore_annotations;

class FirestoreDocument {
  final bool hasSelfRef;
  final bool flutterFormHelper;
  const FirestoreDocument({
    this.hasSelfRef = true,
    this.flutterFormHelper = false,
  });
}

/* Properties */
class FirestoreAttribute {
  final bool ignore;
  final bool nullable;
  final String alias;
  final dynamic defaultValue;
  final String flutterValidatorMessage;

  const FirestoreAttribute({
    this.ignore = false,
    this.nullable = true,
    this.alias = null,
    this.defaultValue = null,
    this.flutterValidatorMessage = 'Couldn\'t parse input!',
  });
}
