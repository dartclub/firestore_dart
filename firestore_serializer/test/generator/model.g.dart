// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// FirestoreSubdocumentGenerator
// **************************************************************************

_$submodelFromSnapshot(Map<String, dynamic> data) => Submodel();

Map<String, dynamic> _$submodelToMap(Submodel model) {
  Map<String, dynamic> data = {};
  return data;
}

// **************************************************************************
// FirestoreDocumentGenerator
// **************************************************************************

Model _$modelFromSnapshot(DocumentSnapshot snapshot) => Model(
      selfRef: snapshot.reference, // ignoring attribute 'int ignoredAttribute'
      number: snapshot.data["otherName"],
      submodel: Submodel.fromSnapshot(snapshot.data["submodel"]),
      // ignoring attribute 'List nestedList'
      dateTime: snapshot.data["dateTime"],
      blob: snapshot.data["blob"],
      // ignoring attribute 'Function function'
    );

Map<String, dynamic> _$modelToMap(Model model) {
  Map<String, dynamic> data = {};
  // ignoring attribute 'int ignoredAttribute'
  data["otherName"] = model.number;
  data["submodel"] = model.submodel.toMap();
  data["nestedList"] = model.nestedList;
  data["dateTime"] = model.dateTime;
  data["blob"] = model.blob;
  // ignoring attribute 'Function function'
  return data;
}
