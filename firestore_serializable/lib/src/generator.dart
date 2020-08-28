import 'package:build/build.dart';
import 'package:firestore_serializable/src/annotation_helper.dart';
import 'package:firestore_serializable/src/map_helper.dart';
import 'package:firestore_serializable/src/snapshot_helper.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:firestore_annotations/firestore_annotations.dart';

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

    return _Generator(this, element as ClassElement, annotation).generate();
  }
}

class _Generator {
  final GeneratorForAnnotation generator;
  final ClassElement element;
  final ConstantReader annotation;

  Set<String> fields = <String>{};
  _Generator(this.generator, this.element, this.annotation);
  Iterable<String> generate() sync* {
    final className = element.name;
    ClassAnnotationHelper annotationHelper = ClassAnnotationHelper(element);

    final accessibleFields = <FieldElement>[];

    for (var el in element.fields) {
      // TODO find more elegant solution
      // TODO ignore getter, if no setter with the same name is available
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

    SnapshotHelper snapshotHelper = SnapshotHelper(className);

    yield* snapshotHelper.createFromSnapshot(accessibleFields,
        annotationHelper.hasSelfRef, annotationHelper.nullable);
    yield* snapshotHelper.createFromMap(
        accessibleFields, className, annotationHelper.nullable);

    yield* MapHelper(className).createToMap(accessibleFields);
  }
}
