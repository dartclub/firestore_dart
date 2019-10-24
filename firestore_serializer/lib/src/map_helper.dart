import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializer/src/annotation_helper.dart';
import 'package:firestore_serializer/src/helper.dart';

class MapHelper  {
  MapHelper();

  String _serializeNestedElement(Element el, FieldAnnotationHelper annotation) {
    var type = getTypeOfElement(el);

    if (isNestedElement(type)) {
      Element subEl = getNestedElement(type);
      String inner = _serializeNestedElement(subEl, annotation);
      if (inner.isEmpty) {
        return '';
      } else {
        if (isListElement(type)) {
          return '.map((data)=>data$inner)';
        } else if (isMapElement(type)) {
          return '.map((key, value) => MapEntry(key, value$inner))';
        } else {
          throw Exception('unsupported type ${type?.name} during serialize');
        }
      }
    } else {
      return _serializeSimpleElement(el, annotation);
    }
  }

  String _serializeSimpleElement(Element el, FieldAnnotationHelper annotation) {
    var type = getTypeOfElement(el);
    if (isFirestoreDataType(type)) {
      return '';
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return '.toMap()';
    } else {
      throw Exception('unsupported type ${type?.name}');
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

    if (annotation.ignore || isFunction(type)) {
      return '\t// ignoring attribute \'${type.name} $srcName\'';
    } else {
      return 'data["$destName"] = model.$srcName' +
          _serializeNestedElement(el, annotation) +
          '$defaultValue;';
    }
  }

  Iterable<String> createToMap(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        'Map<String, dynamic> ${createSuffix(className)}ToMap($className model)');
    buffer.writeln('{\nMap<String, dynamic> data = {};');
    for (var el in accessibleFields) {
      buffer.writeln(serializeElement(el));
    }
    buffer.writeln('return data;}');
    yield buffer.toString();
  }
}
