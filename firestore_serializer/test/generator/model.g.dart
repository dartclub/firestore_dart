// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// FirestoreDocumentGenerator
// **************************************************************************

Submodel _$submodelFromSnapshot(DocumentSnapshot snapshot) => Submodel(
      // ignoring attribute 'int ignoredAttribute'
      number: snapshot.data["otherName"],
      submodel: _$submodelFromMap(snapshot.data["submodel"]),
      intList: List.castFrom(snapshot.data["intList"]).map((data) => data),
      submodelList: List.castFrom(snapshot.data["submodelList"])
          .map((data) => _$submodelFromMap(data)),
      submodelMap: snapshot.data["submodelMap"]
          .map((key, data) => MapEntry(key, _$submodelFromMap(data))),
      dateTime: snapshot.data["dateTime"],
      blob: snapshot.data["blob"],
      // ignoring attribute 'Function function'
    );

_$submodelFromMap(Map<String, dynamic> data) => data == null
    ? null
    : Submodel(
        // ignoring attribute 'int ignoredAttribute'
        number: data["otherName"],
        submodel: _$submodelFromMap(data["submodel"]),
        intList: List.castFrom(data["intList"]).map((data) => data),
        submodelList: List.castFrom(data["submodelList"])
            .map((data) => _$submodelFromMap(data)),
        submodelMap: data["submodelMap"]
            .map((key, data) => MapEntry(key, _$submodelFromMap(data))),
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
  data["submodelList"] = model.submodelList.map((data) => data.toMap());
  data["submodelMap"] =
      model.submodelMap.map((key, value) => MapEntry(key, value.toMap()));
  data["dateTime"] = model.dateTime;
  data["blob"] = model.blob;
  // ignoring attribute 'Function function'
  return data;
}

Model _$modelFromSnapshot(DocumentSnapshot snapshot) => Model(
      selfRef: snapshot.reference, // ignoring attribute 'int ignoredAttribute'
      number: snapshot.data["otherName"],
      intListDefaultValue: List.castFrom(snapshot.data["intListDefaultValue"])
          .map((data) => data),
      stringDefaultValue: snapshot.data["stringDefaultValue"],
      submodel: _$submodelFromMap(snapshot.data["submodel"]),
      intList: List.castFrom(snapshot.data["intList"]).map((data) => data),
      submodelList: List.castFrom(snapshot.data["submodelList"])
          .map((data) => _$submodelFromMap(data)),
      submodelMap: snapshot.data["submodelMap"]
          .map((key, data) => MapEntry(key, _$submodelFromMap(data))),
      dateTime: snapshot.data["dateTime"],
      blob: snapshot.data["blob"],
      // ignoring attribute 'Function function'
    );

_$modelFromMap(Map<String, dynamic> data) => data == null
    ? null
    : Model(
        // ignoring attribute 'int ignoredAttribute'
        number: data["otherName"],
        intListDefaultValue:
            List.castFrom(data["intListDefaultValue"]).map((data) => data),
        stringDefaultValue: data["stringDefaultValue"],
        submodel: _$submodelFromMap(data["submodel"]),
        intList: List.castFrom(data["intList"]).map((data) => data),
        submodelList: List.castFrom(data["submodelList"])
            .map((data) => _$submodelFromMap(data)),
        submodelMap: data["submodelMap"]
            .map((key, data) => MapEntry(key, _$submodelFromMap(data))),
        dateTime: data["dateTime"],
        blob: data["blob"],
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
  data["submodelList"] = model.submodelList.map((data) => data.toMap());
  data["submodelMap"] =
      model.submodelMap.map((key, value) => MapEntry(key, value.toMap()));
  data["dateTime"] = model.dateTime;
  data["blob"] = model.blob;
  // ignoring attribute 'Function function'
  return data;
}
