import 'package:analyzer/dart/element/element.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/helper.dart';

class FormHelper {
  final String className;
  FormHelper(this.className);

  String _createEditingControllerAttr(FieldElement el) =>
      'TextEditingController _${el.displayName}EditingController;';

  String _createAttr(FieldElement el) =>
      '${el.getDisplayString(withNullability: false)};';

  String _createEditingControllerGetter(FieldElement el) {
    String label = '${el.displayName}EditingController';
    return 'TextEditingController get $label{_$label=TextEditingController(text: ${el.displayName}); return _$label;}';
  }

  String _createValidator(FieldElement el) {
    // FormFieldValidator
    String label = '${el.displayName}Validator';
    String type = getElementType(el).isDartCoreString
        ? 'value is String'
        : '${el.type.getDisplayString()}.tryParse(value) != null';
    return 'String $label(String value) => ($type) ? null : "Could not parse.";';
  }

  String _createOnSaved(FieldElement el) {
    String controller = '_${el.displayName}EditingController';
    return '${el.displayName}OnSaved(value) => ${el.displayName} = $controller.text;';
  }

  String _createOnChanged(FieldElement el) {
    String controller = '_${el.displayName}EditingController';
    return '${el.displayName}OnChanged(value) => ${el.displayName} = $controller.text;';
  }

  String _createOnEditingComplete(FieldElement el) {
    String controller = '_${el.displayName}EditingController';
    return '${el.displayName}OnEditingComplete() => ${el.displayName} = $controller.text;';
  }

  String _createOnFieldSubmitted(FieldElement el) {
    String controller = '_${el.displayName}EditingController';
    return '${el.displayName}OnFieldSubmitted(value) => ${el.displayName} = $controller.text;';
  }

  bool _supportedType(FieldElement el) {
    FieldAnnotationHelper annotation = FieldAnnotationHelper(el);
    var type = getElementType(el);
    return (type.isDartCoreDouble ||
            type.isDartCoreInt ||
            type.isDartCoreNum ||
            type.isDartCoreString) &&
        !annotation.ignore;
  }

  _createFieldAttribues(FieldElement el, StringBuffer buffer) {
    if (_supportedType(el)) {
      buffer
        ..writeln(_createAttr(el))
        ..writeln(_createEditingControllerAttr(el))
        ..writeln(_createEditingControllerGetter(el));
    } else {
      buffer.writeln(
          '\t// unsupported attribute \'${el.type.getDisplayString()} ${el.name}\'');
    }
  }

  _createFieldMethods(FieldElement el, StringBuffer buffer) {
    if (_supportedType(el)) {
      buffer
        ..writeln(_createValidator(el))
        ..writeln(_createOnSaved(el))
        ..writeln(_createOnChanged(el))
        ..writeln(_createOnEditingComplete(el))
        ..writeln(_createOnFieldSubmitted(el));
    } else {
      buffer.writeln(
          '\t// unsupported attribute \'${el.type.getDisplayString()} ${el.name}\'');
    }
  }

  _createFormValidate(List<FieldElement> accessibleFields, String className,
      StringBuffer buffer) {
    buffer
      ..writeln('bool validate()=>formKey.currentState.validate();')
      ..writeln('bool validateManual() =>');
    Iterator<FieldElement> i =
        accessibleFields.where((el) => _supportedType(el)).iterator;
    bool moveNext = i.moveNext();
    while (moveNext) {
      var el = i.current;
      buffer.write(
          '((_${el.displayName}EditingController != null) ? ${el.displayName}Validator(_${el.displayName}EditingController.text) == null : true )');
      moveNext = i.moveNext();
      buffer.writeln(moveNext ? '&&' : ';');
    }
  }

  _createFormReset(List<FieldElement> accessibleFields, String className,
      StringBuffer buffer) {
    buffer
      ..writeln('void reset()=>formKey.currentState.reset();')
      ..writeln('void resetManual(){');
    for (var el in accessibleFields.where((el) => _supportedType(el))) {
      buffer.writeln(
          'if(_${el.displayName}EditingController != null){_${el.displayName}EditingController.text = initialState.${el.displayName};}');
    }
    buffer.writeln('}');
  }

  _createFormSave(List<FieldElement> accessibleFields, String className,
      StringBuffer buffer) {
    buffer
      ..writeln('void save()=>formKey.currentState.save();')
      ..writeln('void saveManual(){');
    for (var el in accessibleFields.where((el) => _supportedType(el))) {
      buffer.writeln(
          '${el.displayName} = (_${el.displayName}EditingController != null) ? _${el.displayName}EditingController.text : ${el.displayName};');
    }
    buffer.writeln('}');
  }

  Iterable<String> createHelperExtension(
      List<FieldElement> accessibleFields, String className) sync* {
    StringBuffer buffer = StringBuffer();

    buffer
      ..writeln('abstract class ${className}Helper{')
      ..writeln('final formKey = GlobalKey<FormState>();')
      ..writeln('$className initialState;');

    for (var el in accessibleFields) {
      _createFieldAttribues(el, buffer);
    }
    _createFormValidate(accessibleFields, className, buffer);
    _createFormReset(accessibleFields, className, buffer);
    _createFormSave(accessibleFields, className, buffer);

    for (var el in accessibleFields) {
      _createFieldMethods(el, buffer);
    }

    buffer.writeln('}');
    yield buffer.toString();
  }
}
