// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// FirestoreSubdocumentGenerator
// **************************************************************************

_$submodelFromSnapshot(Map<String, dynamic> data) => Submodel(
      // ignoring attribute 'int ignoredAttribute'
      number: data["otherName"],
      submodel: Submodel.fromSnapshot(data["submodel"]),
      intList: data["intList"].map((data) => data),
      submodelList:
          data["submodelList"].map((data) => Submodel.fromSnapshot(data)),
      submodelMap: data["submodelMap"]
          .map((key, data) => MapEntry(key, Submodel.fromSnapshot(data))),
      dateTime: data["dateTime"],
      blob: data["blob"],
      // ignoring attribute 'Function function'
    );

Map<String, dynamic> _$submodelToMap(Submodel model) {
  Map<String, dynamic> data = {};
  // ignoring attribute 'int ignoredAttribute'
  data["otherName"] = model.number;
  data["submodel"] = model.submodel.toMap();
  data["intList"] = model.intList;
  data["submodelList"] =
      model.submodelList /*List<Submodel>*/ .map((data) => data.toMap());
  data["submodelMap"] = model.submodelMap /*Map<String, Submodel>*/ .map(
      (key, value) => MapEntry(key, value.toMap()));
  data["dateTime"] = model.dateTime;
  data["blob"] = model.blob;
  // ignoring attribute 'Function function'
  return data;
}

// **************************************************************************
// FirestoreDocumentGenerator
// **************************************************************************

Model _$modelFromSnapshot(DocumentSnapshot snapshot) => Model(
      selfRef: snapshot.reference, // ignoring attribute 'int ignoredAttribute'
      number: snapshot.data["otherName"],
      intListDefaultValue:
          snapshot.data["intListDefaultValue"].map((data) => data),
      stringDefaultValue: snapshot.data["stringDefaultValue"],
      submodel: Submodel.fromSnapshot(snapshot.data["submodel"]),
      intList: snapshot.data["intList"].map((data) => data),
      submodelList: snapshot.data["submodelList"]
          .map((data) => Submodel.fromSnapshot(data)),
      submodelMap: snapshot.data["submodelMap"]
          .map((key, data) => MapEntry(key, Submodel.fromSnapshot(data))),
      dateTime: snapshot.data["dateTime"],
      blob: snapshot.data["blob"],
      // ignoring attribute 'Function function'
    );

Map<String, dynamic> _$modelToMap(Model model) {
  Map<String, dynamic> data = {};
  // ignoring attribute 'int ignoredAttribute'
  data["otherName"] = model.number;
  data["intListDefaultValue"] = model.intListDefaultValue ?? [1, 2, 3];
  data["stringDefaultValue"] = model.stringDefaultValue ?? 'FOO BAR "BAZ"';
  data["submodel"] = model.submodel.toMap();
  data["intList"] = model.intList;
  data["submodelList"] =
      model.submodelList /*List<Submodel>*/ .map((data) => data.toMap());
  data["submodelMap"] = model.submodelMap /*Map<String, Submodel>*/ .map(
      (key, value) => MapEntry(key, value.toMap()));
  data["dateTime"] = model.dateTime;
  data["blob"] = model.blob;
  // ignoring attribute 'Function function'
  return data;
}
