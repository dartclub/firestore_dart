// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// FirestoreSubdocumentGenerator
// **************************************************************************

_$barFromSnapshot(Map<String, dynamic> data) => Bar();

Map<String, dynamic> _$barToMap(Bar model) {
  Map<String, dynamic> data = {};
  return data;
}

// **************************************************************************
// FirestoreDocumentGenerator
// **************************************************************************

Foo _$fooFromSnapshot(DocumentSnapshot snapshot) => Foo(
      selfRef: snapshot.reference, // ignoring attribute 'int foo'
      bar: Bar.fromSnapshot(snapshot.data["bar"]),
      bars: snapshot.data["bars"]
          .map((Map<String, dynamic> el) => Bar.fromSnapshot(el))
          .toList(),
      bla: snapshot.data["bla"].toList(),
      map: snapshot.data["map"].map<String, Bar>(
          (String k, Map<String, dynamic> v) =>
              MapEntry(k, Bar.fromSnapshot(v))),
      map2: snapshot.data["map2"],
      dateTime: snapshot.data["dateTime"],
      // ignoring attribute 'Function f'
    );

Map<String, dynamic> _$fooToMap(Foo model) {
  Map<String, dynamic> data = {};
  // ignoring attribute 'int foo'
  data["bar"] = model.bar.toMap();
  data["bars"] = model.bars.map((Bar el) => el.toMap()).toList();
  data["bla"] = model.bla.map((int el) => el).toList();
  data["map"] = model.map.map<String, Map<String, dynamic>>(
      (String k, Bar v) => MapEntry(k, v.toMap()));
  data["map2"] = model.map2;
  data["dateTime"] = model.dateTime;
  // ignoring attribute 'Function f'
  return data;
}
