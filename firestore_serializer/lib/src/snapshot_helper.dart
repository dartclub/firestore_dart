import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializer/src/annotation_helper.dart';
import 'package:firestore_serializer/src/helper.dart';

class SnapshotHelper with Helper {
  final bool subdocument;

  SnapshotHelper(this.subdocument);

  String _serializeNestedElement(
      Element el, AnnotationHelper annotation, String data) {
    var type = getTypeOfElement(el);

    if (isNestedElement(type)) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation, 'data');
      if (inner.isEmpty) {
        return '';
      } else {
        if (isListElement(type)) {
          return '$data.map((data) => $inner)';
        } else if (isMapElement(type)) {
          return '$data.map((key, data) => MapEntry(key, $inner))';
        } else {
          throw Exception('unsupported type ${type?.name}');
        }
      }
    } else {
      return _serializeSimpleElement(el, annotation, data);
    }
  }

  String _serializeSimpleElement(
      Element el, AnnotationHelper annotation, String data) {
    var type = getTypeOfElement(el);
    if (isSimpleElement(type)) {
      return data;
    } else if (isFirestoreElement(type)) {
      return '$type.fromSnapshot($data)';
    } else {
      throw Exception('unsupported type ${type?.name}');
    }
  }

  String serializeElement(FieldElement el) {
    AnnotationHelper annotation = AnnotationHelper(el);

    String srcName = annotation.alias ?? el.name;
    String destName = el.name;
    String data =
        subdocument ? 'data["$srcName"]' : 'snapshot.data["$srcName"]';

    var type = el.type;

    if (annotation.ignore || isFunction(type)) {
      return '\t// ignoring attribute \'${el.type.name} $destName\'';
    } else {
      return '$destName: ' +
          _serializeNestedElement(el, annotation, data) +
          ',';
    }
  }

  Iterable<String> createFromSnapshot(
      List<FieldElement> accessibleFields, String className) sync* {
    if (subdocument) {
      yield '${createSuffix(className)}FromSnapshot(Map<String, dynamic> data)=>$className(';
    } else {
      yield '$className ${createSuffix(className)}FromSnapshot(DocumentSnapshot snapshot)=>$className(';
      yield 'selfRef: snapshot.reference,';
    }
    for (var el in accessibleFields) {
      yield serializeElement(el);
    }
    yield ');';
  }
}
