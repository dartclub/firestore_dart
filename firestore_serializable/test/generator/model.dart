import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

@FirestoreDocument(hasSelfRef: false)
class Submodel {
  @FirestoreAttribute()
  int attribute;
  Submodel({this.attribute});
  factory Submodel.fromMap(Map<String, dynamic> data) =>
      _$submodelFromMap(data);
  Map<String, dynamic> toMap() => _$submodelToMap(this);
}

@FirestoreDocument(nullable: true)
class Model {
  DocumentReference selfRef;

/* ignored attributes */
  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  Function function;

  get foo => 'foo';

  int _privateAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  @FirestoreAttribute(nullable: false)
  int nonNullable;

  @FirestoreAttribute(defaultValue: [1, 2, 3])
  List<int> intListDefaultValue;

  @FirestoreAttribute(
      defaultValue: 'default Value "Let\'s see if the escaping works"')
  String stringDefaultValue;

  List<int> intList;

  List<List<int>> nestedIntList;

  List<List<List<int>>> doublyNestedIntList;

  List<dynamic> dynamicList;

  List<String> stringList;

  List<Submodel> submodelList;

  Set<String> stringSet;

  Set<Submodel> submodelSet;

  List<List<Submodel>> nestedSubmodelList;

  Map<String, dynamic> map;

  Map<String, Map<String, dynamic>> nestedMap;

  Map<String, Submodel> submodelMap;

  DateTime dateTime;

  Blob blob;

  dynamic attribute;

  Model({
    this.selfRef,
    this.ignoredAttribute,
    this.number,
    this.nonNullable,
    this.intListDefaultValue,
    this.doublyNestedIntList,
    this.stringDefaultValue,
    this.intList,
    this.nestedIntList,
    this.dynamicList,
    this.stringList,
    this.submodelList,
    this.nestedSubmodelList,
    this.map,
    this.nestedMap,
    this.submodelMap,
    this.dateTime,
    this.blob,
    this.function,
    this.attribute,
    this.stringSet,
    this.submodelSet,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);
  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);
  Map<String, dynamic> toMap() => _$modelToMap(this);
}
