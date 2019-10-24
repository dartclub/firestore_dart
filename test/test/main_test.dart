import 'package:firebase_admin_interop/firebase_admin_interop.dart' as interop;

import 'package:firestore_api/firestore_api.dart';
import 'package:test/test.dart';

part 'main_test.g.dart';

@FirestoreDocument()
class Foo {
  final DocumentReference selfRef;
  String name;

  Foo({this.selfRef, this.name});
}

void main() {
  test('test firestore', () async {
    print("running");

    final admin = interop.FirebaseAdmin.instance;
    final app = admin.initializeApp();
    print(app.options.projectId);

     /*interop.CollectionReference testCol = app.firestore().collection("test");
     await testCol.add(interop.DocumentData.fromMap({"name": "my test"}));

     interop.QuerySnapshot querySnapshot = await testCol.get();

     for (interop.DocumentSnapshot snapshot in querySnapshot.documents) {
       print(snapshot.data.getString("name"));
     }*/

    print("firestore: ${app.firestore().toString()}");

     List<interop.CollectionReference> collections = await app.firestore().listCollections();
     print("collections: ${collections.length}");
     
     for (interop.CollectionReference col in collections) {
       print(col.path);
       
     }

    expect(1, 1);
    
  });
}
