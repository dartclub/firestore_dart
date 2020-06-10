/* Firestore Serializable Annotations */
library firestore_annotations;

class FirestoreDocument {
  final bool hasSelfRef;
  const FirestoreDocument({
    this.hasSelfRef = true,
  });
}

/* Properties */
class FirestoreAttribute {
  final bool ignore;
  final bool nullable;
  final String alias;
  final dynamic defaultValue;

  const FirestoreAttribute({
    this.ignore = false,
    this.nullable = true,
    this.alias = null,
    this.defaultValue = null,
  });
}
