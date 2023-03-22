/* Firestore Serializable Annotations */
library firestore_annotations;

class FirestoreDocument {
  final bool hasSelfRef;
  final bool nullable;

  const FirestoreDocument({
    this.nullable = false,
    this.hasSelfRef = true,
  });
}

/* Properties */
class FirestoreAttribute {
  final bool ignore;
  final bool nullable;
  final String? alias;
  final dynamic defaultValue;

  const FirestoreAttribute({
    this.ignore = false,
    this.nullable = true,
    this.alias = null,
    this.defaultValue = null,
  });
}
