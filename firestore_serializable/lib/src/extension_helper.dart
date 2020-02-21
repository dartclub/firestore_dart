import 'package:firestore_serializable/src/helper.dart';

class ExtensionHelper {
  ExtensionHelper();
  Iterable<String> createExtension(String className) sync* {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('extension on $className{');
    buffer.writeln(
        'Map<String, dynamic> toMap() => ${createSuffix(className)}ToMap(this);');
    buffer.writeln('}');
    yield buffer.toString();
  }
}
