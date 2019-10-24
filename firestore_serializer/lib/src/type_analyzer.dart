import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:firestore_serializer/src/helper.dart';

void analyzeTypeRecursive(Element el, StringBuffer buffer) {
    DartType type = getTypeOfElement(el);
    
    buffer.writeln("Element - ${el} / ${el.runtimeType} - ${type?.name} isDartCoreInt: ${type.isDartCoreInt}");
    if (el is TypeParameterElement) {
      buffer.writeln("el.type.element: ${el.type.element}");
    }
    if (type is ParameterizedType) {
      String typeArguments = type.typeArguments.map((DartType type) {
        return type.name;
      }).join(",");
      String typeParameters =
          type.typeParameters.map((TypeParameterElement type) {
        return "${type.name} - bound: ${type.bound}";
      }).join(",");
      buffer.writeln("typeArguments: $typeArguments");
      buffer.writeln("typeParameters: $typeParameters");
      buffer.writeln("-----");
      if (type.typeArguments.isNotEmpty) {
        analyzeTypeRecursive(type.typeArguments.first.element, buffer);
      }
    }
  }

  void analyzeType(Element el) {
    StringBuffer buffer = StringBuffer();

    analyzeTypeRecursive(el, buffer);

    File out = File("list-type.txt");
    out.createSync();
    out.writeAsStringSync(buffer.toString());
  }
