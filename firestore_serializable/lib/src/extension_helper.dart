import 'package:firestore_serializable/src/helper.dart';

class ExtensionHelper {
  ExtensionHelper();
  Iterable<String> createExtension(String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('extension on $className{');
    buffer.writeln(
        '$className fromSnapshot(DocumentSnapshot snapshot) => ${createSuffix(className)}FromSnapshot(snapshot);');
    buffer.writeln(
        '$className fromMap(Map<String, dynamic> data) => ${createSuffix(className)}FromMap(data);');
    buffer.writeln(
        'Map<String, dynamic> toMap($className model) => ${createSuffix(className)}ToMap(model);');
    buffer.writeln('}');
    yield buffer.toString();
  }
}
