import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
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

  Object _getValue(DartObject dartObject) {
    if (dartObject.isNull) {
      return null;
    }
    return ConstantReader(dartObject).literalValue;
  }

  _getParams() {
    if (hasFirestoreAttribute) {
      DartObject obj = _meta.computeConstantValue();
      attribute = FirestoreAttribute(
        ignore: obj.getField('ignore').toBoolValue(),
        nullable:
            obj.getField('nullable').toBoolValue(), // TODO implement nullable
        alias: obj.getField('alias').toStringValue(),
        defaultValue: _getValue(
            obj.getField('defaultValue')), // TODO implement defaultValue
      );
    }
  }

  get hasFirestoreAttribute => _hasFirestoreAttribute;
  get ignore => attribute.ignore;
  get nullable => attribute.nullable;
  get alias => attribute.alias;
  get defaultValue => attribute.defaultValue;
}
