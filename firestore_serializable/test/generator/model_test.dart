import 'dart:typed_data';

import 'package:firestore_api/firestore_api.dart';
import 'model.dart';
import 'package:test/test.dart';

main() {
  group('Model()', () {
    Model model, model2;
    Map<String, dynamic> map;
    setUp(() {
      model = Model(
        ignoredAttribute: 3,
        function: () {},
        number: 42,
        intListDefaultValue: null,
        stringDefaultValue: null,
        intList: [4, 5, 6],
        nestedIntList: [
          [1, 2, 3],
          [4, 5, 6]
        ],
        doublyNestedIntList: [
          [
            [1, 2, 3],
            [4, 5, 6],
          ],
          [
            [7, 8, 9],
            [8, 7, 6],
          ],
        ],
        dynamicList: [
          'String',
          42,
          3.142,
        ],
        submodelList: [
          Submodel(attribute: 1),
          Submodel(attribute: 2),
          Submodel(attribute: 3)
        ],
        nestedSubmodelList: [
          [Submodel(attribute: 1)],
          [Submodel(attribute: 2)],
          [Submodel(attribute: 3)],
        ],
        map: {
          'foo': 1,
          'bar': 2,
          'baz': 3,
        },
        nestedMap: {
          'foo': {'bar': 'baz'},
        },
        submodelMap: {
          'foo': Submodel(attribute: 1),
          'bar': Submodel(attribute: 2),
          'baz': Submodel(attribute: 3),
        },
        dateTime: DateTime.now(),
        blob: Blob(Uint8List.fromList([1, 2, 3])),
        attribute: 42,
      );

      map = model.toMap();
      model2 = Model.fromMap(map);
    });
    group('Model().toMap', () {
      test('ignore', () {
        expect(map.containsKey('ignoreAttribute'), false);
        expect(map.containsKey('function'), false);
        expect(map.containsKey('_privateAttribute'), false);
      });
      test('alias', () {
        expect(map.containsKey('otherName'), true);
      });
      group('defaultValue', () {
        test('List', () {
          expect(map.containsKey('intListDefaultValue'), true);
          expect(map['intListDefaultValue'], [1, 2, 3]);
        });
        test('String', () {
          expect(map.containsKey('stringDefaultValue'), true);
          // TODO test String escape better
          expect(map['stringDefaultValue'],
              'default Value "Let\'s see if the escaping works"');
        });
      });

      group('List', () {
        group('List<T>', () {
          test('List<int>', () {
            expect(map.containsKey('intList'), true);
            expect(map['intList'], [4, 5, 6]);
          });
          test('List<List<int>>', () {
            expect(map.containsKey('nestedIntList'), true);
            expect(map['nestedIntList'].length, 2);
            expect(map['nestedIntList'].first.length, 3);
          });
          test('<List<List<List<int>>>', () {
            print(map.keys.join(','));
            expect(map.containsKey('doublyNestedIntList'), true);
            expect(map['doublyNestedIntList'].length, 2);
            expect(map['doublyNestedIntList'].first.length, 2);
            expect(map['doublyNestedIntList'].first.first.length, 3);
          });
        });
        test('List with dynamic', () {
          expect(map.containsKey('dynamicList'), true);
          expect(map['dynamicList'][0] is String, true);
          expect(map['dynamicList'][1] is int, true);
          expect(map['dynamicList'][2] is double, true);
        });
        test('List<Submodel>', () {
          expect(map.containsKey('submodelList'), true);
          expect(map['submodelList'][0]['attribute'], 1);
          expect(map['submodelList'][1]['attribute'], 2);
          expect(map['submodelList'][2]['attribute'], 3);
        });
      });

      group('Map', () {
        test('Map<String, dynamic>', () {
          expect(map.containsKey('map'), true);
          expect(map['map'].keys.length, 3);
        });
        test('Map<String, Map<String, dynamic>>', () {
          expect(map.containsKey('nestedMap'), true);
          expect(map['nestedMap']['foo']['bar'], 'baz');
        });
        test('Map<String, Submodel>', () {
          expect(map.containsKey('submodelMap'), true);
          expect(map['submodelMap'].keys.length, 3);
        });
      });

      group('primitives', () {
        test('DateTime', () {
          expect(map.containsKey('dateTime'), true);
        });
        test('Blob', () {
          expect(map.containsKey('blob'), true);
        });
        test('dynamic', () {
          expect(map.containsKey('attribute'), true);
          expect(map['attribute'], 42);
        });
      });
    });

    group('Model.fromSnapshot', () {});

    tearDown(() {});
  });

  group('Submodel()', () {});
}
