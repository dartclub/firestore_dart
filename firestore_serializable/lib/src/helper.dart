import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

const SUFFIX = '_\$';
String createSuffix(String className) =>
    '$SUFFIX${className[0].toLowerCase()}${className.substring(1)}';

String getName(Element el) {
  String name;
  if (el.kind.displayName == 'constructor') {
    if (el.enclosingElement == null) {
      name = '<unknown class>';
    } else {
      name = el.enclosingElement.displayName;
    }
    String constructorName = el.displayName;
    if (constructorName != null && constructorName.isNotEmpty) {
      name = '$name.$constructorName';
    }
  } else {
    name = el.displayName;
    if (name == null || name.isEmpty) {
      name = '<unknown name>';
    }
  }

  return name;
}

bool isType(DartType t, String n) => t.getDisplayString() == n;

bool isFirestoreDataType(DartType type) {
  return type != null &&
      (type.isDartCoreNull ||
          type.isDartCoreBool ||
          type.isDartCoreDouble ||
          type.isDynamic ||
          type.isDartCoreInt ||
          type.isDartCoreNum ||
          type.isDartCoreString ||
          isType(type, 'DateTime') ||
          isType(type, 'DocumentReference') ||
          isType(type, 'CollectionReference') ||
          isType(type, 'GeoPoint') ||
          isType(type, 'Timestamp') ||
          isType(type, 'Blob'));
}

bool isAllowedGeneric(DartType type) {
  return type != null &&
      (type.isDartCoreBool ||
          type.isDartCoreDouble ||
          type.isDartCoreInt ||
          type.isDartCoreNum ||
          type.isDartCoreString ||
          isType(type, 'DateTime') ||
          isType(type, 'DocumentReference') ||
          isType(type, 'CollectionReference') ||
          isType(type, 'GeoPoint') ||
          isType(type, 'Timestamp') ||
          isType(type, 'Blob'));
}

bool hasFirestoreDocumentAnnotation(DartType type) {
  if (type == null) return false;
  var meta = type.element.metadata;
  if (meta.isNotEmpty) {
    for (var m in meta) {
      if (getName(m.element) == 'FirestoreDocument') {
        return true;
      }
    }
  }
  return false;
}

DartType getElementType(Element el) {
  if (el is FieldElement) {
    return el.type;
  } else if (el is ClassElement) {
    return el.thisType;
  } else if (el is DynamicElementImpl) {
    return el.type;
  } else if (el is TypeParameterElementImpl) {
    return el.defaultType;
  } else {
    throw Exception(
        'Type Error! ${el.getDisplayString(withNullability: false)} ${el.runtimeType}');
  }
}

Element getNestedElement(DartType type) {
  if (type is TypeParameterType && type.getDisplayString() == 'E') {
    return DynamicElementImpl();
  } else if (type is InterfaceType) {
    return type.typeArguments.first.element;
  } else {
    return null;
  }
}
