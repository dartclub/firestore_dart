import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_serializer/src/helper.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationHelper with Helper {
  FieldElement _el;
  ElementAnnotation _meta;
  bool _hasFirestoreAttribute = false;
  FirestoreAttribute attribute = FirestoreAttribute();

  AnnotationHelper(FieldElement element) {
    _el = element;
    if (_el.metadata.length > 0) {
      for (var m in _el.metadata) {
        if (getName(m.element) == 'FirestoreAttribute') {
          _hasFirestoreAttribute = true;
          _meta = m;
        }
      }
    }
    _getParams();
  }

  Object _getLiteral(
    DartObject dartObject,
    Iterable<String> typeInformation,
  ) {
    if (dartObject.isNull) {
      return null;
    }

    final reader = ConstantReader(dartObject);

    String badType;
    if (reader.isSymbol) {
      badType = 'Symbol';
    } else if (reader.isType) {
      badType = 'Type';
    } else if (dartObject.type is FunctionType) {
      badType = 'Function';
    } else if (!reader.isLiteral) {
      badType = dartObject.type.name;
    }

    if (badType != null) {
      badType = typeInformation.followedBy([badType]).join(' > ');
      throw ('`defaultValue` is `$badType`, it must be a literal.'); // TODO throw
    }

    final literal = reader.literalValue;

    if (literal is num || literal is String || literal is bool) {
      return literal;
    } else if (literal is List<DartObject>) {
      return [
        for (var e in literal)
          _getLiteral(e, [
            ...typeInformation,
            'List',
          ])
      ];
    } else if (literal is Map<DartObject, DartObject>) {
      final mapTypeInformation = [
        ...typeInformation,
        'Map',
      ];
      return literal.map(
        (k, v) => MapEntry(
          _getLiteral(k, mapTypeInformation),
          _getLiteral(v, mapTypeInformation),
        ),
      );
    }

    badType = typeInformation.followedBy(['$dartObject']).join(' > ');
    return null;
  }

  _getParams() {
    if (hasFirestoreAttribute) {
      DartObject obj = _meta.computeConstantValue();
      attribute = FirestoreAttribute(
        ignore: obj.getField('ignore').toBoolValue(),
        nullable:
            obj.getField('nullable').toBoolValue(), // TODO implement nullable
        alias: obj.getField('alias').toStringValue(),
        defaultValue: _getLiteral(
          obj.getField('defaultValue'),
          [],
        ),
      );
    }
  }

  get hasFirestoreAttribute => _hasFirestoreAttribute;
  get ignore => attribute.ignore;
  get nullable => attribute.nullable;
  get alias => attribute.alias;
  get defaultValue => attribute.defaultValue;
}
