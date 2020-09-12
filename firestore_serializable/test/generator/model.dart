import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

class Timestamp {
  final _stamp;
  Timestamp.fromMillisecondsSinceEpoch(this._stamp);
  Timestamp.fromDate(this._stamp);
}

@FirestoreDocument(hasSelfRef: false)
class Submodel {
  @FirestoreAttribute()
  int attribute;
  Submodel({this.attribute});
  factory Submodel.fromMap(Map<String, dynamic> data) =>
      _$submodelFromMap(data);
  Map<String, dynamic> toMap() => _$submodelToMap(this);
}

@FirestoreDocument(nullable: true)
class Model {
  DocumentReference selfRef;

  Model({this.selfRef});

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);
  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);
  Map<String, dynamic> toMap() => _$modelToMap(this);
}
