import 'model.dart';
import 'package:test/test.dart';

main() {
  group('serializable', () {
    Model model;
    Map<String, dynamic> map;
    setUp(() {
      model = Model(selfRef: null);

      map = model.toMap();
    });

    tearDown(() {});
  });
}
