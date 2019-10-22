import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializer/src/annotation_helper.dart';
import 'package:firestore_serializer/src/helper.dart';

class MapHelper with Helper {
  final bool subdocument;

  MapHelper(this.subdocument);

  String _serializeNestedElement(Element el, AnnotationHelper annotation) {
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
          throw Exception('unsupported type ${type?.name}');
        }
      }
    } else {
      return _serializeSimpleElement(el, annotation);
    }
  }

  String _serializeSimpleElement(Element el, AnnotationHelper annotation) {
    var type = getTypeOfElement(el);
    if (isSimpleElement(type)) {
      return '';
    } else if (isFirestoreElement(type)) {
      return '.toMap()';
    } else {
      throw Exception('unsupported type ${type?.name}');
    }
  }

  String serializeElement(FieldElement el) {
    AnnotationHelper annotation = AnnotationHelper(el);

    String srcName = el.name;
    String destName = annotation.alias ?? el.name;

    var type = el.type;

    if (annotation.ignore || isFunction(type)) {
      return '\t// ignoring attribute \'${type.name} $srcName\'\n';
    } else {
      return 'data["$destName"] = model.$srcName' +
          _serializeNestedElement(el, annotation) +
          ';\n';
    }
  }

  Iterable<String> createToMap(
      List<FieldElement> accessibleFields, String className) sync* {
    final buffer = StringBuffer();
    buffer.write(
        'Map<String, dynamic> ${createSuffix(className)}ToMap($className model)');
    buffer.write('{\nMap<String, dynamic> data = {};\n');
    for (var el in accessibleFields) {
      buffer.write(serializeElement(el));
    }
    buffer.write('return data;\n}');

    yield buffer.toString();
  }
}
