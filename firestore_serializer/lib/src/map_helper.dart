import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializer/src/annotation_helper.dart';
import 'package:firestore_serializer/src/helper.dart';

class MapHelper with Helper {
  final bool subdocument;

  MapHelper(this.subdocument);

// TODO return type information + converter functions
  String _serializeNestedElement(Element el, AnnotationHelper annotation) {
    ClassElement subEl = getNestedElement(el) as ClassElement;

    if (isNestedElement(subEl)) {
      // TODO
      String pre = '.map(()=>';
      String post = ')';
      _serializeNestedElement(subEl, annotation); // TODO
    } else {
      // TODO if (isSimpleElement / firestoreDocument etc.)
      return '';
    }
    return '';
  }

  String _serializeSimpleElement(FieldElement el, AnnotationHelper annotation) {
    if (isSimpleElement(el)) {
      return '';
    } else if (isFirestoreElement(el.type)) {
      return '.toMap()';
    } else {
      return '';
    }
  }

  String serializeElement(FieldElement el) {
    AnnotationHelper annotation = AnnotationHelper(el);

    String srcName = el.name;
    String destName = annotation.alias ?? el.name;
    String pre = 'data["$destName"] = model.$srcName';
    String serialized = '';
    String post = ';\n';

    if (annotation.ignore) {
      return '\t// ignoring attribute \'${el.type.name} $srcName\'\n';
    } else {
      /*if (isFirestoreElementList(el)) {
        String type = getTypeOfGenericList(el);
        line += '.map(($type el) => el.toMap()).toList()';
      } else if (isSimpleElementList(el)) {
        line += '.toList()';
      } else if (isFirestoreElementMap(el)) {
        String type = getTypeOfGenericMap(el);
        line +=
            '.map<String,Map<String,dynamic>>((String k, $type v) => MapEntry(k, v.toMap()))';
      } else if (isNestedElement(el)) {
        line += _serializeNestedElement(el);
      } 
      else if(isDynamicMap(el){
        // line += '';
      }
      else {
        return '\t// ignoring attribute \'${el.type.name} $srcName\'\n';
      }*/
      if (isNestedElement(el)) {
        serialized = _serializeNestedElement(el, annotation);
      } else if (isSimpleElement(el) || isFirestoreElement(el.type)) {
        serialized = _serializeSimpleElement(el, annotation);
      }
      return '$pre$serialized$post';
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
