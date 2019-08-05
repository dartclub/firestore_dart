import 'package:firestore_api/firestore_api.dart';

part 'main.g.dart';

@FirestoreSubdocument()
class Bar {
  factory Bar.fromSnapshot(Map<String, dynamic> data) =>
      _$barFromSnapshot(data);
  Map<String, dynamic> toMap() => _$barToMap(this);
  Bar();
}

@FirestoreDocument()
class Foo {
  DocumentReference selfRef;

  @FirestoreAttribute(ignore: true)
  int foo;

  // unter Bar nachschauen, ob Bar FirestoreDocument Annotation hat (@FirestoreSubdocument())
  Bar bar;

  List<Bar> bars;

  List<int> bla;

  Map<String, Bar> map;

  Map<String, dynamic> map2;

  DateTime dateTime;

  Function f;

  Foo({
    this.selfRef,
    this.foo,
    this.bar,
    this.bars,
    this.bla,
    this.map,
    this.map2,
    this.dateTime,
    this.f,
  });

  factory Foo.fromSnapshot(DocumentSnapshot snapshot) =>
      _$fooFromSnapshot(snapshot);

  Map<String, dynamic> toMap() => _$fooToMap(this);
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
