import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

class Timestamp {}

@FirestoreDocument(nullable: true)
class Model {
  DocumentReference selfRef;
  int simple;
  List<int> list;
  List<List<int>> nestedList;
  Map<String, String> map;
  List<Timestamp> timestampList;

  Model({
    this.selfRef,
    this.simple,
    this.list,
    this.nestedList,
    this.map,
    this.timestampList,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);
  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);
  Map<String, dynamic> toMap() => _$modelToMap(this);
}
