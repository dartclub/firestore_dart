import 'package:firestore_annotations/firestore_annotations.dart';

/* You don't have to use this firestore package, you can also use cloud_firestore or others */
import 'package:firestore_api/firestore_api.dart';

/* This annotation indicates that this is a model for firestore */
@FirestoreDocument()
class Model {
  DocumentReference selfRef;

  /* attribute annotations */

  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  @FirestoreAttribute(defaultValue: [1, 2, 3])
  List<int> intListDefaultValue;

  /* functions are ignored */
  Function function;

  /* private attributes as well */
  int _privateAttribute;

  List<int> intList;

  List<List<int>> nestedIntList;

  List<List<List<int>>> doublyNestedList;

  List<dynamic> dynamicList;

  DateTime dateTime;

  Blob blob;

  dynamic attribute;

  Model({
    this.selfRef,
    this.ignoredAttribute,
    this.number,
    this.intListDefaultValue,
    this.doublyNestedList,
    this.intList,
    this.nestedIntList,
    this.dynamicList,
    this.dateTime,
    this.blob,
    this.function,
    this.attribute,
  });

  /* constructors */
  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);

  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);

  /* toMap() method is generated as an extension method, but can also be accessed globally via _$modelToMap(Model model) */
}
