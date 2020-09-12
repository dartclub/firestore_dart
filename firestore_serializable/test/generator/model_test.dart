import 'dart:typed_data';

import 'package:firestore_api/firestore_api.dart';
import 'model.dart';
import 'package:test/test.dart';

main() {
  group('serializable', () {
    Model model;
    Map<String, dynamic> map;
    setUp(() {
      model = Model(selfRef: );

      map = model.toMap();
    });

    tearDown(() {});
  });
}
