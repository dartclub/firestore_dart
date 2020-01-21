import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:firestore_serializable/src/helper.dart';

void analyzeTypeRecursive(Element el, StringBuffer buffer) {
    DartType type = getElementType(el);
    
    buffer.writeln("Element - ${el} / ${el.runtimeType} - ${type?.getDisplayString()} isDartCoreInt: ${type.isDartCoreInt}");
    if (el is TypeParameterElement) {
      buffer.writeln("el.type.element: ${el.type.element}");
    }
    if (type.isDartCoreList || type.isDartCoreSet || type.isDartCoreMap) {
      String typeArguments = (type as InterfaceType).typeArguments.map((DartType type) {
        return type.getDisplayString();
      }).join(",");
      
      buffer.writeln("typeArguments: $typeArguments");
      buffer.writeln("-----");
      if ((type as InterfaceType).typeArguments.isNotEmpty) {
        analyzeTypeRecursive((type as InterfaceType).typeArguments.first.element, buffer);
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
