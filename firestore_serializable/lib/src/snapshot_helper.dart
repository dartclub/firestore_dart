import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
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
      DartType subType = getElementType(subEl);
      String subTypeLabel = subType.getDisplayString();

      if (inner.isEmpty) {
        var name = (data != 'data' ? data : inner);
        return isAllowedGeneric(subType) ? '$name.cast<$subTypeLabel>()' : name;
      } else {
        return 'List.castFrom($data ?? []).map<$subTypeLabel>((data) => $inner)?.toList()';
      }
    } else if (type.isDartCoreSet) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');
      DartType subType = getElementType(subEl);
      String subTypeLabel = subType.getDisplayString();

      if (inner.isEmpty) {
        var name = (data != 'data' ? data : inner);
        return isAllowedGeneric(subType) ? '$name.cast<$subTypeLabel>()' : name;
      } else {
        return 'Set.castFrom($data ?? {}).map<$subTypeLabel>((data) => $inner).toSet()';
      }
    } else if (type.isDartCoreMap) {
      Element subEl = getNestedElement(type);
      String inner = _deserializeNestedElement(subEl, annotation, 'data');

      return inner.isEmpty
          ? (data != 'data' ? data : inner)
          : '$data?.map((key, data) => MapEntry(key, $inner))';
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
      var parse = annotation.nullable ? 'tryParse' : 'parse';
      if (data == 'data') {
        return '';
      } else if (type.isDartCoreString) {
        return '$data is String ? $data : $data?.toString()';
      } else if (type.isDartCoreBool) {
        return '$data is bool ? $data : $data == "true"';
      } else if (type.isDartCoreDouble) {
        return '$data is double  ? $data : double.$parse($data.toString())';
      } else if (type.isDartCoreInt) {
        return '$data is int ? $data : int.$parse($data.toString())';
      } else if (type.isDartCoreNum) {
        return '$data is num ? $data : num.$parse($data.toString())';
      } else if (isType(type, 'DateTime')) {
        return '$data is DateTime ? $data : DateTime.$parse($data.toString())';
      } else {
        return data;
      }
    } else if (hasFirestoreDocumentAnnotation(type)) {
      return '${type.getDisplayString()}.fromMap(Map<String, dynamic>.from($data ?? {}))';
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

    String defaultValue = ',';
    if (annotation.defaultValue != null) {
      defaultValue = '?? ${annotation.defaultValue},';
    }
    var type = el.type;

    if (annotation.ignore || type.isDartCoreFunction || el.setter == null) {
      return '\t// ignoring attribute \'${el.type.getDisplayString()} $destName\'';
    } else {
      return '$destName: ' +
          _deserializeNestedElement(el, annotation, data) +
          defaultValue;
    }
  }

  _createNullabilityCheck(bool nullable, bool fromMap) {
    String data = fromMap ? 'data' : 'snapshot';
    if (nullable) {
      return 'if($data == null) return null;';
    } else {
      return 'assert($data != null);';
    }
  }

  _createFieldNullabilityCheck(FieldElement el, bool fromMap) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);
    String srcName = annotation.alias ?? el.name;
    String data = fromMap ? 'data["$srcName"]' : 'snapshot.data["$srcName"]';

    return annotation.nullable ? '' : 'assert($data != null);';
  }

  Iterable<String> createFromSnapshot(List<FieldElement> accessibleFields,
      bool hasSelfRef, bool nullable) sync* {
    StringBuffer buffer = StringBuffer();

    buffer
      ..writeln(
          '$className ${createSuffix(className)}FromSnapshot(DocumentSnapshot snapshot){')
      ..writeln(_createNullabilityCheck(nullable, false));

    for (var el in accessibleFields) {
      buffer.writeln(_createFieldNullabilityCheck(el, false));
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

  Iterable<String> createFromMap(List<FieldElement> accessibleFields,
      String className, bool nullable) sync* {
    StringBuffer buffer = StringBuffer();

    buffer
      ..writeln(
          '$className ${createSuffix(className)}FromMap(Map<String, dynamic> data){')
      ..writeln(_createNullabilityCheck(nullable, true));

    for (var el in accessibleFields) {
      buffer.writeln(_createFieldNullabilityCheck(el, true));
    }

    buffer.writeln('return $className(');

    for (var el in accessibleFields) {
      buffer.writeln(deserializeElement(el, true));
    }

    buffer.writeln(');}');

    yield buffer.toString();
  }
}
