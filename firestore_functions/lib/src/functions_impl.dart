import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as f;
import 'package:firebase_functions_interop/src/bindings.dart' as js
    show RuntimeOptions, HttpsFunction, CloudFunction;
import 'package:node_interop/node_interop.dart';

import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_node/firestore_node.dart';

final FirebaseFunctions functions = FirebaseFunctions(f.functions);

/// Firebase functions interop that uses github.com/dartclub/firestore_api's Firestore interface
class FirebaseFunctions {
  final f.FirebaseFunctions _functions;
  final _FirestoreFunctionsImpl _firestoreFunctions;

  FirebaseFunctions(this._functions)
      : _firestoreFunctions = _FirestoreFunctionsImpl(_functions);

  /// Configuration object for Firebase functions.
  f.Config get config => _functions.config;

  /// HTTPS functions.
  f.HttpsFunctions get https => _functions.https;

  /// Realtime Database functions.
  f.DatabaseFunctions get database => _functions.database;

  /// Firestore functions.
  _FirestoreFunctionsImpl get firestore => _firestoreFunctions;

  /// Pubsub functions.
  f.PubsubFunctions get pubsub => _functions.pubsub;

  /// Storage functions.
  f.StorageFunctions get storage => _functions.storage;

  /// Authentication functions.
  f.AuthFunctions get auth => _functions.auth;

  /// Configures the regions to which to deploy and run a function.
  ///
  /// For a list of valid values see https://firebase.google.com/docs/functions/locations
  FirebaseFunctions region(String region) {
    return FirebaseFunctions(_functions.region(region));
  }

  /// Configures memory allocation and timeout for a function.
  FirebaseFunctions runWith(js.RuntimeOptions options) {
    return FirebaseFunctions(_functions.runWith(options));
  }

  /// Export [function] under specified [key].
  ///
  /// For HTTPS functions the [key] defines URL path prefix.
  operator []=(String key, dynamic function) {
    assert(function is js.HttpsFunction || function is js.CloudFunction);
    setExport(key, function);
  }
}

class _FirestoreFunctionsImpl {
  final f.FirebaseFunctions _functions;

  _FirestoreFunctionsImpl(this._functions);

  _DocumentBuilderImpl document(String path) =>
      _DocumentBuilderImpl(_functions.firestore.document(path));
}

class _DocumentBuilderImpl {
  final f.DocumentBuilder _documentBuilder;

  _DocumentBuilderImpl(this._documentBuilder);

  /// Event handler that fires every time new data is created in Cloud Firestore.
  js.CloudFunction onCreate(f.DataEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onCreate(
          (f.DocumentSnapshot data, f.EventContext context) =>
              handler(DocumentSnapshotImpl(data), context));

  /// Event handler that fires every time data is deleted from Cloud Firestore.
  js.CloudFunction onDelete(f.DataEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onDelete(
          (f.DocumentSnapshot data, f.EventContext context) =>
              handler(DocumentSnapshotImpl(data), context));

  /// Event handler that fires every time data is updated in Cloud Firestore.
  js.CloudFunction onUpdate(f.ChangeEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onUpdate(
          (f.Change<f.DocumentSnapshot> data, f.EventContext context) =>
              handler(
                  f.Change<DocumentSnapshot>(DocumentSnapshotImpl(data.before),
                      DocumentSnapshotImpl(data.after)),
                  context));

  /// Event handler that fires every time a Cloud Firestore write of any
  /// kind (creation, update, or delete) occurs.
  js.CloudFunction onWrite(f.ChangeEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onWrite(
          (f.Change<f.DocumentSnapshot> data, f.EventContext context) =>
              handler(
                  f.Change<DocumentSnapshot>(DocumentSnapshotImpl(data.before),
                      DocumentSnapshotImpl(data.after)),
                  context));
}
