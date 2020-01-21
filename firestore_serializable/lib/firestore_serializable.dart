import 'src/generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder firestoreSerializer(BuilderOptions options) =>
    SharedPartBuilder([FirestoreDocumentGenerator()], 'firestore_api');
