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

  _isSimpleElementGeneric(DartType type) =>
      type.isDartCoreBool ||
      type.isDartCoreDouble ||
      type.isDartCoreInt ||
      type.isDynamic ||
      _isString(type) ||
      _isDateTime(type);

  bool _isDateTime(DartType type) => type.name == 'DateTime';

  bool _isString(DartType type) => type.name == 'String';

  bool _isDocumentRef(DartType type) => type.name == 'DocumentReference';
  bool _isCollectionRef(DartType type) => type.name == 'CollectionReference';
  bool _isGeoPoint(DartType type) => type.name == 'GeoPoint';
  bool _isBlob(DartType type) => type.name == 'Blob';

  bool isFirestoreDataType(DartType type) {
    return type != null &&
        (type.isDartCoreNull ||
            _isSimpleElementGeneric(type) ||
            _isDocumentRef(type) ||
            _isCollectionRef(type) ||
            _isGeoPoint(type) ||
            _isBlob(type));
  }

  bool isDynamicElement(DartType type) => type.isDynamic;

  bool isFunction(DartType type) => type != null && type.isDartCoreFunction;

  bool hasFirestoreDocumentAnnotation(DartType type) {
    if (type == null) return false;
    var meta = type.element.metadata;
    if (meta.length > 0) {
      for (var m in meta) {
        if (getName(m.element) == 'FirestoreDocument') {
          return true;
        }
      }
    }
    return false;
  }

  String getTypeOfFirestoreElement(DartType type) => type.element.displayName;

  _containsFirestoreElement(List<DartType> types) =>
      types
          .where((DartType type) => hasFirestoreDocumentAnnotation(type))
          .length >
      0;

  @deprecated
  bool isFirestoreElementList(DartType type) {
    if (type is ParameterizedType && type.name == 'List') {
      List<DartType> types = type.typeArguments;
      return types.length == 1 && _containsFirestoreElement(types);
    }
    return false;
  }

  bool _containsSimpleElement(List<DartType> types) =>
      types.where((DartType type) => _isSimpleElementGeneric(type)).length > 0;

  @deprecated
  bool isSimpleElementList(DartType type) {
    if (type is ParameterizedType && type.name == 'List') {
      List<DartType> types = type.typeArguments;
      return types.length == 1 && _containsSimpleElement(types);
    }
    return false;
  }

  isListElement(DartType type) {
    if (type != null) {
      return type.name == 'List';
    } else {
      return false;
    }
  }

  isMapElement(DartType type) {
    if (type != null) {
      return type.name == 'Map';
    } else {
      return false;
    }
  }

  isNestedElement(DartType type) => isListElement(type) || isMapElement(type);

  String getTypeOfGenericList(DartType type) {
    if (type is ParameterizedType && type.name == 'List') {
      List<DartType> types = type.typeArguments;
      if (types.length == 1) {
        return types.first.element.name;
      }
    }
    return '';
  }

  DartType getTypeOfElement(Element el) {
    if (el is FieldElement) {
      return el.type;
    } else if (el is ClassElement) {
      return el.type;
    } else if (el is TypeParameterElement) {
      return el.type;
    } else {
      return null;
    }
  }

  List<DartType> _containsNestedType(List<DartType> types) =>
      types.where((DartType t) => isNestedElement(t)).toList();

  Element getNestedElement(DartType type) {
    if (type is ParameterizedType) {
      if (type.name == 'Map') {
        List<DartType> types = type.typeArguments;
        if (types.length == 2) {
          return types.last.element;
        }
      } else if (type.name == 'List') {
        List<DartType> types = type.typeArguments;
        if (types.length == 1) {
          return types.first.element;
        }
      }
    }
    return null;
  }

  @deprecated
  bool isFirestoreElementMap(DartType type) {
    if (type is ParameterizedType && type.name == 'Map') {
      List<DartType> types = type.typeArguments;
      return types.length == 2 &&
          types.first.name == 'String' &&
          _containsFirestoreElement(types);
    }
    return false;
  }

  @deprecated
  bool isDynamicElementMap(DartType type) {
    if (type is ParameterizedType && type.name == 'Map') {
      List<DartType> types = type.typeArguments;
      return types.length == 2 &&
          _isString(types.first) &&
          _isSimpleElementGeneric(types.last);
    }
    return false;
  }

  @deprecated
  String getTypeOfGenericMap(FieldElement el) {
    if (el.type is ParameterizedType && el.type.name == 'Map') {
      List<DartType> types = (el.type as ParameterizedType).typeArguments;
      if (types.length == 2) {
        return types.last.element.name;
      }
    }
    return '';
  }
}
