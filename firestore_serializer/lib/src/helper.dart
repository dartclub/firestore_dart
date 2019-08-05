import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

mixin Helper {
  String createSuffix(String className) =>
      '_\$${className[0].toLowerCase()}${className.substring(1)}';

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

  bool isUnsupportedElement(FieldElement el) {
    if (el.type != null) {
      DartType t = el.type;
      return t.isDartAsyncFuture ||
          t.isDartAsyncFutureOr ||
          t.isDartCoreInt ||
          t.isDartCoreNull;
    } else {
      return false;
    }
  }

  bool _isDateTime(DartType type) => type.name == 'DateTime';

  bool _isString(DartType type) => type.name == 'String';

  bool _isDocumentRef(DartType type) => type.name == 'DocumentReference';
  bool _isCollectionRef(DartType type) => type.name == 'CollectionReference';
  bool _isGeoPoint(DartType type) => type.name == 'GeoPoint';
  bool _isBlob(DartType type) => type.name == 'Blob';

  bool isSimpleElement(FieldElement el) {
    DartType t = el.type;
    return t.isDartCoreBool ||
        t.isDartCoreDouble ||
        t.isDartCoreInt ||
        t.isDartCoreNull ||
        t.isDynamic ||
        _isString(t) ||
        _isDateTime(t) ||
        _isDocumentRef(t) ||
        _isCollectionRef(t) ||
        _isGeoPoint(t) ||
        _isBlob(t);
  }

  bool isFirestoreElement(DartType type) {
    var meta = type.element.metadata;
    if (meta.length > 0) {
      for (var m in meta) {
        if (getName(m.element) == 'FirestoreSubdocument') {
          return true;
        }
      }
    }
    return false;
  }

  String getTypeOfFirestoreElement(DartType type) => type.element.displayName;

  _containsFirestoreElement(List<DartType> types) =>
      types.where((DartType type) => isFirestoreElement(type)).length > 0;

  bool isFirestoreElementList(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'List') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      return types.length == 1 && _containsFirestoreElement(types);
    }
    return false;
  }

  bool _containsSimpleElement(List<DartType> types) =>
      types
          .where((DartType t) =>
              t.isDartCoreBool ||
              t.isDartCoreDouble ||
              t.isDartCoreInt ||
              t.isDynamic ||
              _isString(t) ||
              _isDateTime(t))
          .length >
      0;

  bool isSimpleElementList(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'List') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      return types.length == 1 && _containsSimpleElement(types);
    }
    return false;
  }

  String getTypeOfGenericList(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'List') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      if (types.length == 1) {
        return types.first.element.name;
      }
    }
    return '';
  }

  bool _isNestedType(DartType t) =>
      t.name != null && (t.name == 'List' || t.name == 'Map');

  List<DartType> _containsNestedType(List<DartType> types) =>
      types.where((DartType t) => _isNestedType(t)).toList();

  Element getNestedElement(Element el) {
    bool isNested = false;
    List types;

    if (el is FieldElement) {
      if (el.type.isDartCoreFunction) return null;
      isNested = el.type is ParameterizedType &&
          (el.type.name == 'List' || el.type.name == 'Map');
      types = (el.type as ParameterizedType).typeArguments;
    } else if (el is ClassElement) {
      isNested = (el.type.name == 'List' || el.type.name == 'Map');
      types = el.type?.typeArguments;
    }

    if (isNested && types != null) {
      List<DartType> listTypes = _containsNestedType(types);
      if (listTypes != null && listTypes.length == 1) {
        var listType = listTypes.first;
        return listType.element;
      }
    }

    return null;
  }

  isNestedElement(Element el) => getNestedElement(el) != null;

  bool isFirestoreElementMap(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'Map') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      return types.length == 2 &&
          types.first.name == 'String' &&
          _containsFirestoreElement(types);
    }
    return false;
  }

  String getTypeOfGenericMap(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'Map') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      if (types.length == 2) {
        return types.last.element.name;
      }
    }
    return '';
  }

  _isSimpleElementGeneric(DartType t) =>
      t.isDartCoreBool ||
      t.isDartCoreDouble ||
      t.isDartCoreInt ||
      t.isDynamic ||
      _isString(t) ||
      _isDateTime(t);
  bool isDynamicElementMap(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'Map') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      return types.length == 2 &&
          types.first.name == 'String' &&
          _isSimpleElementGeneric(types.last);
    }
    return false;
  }
}
