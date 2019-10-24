import 'package:firestore_api/firestore_api.dart';

part 'model.g.dart';

/*@FirestoreDocument(hasSelfRef: false)
class Submodel {
  factory Submodel.fromMap(Map<String, dynamic> data) =>
      _$submodelFromMap(data);
  Map<String, dynamic> toMap() => _$submodelToMap(this);

  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  int _privateAttribute;

  Submodel submodel;

  List<int> intList;

  List<Submodel> submodelList;

  //List<List<int>> nestedIntList;

  //List<dynamic> dynamicList;

  //List<List<dynamic>> nestedList;

  List<List<Submodel>> nestedSubmodelList;

  //ist<List<List<dynamic>>> doublyNestedList;

  Map<String, Submodel> submodelMap;

  //Map<String, dynamic> dynamicMap;

  DateTime dateTime;

  Blob blob;

  Function function;

  Submodel({
    this.ignoredAttribute,
    this.number,
    this.submodel,
    this.submodelList,
    this.submodelMap,
    this.intList,
    //this.nestedIntList,
    //this.dynamicList,
    //this.nestedList,
    //this.doublyNestedList,
    //this.dynamicMap
    this.nestedSubmodelList,
    this.dateTime,
    this.blob,
    this.function,
  });

  Submodel.defaults();
}
*/
@FirestoreDocument()
class Model {
  DocumentReference selfRef;

  @FirestoreAttribute(ignore: true)
  int ignoredAttribute;

  @FirestoreAttribute(alias: 'otherName')
  int number;

  //@FirestoreAttribute(defaultValue: [1, 2, 3])
  //List<int> intListDefaultValue;

  @FirestoreAttribute(defaultValue: 'FOO BAR "BAZ"')
  String stringDefaultValue;

  int _privateAttribute;

  //Submodel submodel;

  //List<int> intList;

  //List<Submodel> submodelList;

  List<List<int>> nestedIntList;

  //List<dynamic> dynamicList;

  //List<List<dynamic>> nestedList;

  //List<List<Submodel>> nestedSubmodelList;

  //ist<List<List<dynamic>>> doublyNestedList;

  //Map<String, Submodel> submodelMap;

  //Map<String, dynamic> dynamicMap;

  DateTime dateTime;

  Blob blob;

  Function function;

  Model({
    this.selfRef,
    this.ignoredAttribute,
    this.number,
    //this.submodel,
    //this.submodelList,
    //this.submodelMap,
    //this.intList,
    //this.intListDefaultValue,
    this.stringDefaultValue,
    this.nestedIntList,
    //this.dynamicList,
    //this.nestedList,
    //this.doublyNestedList,
    //this.dynamicMap
    this.dateTime,
    this.blob,
    this.function,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);

  factory Model.fromMap(Map<String, dynamic> data) =>
      _$modelFromMap(data);

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
