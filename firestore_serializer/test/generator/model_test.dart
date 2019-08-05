import 'dart:typed_data';

import 'package:firestore_api/firestore_api.dart';

import 'model.dart';
import 'package:test/test.dart';

main() {
  group('model', () {
    Model model;
    Map<String, dynamic> map;

    setUp(() {
      model = Model(
        blob: Blob(Uint8List.fromList([1, 2, 3])),
        dateTime: DateTime.now(),
        dynamicMap: <String, dynamic>{
          "first": 1,
          "second": 2.0,
          "third": "3",
        },
        function: () {},
        ignoredAttribute: 42,
        intList: [1, 2, 3],
        selfRef: null,
        submodel: Submodel(),
        submodelList: [Submodel(), Submodel(), Submodel()],
        submodelMap: <String, Submodel>{
          "first": Submodel(),
          "second": Submodel(),
          "third": Submodel(),
        },
        dynamicList: [1, 2, 3],
        number: 1,
      );
      map = model.toMap();
    });

    group('Model().toMap', () {
      test('@FirestoreAttribute(ignore: true)', () {
        expect(map.containsKey('ignoredAttribute'), false);
      });
      test('@FirestoreAttribute(alias: \'otherName\')', () {
        expect(map.containsKey('number'), false);
        expect(map.containsKey('otherName'), true);
      });
//TODO implement required
      test('@FirestoreAttribute(required: true)', () {
        expect(true, false);
      });
// TODO implement nullable
      test('@FirestoreAttribute(nullable: false)', () {
        expect(true, false);
      });
// TODO implement defaultValue
      test('@FirestoreAttribute(defaultValue: ...)', () {
        expect(true, false);
      });
      test('private attributes', () {
        expect(map.containsKey('_privateAttribute'), false);
      });
      test('@FirebaseSubdocument Submodel', () {
        expect(map.containsKey('submodel'), true);
        expect(map['submodel'] is Map, true);
        expect(map['submodel'] is Submodel, false);
      });

      test('List<@FirestoreSubdocument Submodel>', () {
        expect(map.containsKey('submodelList'), true);
        var list = map['submodelList'];
        expect(list is List, true);
        expect(list.length, 3);
        for (var item in list) {
          expect(item is Map, true);
          expect(item is Submodel, false);
        }
      });

      test('List<int>', () {
        expect(map.containsKey('intList'), true);
        var list = map['intList'];
        expect(list is List, true);
      });
      test('List<dynamic>', () {
        expect(map.containsKey('dynamicList'), true);
        var list = map['dynamicList'];
        expect(list is List, true);
      });
      test('Map<String, @FirestoreSubdocument Submodel>', () {
        expect(map.containsKey('submodelMap'), true);
        Map m = map['submodelMap'];
        expect(m is Map, true);
        expect(m.length, 3);
        for (var item in m.keys) {
          expect(item is String, true);
          expect(m[item] is Map, true);
          expect(m[item] is Submodel, false);
        }
      });

      test('Map<String, dynamic>', () {
        expect(map.containsKey('dynamicMap'), true);
        Map m = map['dynamicMap'];
        expect(m is Map, true);
        expect(m.length, 3);
        for (var item in m.keys) {
          expect(item is String, true);
        }
      });

// TODO implement nested Element tests
      test('List<List<dynamic>>', () {});

      test('Map<String, Map<K,V>>', () {
        expect(true, false);
      });
      test('Map<String, List<T>>', () {
        expect(true, false);
      });
      test('List<Map<String, dynamic>>', () {
        expect(true, false);
      });

      test('DateTime', () {
        expect(map.containsKey('dateTime'), true);
        expect(map['dateTime'] is DateTime, true);
      });

      test('Blob', () {
        expect(map.containsKey('blob'), true);
        expect(map['blob'] is Blob, true);
      });

      test('Function', () {
        expect(map.containsKey('function'), false);
      });
    });

    group('Model.fromSnapshot', () {});

    tearDown(() {});
  });
}
