import 'package:firestore_api/firestore_api.dart';

part 'model.g.dart';

@FirestoreSubdocument()
class Submodel {
  factory Submodel.fromSnapshot(Map<String, dynamic> data) =>
      _$submodelFromSnapshot(data);
  Map<String, dynamic> toMap() => _$submodelToMap(this);
  Submodel();
}

@FirestoreDocument()
class Model {
  DocumentReference selfRef;

  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  int _privateAttribute;

  Submodel submodel;

  List<Submodel> submodelList;

  List<int> intList;

  List<dynamic> dynamicList;

  List<List<dynamic>> nestedList;

  List<List<List<dynamic>>> doublyNestedList;

  Map<String, Submodel> submodelMap;

  Map<String, dynamic> dynamicMap;

  DateTime dateTime;

  Blob blob;

  Function function;

  Model({
    this.selfRef,
    this.ignoredAttribute,
    this.number,
    this.submodel,
    this.submodelList,
    this.intList,
    this.dynamicList,
    this.nestedList,
    this.doublyNestedList,
    this.submodelMap,
    this.dynamicMap,
    this.dateTime,
    this.blob,
    this.function,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);

  Map<String, dynamic> toMap() => _$modelToMap(this);
}

/*
@JsonSerializable(nullable: false)
class Person {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  Person({this.firstName, this.lastName, this.dateOfBirth});
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
*/
