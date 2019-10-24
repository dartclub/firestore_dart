import 'dart:typed_data';

import 'package:firestore_api/firestore_api.dart';

import 'model.dart';
import 'package:test/test.dart';
/*
main() {
  group('Model()', () {
    Model model;
    Map<String, dynamic> map;
    setUp(() {
      model = Model(
        ignoredAttribute: 42,
        number: 1,
        submodel: Submodel.fromMap({}),
        intList: [1, 2, 3],
        submodelList: <Submodel>[Submodel(), Submodel(), Submodel()],
        submodelMap: <String, Submodel>{
          "first": Submodel(),
          "second": Submodel(),
          "third": Submodel(),
        },
        dateTime: DateTime.now(),
        blob: Blob(Uint8List.fromList([1, 2, 3])),
        function: () {},
        selfRef: null,
      );

      map = model.toMap();
    });
    group('Model()', () {
      group('Model().toMap', () {
        group('Simple attributes', () {
          test('ignore', () {
            expect(map.containsKey('ignoreAttribute'), false);
            expect(map.containsKey('function'), false);
            expect(map.containsKey('_privateAttribute'), false);
          });
          test('simple attributes', () {
            expect(map.containsKey('number'), false);
            expect(map.containsKey('otherName'), true);
            expect(map.containsKey('dateTime'), true);
            expect(map.containsKey('blob'), true);
          });

          test('FirestoreSubdocument', () {
            expect(map.containsKey('submodel'), true);
            //expect(map["submodel"] is Submodel, true);
          });
        });

        group('Lists', () {
          test('List of FirestoreSubdocument', () {
            expect(map.containsKey('submodelList'), true);
            //expect(map["submodelList"] is List<Submodel>, true);
          });
          test('List<int>', () {
            expect(map.containsKey('intList'), true);
          });
          test('List<List<int>>', () {
            expect(map.containsKey('nestedIntList'), true);
          });

          test('List<dynamic>', () {
            expect(map.containsKey('dynamicList'), true);
          });
        });
        group('Maps', () {
          test('Map of FirestoreSubdocument', () {
            expect(map.containsKey('submodelMap'), true);
            expect(map['submodelMap'].keys.length, 3);
            //expect(map["submodelMap"] is List<Submodel>, true);
          });
        });
      });

      group('Model.fromSnapshot', () {});

      tearDown(() {});
    });
  });

  group('Submodel()', () {});
}
*/