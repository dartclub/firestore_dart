import 'package:firestore_annotations/firestore_annotations.dart';
import 'package:firestore_api/firestore_api.dart';
part 'model.g.dart';

@FirestoreDocument(nullable: true)
class Model {
  DocumentReference selfRef;

  Model({
    this.selfRef,
  });

  factory Model.fromSnapshot(DocumentSnapshot snapshot) =>
      _$modelFromSnapshot(snapshot);
  factory Model.fromMap(Map<String, dynamic> data) => _$modelFromMap(data);
  Map<String, dynamic> toMap() => _$modelToMap(this);
}
