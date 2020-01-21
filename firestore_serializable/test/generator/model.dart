import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

@FirestoreDocument(hasSelfRef: false)
class Submodel {
  @FirestoreAttribute()
  int bla;
  Submodel({this.bla});
  factory Submodel.fromMap(Map<String, dynamic> data) =>
      _$submodelFromMap(data);
}

@FirestoreDocument()
class Model {
  DocumentReference selfRef;

/* ignored attributes */
  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  Function function;

  int _privateAttribute;


  @FirestoreAttribute(alias: 'otherName')
  int number;

  @FirestoreAttribute(defaultValue: [1, 2, 3])
  List<int> intListDefaultValue;

  @FirestoreAttribute(defaultValue: 'FOO BAR "BAZ"')
  String stringDefaultValue;

  List<int> intList;

  List<List<int>> nestedIntList;

  List<List<List<int>>> doublyNestedList;

  List<dynamic> dynamicList;

  DateTime dateTime;

  Blob blob;

  dynamic bla;

  Model({
    this.selfRef,
    this.ignoredAttribute,
    this.number,
    this.intListDefaultValue,
    this.doublyNestedList,
    this.stringDefaultValue,
    this.intList,
    this.nestedIntList,
    this.dynamicList,
    this.dateTime,
    this.blob,
    this.function,
    this.bla,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);
  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);
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
