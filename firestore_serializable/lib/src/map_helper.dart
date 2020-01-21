import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

class MapHelper {
  MapHelper();

  String _serializeNestedElement(Element el, FieldAnnotationHelper annotation) {
    var type = getElementType(el);

    if (type.isDartCoreList) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation);
      return inner.isEmpty ? '' : '.map((data)=>data$inner).toList()';
    } else if (type.isDartCoreSet) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation);
      return inner.isEmpty ? '' : '.map((data)=>data$inner).toSet()';
    } else if (type.isDartCoreMap) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation);
      return inner.isEmpty
          ? ''
          : '.map((key, value) => MapEntry(key, value$inner))';
    } else {
      return _serializeSimpleElement(el, annotation);
    }
  }

  String _serializeSimpleElement(Element el, FieldAnnotationHelper annotation) {
    var type = getElementType(el);
    if (isFirestoreDataType(type)) {
      return '';
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return '.toMap()';
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
      return '"$destName": model.$srcName' +
          _serializeNestedElement(el, annotation) +
          '$defaultValue,';
    }
  }

  Iterable<String> createToMap(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        'Map<String, dynamic> ${createSuffix(className)}ToMap($className model)');
    buffer.writeln('=> <String, dynamic>{');
    for (var el in accessibleFields) {
      buffer.writeln(serializeElement(el));
    }
    buffer.writeln('};');
    yield buffer.toString();
  }
}
