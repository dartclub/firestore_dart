import 'package:build/build.dart';
import 'package:firestore_serializer/src/map_helper.dart';
import 'package:firestore_serializer/src/snapshot_helper.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:firestore_api/firestore_api.dart';

class FirestoreDocumentGenerator
    extends GeneratorForAnnotation<FirestoreDocument> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError('Generator cannot target `$name`.',
          todo: 'Remove the FirestoreDocument annotation from `$name`.',
          element: element);
    }

    return _Generator(this, element as ClassElement, annotation, false)
        .generate();
  }
}

class FirestoreSubdocumentGenerator
    extends GeneratorForAnnotation<FirestoreSubdocument> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.name;
      throw InvalidGenerationSourceError('Generator cannot target `$name`.',
          todo: 'Remove the FirestoreDocument annotation from `$name`.',
          element: element);
    }

    return _Generator(this, element as ClassElement, annotation, true)
        .generate();
  }
}

class _Generator {
  final GeneratorForAnnotation generator;
  final ClassElement element;
  final ConstantReader annotation;
  final bool subdocument;

  Set<String> fields = <String>{};
  _Generator(this.generator, this.element, this.annotation, this.subdocument);
  Iterable<String> generate() sync* {
    final className = element.name;

    final accessibleFields = <FieldElement>[];

    for (var el in element.fields) {
      if (!el.isPublic) {
        //throw 'Error';
      } else if (el.name == 'selfRef') {
        //throw 'Error';
      } else if (el.getter == null) {
        //throw 'Error';
      } else {
        accessibleFields.add(el);
      }
    }

    yield* SnapshotHelper(subdocument)
        .createFromSnapshot(accessibleFields, className);

    yield* MapHelper(subdocument).createToMap(accessibleFields, className);
  }
}
