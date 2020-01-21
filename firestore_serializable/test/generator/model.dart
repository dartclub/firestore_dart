import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

@FirestoreDocument(hasSelfRef: false)
class Submodel {
  @FirestoreAttribute()
  int bla;
  Submodel({this.bla});
}

@FirestoreDocument()
class Model {
  DocumentReference selfRef;

  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  @FirestoreAttribute(defaultValue: [1, 2, 3])
  List<int> intListDefaultValue;

  @FirestoreAttribute(defaultValue: 'FOO BAR "BAZ"')
  String stringDefaultValue;

  int _privateAttribute;

  List<int> intList;

  List<List<int>> nestedIntList;

  List<List<List<int>>> doublyNestedList;

  List<dynamic> dynamicList;

  DateTime dateTime;

  Blob blob;

  dynamic bla;

  Function function;

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
