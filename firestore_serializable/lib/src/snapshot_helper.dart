import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

class SnapshotHelper {
  final String className;
  SnapshotHelper(this.className);

  String _deserializeNestedElement(
      Element el, FieldAnnotationHelper annotation, String data) {
    var type = getElementType(el);

    if (type.isDartCoreList) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');
      String subTypeLabel = getElementType(subEl).getDisplayString();

      return inner.isEmpty
          ? (data != 'data' ? data : inner)
          : 'List.castFrom($data).map<$subTypeLabel>((data) => $inner).toList()';
    } else if (type.isDartCoreSet) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');
      String subTypeLabel = getElementType(subEl).getDisplayString();

      return inner.isEmpty
          ? (data != 'data' ? data : inner)
          : 'Set.castFrom($data).map<$subTypeLabel>((data) => $inner).toSet()';
    } else if (type.isDartCoreMap) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');

      return inner.isEmpty
          ? (data != 'data' ? data : inner)
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
      if (data == 'data') {
        return '';
      } else if (type.isDartCoreString) {
        return '$data is String ? $data : $data.toString()';
      } else if (type.isDartCoreBool) {
        return '$data is bool ? $data : $data == "true"';
      } else if (type.isDartCoreDouble) {
        return '$data is double  ? $data : double.parse($data)';
      } else if (type.isDartCoreInt) {
        return '$data is int ? $data : int.parse($data)';
      } else if (type.isDartCoreNum) {
        return '$data is num ? $data : num.parse($data)';
      } else if (isType(type, 'DateTime')) {
        return '$data is DateTime ? $data : ($data is Timestamp ? $data.toDate() : DateTime.tryParse($data.toString()))';
      } else if (isType(type, 'Timestamp')) {
        return '$data is Timestamp ? $data : ($data is DateTime ? Timestamp.fromDate($data) : null)';
      } else {
        return data;
      }
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return '${type.getDisplayString()}.fromMap(Map<String, dynamic>.from($data))';
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
      return '$destName: $data != null ?' +
          _deserializeNestedElement(el, annotation, data) +
          ': null,';
    }
  }

  _createNullabilityCheck(FieldElement el, bool fromMap) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);
    String srcName = annotation.alias ?? el.name;
    String data = fromMap ? 'data["$srcName"]' : 'snapshot.data["$srcName"]';

    return annotation.nullable ? '' : 'assert($data != null);';
  }

  Iterable<String> createFromSnapshot(
      List<FieldElement> accessibleFields, bool hasSelfRef) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        '$className ${createSuffix(className)}FromSnapshot(DocumentSnapshot snapshot){');
    for (var el in accessibleFields) {
      buffer.writeln(_createNullabilityCheck(el, false));
    }
    buffer.writeln('return $className(');
    if (hasSelfRef) {
      buffer.writeln('selfRef: snapshot.reference');
      if (accessibleFields.isNotEmpty) {
        buffer.write(",");
      }
    }
    for (var el in accessibleFields) {
      buffer.writeln(deserializeElement(el, false));
    }
    buffer.writeln(');}');
    yield buffer.toString();
  }

  Iterable<String> createFromMap(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        '$className ${createSuffix(className)}FromMap(Map<String, dynamic> data){');
    for (var el in accessibleFields) {
      buffer.writeln(_createNullabilityCheck(el, true));
    }
    buffer.writeln('return $className(');
    for (var el in accessibleFields) {
      buffer.writeln(deserializeElement(el, true));
    }
    buffer.writeln(');}');
    yield buffer.toString();
  }
}
