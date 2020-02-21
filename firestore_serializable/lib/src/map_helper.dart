import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

class MapHelper {
  final String className;
  MapHelper(this.className);

  String _serializeNestedElement(
      Element el, FieldAnnotationHelper annotation, String data) {
    var type = getElementType(el);

    if (type.isDartCoreList) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation, 'data');
      return data + (inner.isEmpty ? '' : '.map((data)=>$inner).toList()');
    } else if (type.isDartCoreSet) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation, 'value');
      return data + (inner.isEmpty ? '' : '.map((data)=>$inner).toSet()');
    } else if (type.isDartCoreMap) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation, 'data');
      return data +
          (inner.isEmpty ? '' : '.map((key, data) => MapEntry(key, $inner))');
    } else {
      return _serializeSimpleElement(el, annotation, data);
    }
  }

  String _serializeSimpleElement(
      Element el, FieldAnnotationHelper annotation, String data) {
    var type = getElementType(el);

    if (isFirestoreDataType(type)) {
      if (isType(type, 'DateTime')) {
        return '$data != null ? Timestamp.fromDate($data) : null';
      } else if (data == 'data') {
        return '';
      } else {
        return data;
      }
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return '$data.toMap()';
    } else {
      throw Exception(
          'unsupported type ${type?.getDisplayString()} ${el.runtimeType} during serialize');
    }
  }

  String serializeElement(FieldElement el) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);

    String srcName = el.name;
    String destName = annotation.alias ?? el.name;

    String defaultValue = '';
    if (annotation.defaultValue != null) {
      defaultValue = ' ?? ${annotation.defaultValue}';
    }

    var type = el.type;

    if (annotation.ignore || type.isDartCoreFunction) {
      return '\t// ignoring attribute \'${type.getDisplayString()} $srcName\'';
    } else {
      return '"$destName": ' +
          _serializeNestedElement(el, annotation, 'model.$srcName') +
          '$defaultValue,';
    }
  }

  _createNullabilityCheck(FieldElement el) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);
    return annotation.nullable ? '' : 'assert(model.${el.name} != null);';
  }

  Iterable<String> createToMap(List<FieldElement> accessibleFields) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        'Map<String, dynamic> ${createSuffix(className)}ToMap($className model){');
    for (var el in accessibleFields) {
      buffer.writeln(_createNullabilityCheck(el));
    }
    buffer.writeln('return <String, dynamic>{');
    for (var el in accessibleFields) {
      buffer.writeln(serializeElement(el));
    }
    buffer.writeln('};}');
    yield buffer.toString();
  }
}
