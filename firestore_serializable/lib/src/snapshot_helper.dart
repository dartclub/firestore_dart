import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

class SnapshotHelper {
  SnapshotHelper();

  String _deserializeNestedElement(
      Element el, FieldAnnotationHelper annotation, String data) {
    var type = getElementType(el);

    if (type.isDartCoreList) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');

      return inner.isEmpty ? '' : 'List.castFrom($data).map((data) => $inner)';
    } else if (type.isDartCoreSet) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');

      return inner.isEmpty ? '' : 'Set.castFrom($data).map((data) => $inner)';
    } else if (type.isDartCoreMap) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');

      return inner.isEmpty
          ? ''
          : '$data.map((key, data) => MapEntry(key, $inner))';
    } else {
      return _deserializeSimpleElement(el, annotation, data);
    }
  }

  String _deserializeSimpleElement(
    Element el,
    FieldAnnotationHelper annotation,
    String data,
  ) {
    var type = getElementType(el);
    if (isFirestoreDataType(type)) {
      return "$data";
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return 'fromMap($data)';
    } else {
      throw Exception(
          'unsupported type ${type?.getDisplayString()} ${el.runtimeType} during deserialize');
    }
  }

  String deserializeElement(FieldElement el, bool fromMap) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);

    String srcName = annotation.alias ?? el.name;
    String destName = el.name;
    String data = fromMap ? 'data["$srcName"]' : 'snapshot.data["$srcName"]';

    var type = el.type;

    if (annotation.ignore || type.isDartCoreFunction) {
      return '\t// ignoring attribute \'${el.type.getDisplayString()} $destName\'';
    } else {
      return '$destName: ' +
          _deserializeNestedElement(el, annotation, data) +
          ',';
    }
  }

  Iterable<String> createFromSnapshot(List<FieldElement> accessibleFields,
      String className, bool hasSelfRef) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        '$className ${createSuffix(className)}FromSnapshot(DocumentSnapshot snapshot)=>$className(');
    if (hasSelfRef) {
      buffer.writeln('selfRef: snapshot.reference');
      if (accessibleFields.isNotEmpty) {
        buffer.write(",");
      }
    }
    for (var el in accessibleFields) {
      buffer.writeln(deserializeElement(el, false));
    }
    buffer.writeln(');');
    yield buffer.toString();
  }

  Iterable<String> createFromMap(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        '$className ${createSuffix(className)}FromMap(Map<String, dynamic> data)=> data == null ? null : $className(');
    for (var el in accessibleFields) {
      buffer.writeln(deserializeElement(el, true));
    }
    buffer.writeln(');');
    yield buffer.toString();
  }
}
