import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

typedef String CreateCallback(FieldElement el);

class FormHelper {
  final String className;
  FormHelper(this.className);

  String _createForField(FieldElement el, CreateCallback callback) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);
    var type = getElementType(el);

    var supportedType = type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isDartCoreNum ||
        type.isDartCoreString;

    if (annotation.ignore) {
      return '\t// ignoring attribute \'${el.type.getDisplayString()} ${el.name}\'';
    } else if (supportedType && callback != null) {
      return callback(el);
    } else {
      return '\t// unsupported attribute \'${el.type.getDisplayString()} ${el.name}\'';
    }
  }

  String _createEditingControllerAttr(FieldElement el) =>
      'TextEditingController _${el.displayName}EditingController;';

  String _createAttr(FieldElement el) =>
      '${el.getDisplayString(withNullability: false)};';

  String _createEditingControllerGetter(FieldElement el) {
    String label = '${el.displayName}EditingController';
    return 'get $label{_$label=TextEditingController(text: ${el.displayName}); return _$label;}';
  }

  String _createValidatorFunction(FieldElement el) {
    // FormFieldValidator
    String label = '${el.displayName}Validator';
    String type = getElementType(el).isDartCoreString
        ? 'value is String'
        : '${el.type.getDisplayString()}.tryParse(value) != null';
    return 'String $label(String value) => ($type) ? null : "Could not parse.";';
  }

  Iterable<String> createHelperExtension(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('abstract class ${className}Helper{');

    for (var el in accessibleFields) {
      buffer.writeln(
        _createForField(el, _createAttr),
      );
      buffer.writeln(
        _createForField(el, _createEditingControllerAttr),
      );
      buffer.writeln(
        _createForField(
          el,
          _createEditingControllerGetter,
        ),
      );
      buffer.writeln(
        _createForField(
          el,
          _createValidatorFunction,
        ),
      );
    }

    buffer.writeln('}');
    yield buffer.toString();
  }
}
