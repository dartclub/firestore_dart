import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializer/src/annotation_helper.dart';
import 'package:firestore_serializer/src/helper.dart';

class SnapshotHelper with Helper {
  final bool subdocument;

  SnapshotHelper(this.subdocument);

  String serializeElement(FieldElement el) {

    AnnotationHelper annotation = AnnotationHelper(el);

    String srcName = annotation.alias ?? el.name;
    String destName = el.name;
    String data = subdocument ? 'data["$srcName"]' : 'snapshot.data["$srcName"]';
    String line = '$destName: ';
    
    if (annotation.ignore) {
      return '\t// ignoring attribute \'${el.type.name} $destName\'\n';
    } else {
      if (isFirestoreElement(el.type)) {
        String type = getTypeOfFirestoreElement(el.type);
        line += '$type.fromSnapshot($data)';
      } else if (isSimpleElement(el) || isDynamicElementMap(el)) {
        line += '$data';
      } else if (isFirestoreElementList(el)) {
        String type = getTypeOfGenericList(el);
        line +=
            '$data.map((Map<String, dynamic> el) => $type.fromSnapshot(el)).toList()';
      } else if (isSimpleElementList(el)) {
        line += '$data.toList()';
      } else if (isFirestoreElementMap(el)) {
        String type = getTypeOfGenericMap(el);
        line +=
            '$data.map<String,$type>((String k, Map<String, dynamic> v) => MapEntry(k, $type.fromSnapshot(v)))';
      } 
      // TODO implement nestedElement
      else {
        return '\t// ignoring attribute \'${el.type.name} $destName\'\n';
      }
    }
    return '$line,\n';
  }

  Iterable<String> createFromSnapshot(
      List<FieldElement> accessibleFields, String className) sync* {
    final buffer = StringBuffer();

    if (subdocument) {
      buffer.write(
          '${createSuffix(className)}FromSnapshot(Map<String, dynamic> data)=>$className(');
    } else {
      buffer.write(
          '$className ${createSuffix(className)}FromSnapshot(DocumentSnapshot snapshot)=>$className(');
      buffer.write('selfRef: snapshot.reference,');
    }
    for (var el in accessibleFields) {
      buffer.write(serializeElement(el));
    }
    buffer.write(');');
    yield buffer.toString();

    yield buffer.toString();
  }
}
