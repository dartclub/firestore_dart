import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as f;
import 'package:firebase_functions_interop/src/bindings.dart' as js
    show RuntimeOptions, HttpsFunction, CloudFunction, DocumentBuilder;
import 'package:node_interop/node_interop.dart';

import 'package:firestore_api/firestore_api.dart';
import 'package:firestore_node/src/node_impl.dart' show DocumentSnapshotImpl;

export 'package:firebase_functions_interop/src/bindings.dart'
    show CloudFunction, HttpsFunction, EventAuthInfo, RuntimeOptions;
export 'package:firebase_functions_interop/src/express.dart';

export 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide Firestore;

final f.FirebaseFunctions functions = FirebaseFunctionsImpl(f.functions);

class FirebaseFunctionsImpl implements f.FirebaseFunctions {
  final f.FirebaseFunctions _functions;
  final f.FirestoreFunctions _firestoreFunctions;

  FirebaseFunctionsImpl(this._functions)
      : _firestoreFunctions = _FirestoreFunctionsImpl(_functions);

  /// Configuration object for Firebase functions.
  @override
  f.Config get config => _functions.config;

  /// HTTPS functions.
  @override
  f.HttpsFunctions get https => _functions.https;

  /// Realtime Database functions.
  @override
  f.DatabaseFunctions get database => _functions.database;

  /// Firestore functions.
  @override
  f.FirestoreFunctions get firestore => _firestoreFunctions;

  /// Pubsub functions.
  @override
  f.PubsubFunctions get pubsub => _functions.pubsub;

  /// Storage functions.
  @override
  f.StorageFunctions get storage => _functions.storage;

  /// Authentication functions.
  @override
  f.AuthFunctions get auth => _functions.auth;

  /// Configures the regions to which to deploy and run a function.
  ///
  /// For a list of valid values see https://firebase.google.com/docs/functions/locations
  @override
  f.FirebaseFunctions region(String region) {
    return FirebaseFunctionsImpl(_functions.region(region));
  }

  /// Configures memory allocation and timeout for a function.
  @override
  f.FirebaseFunctions runWith(js.RuntimeOptions options) {
    return FirebaseFunctionsImpl(_functions.runWith(options));
  }

  /// Export [function] under specified [key].
  ///
  /// For HTTPS functions the [key] defines URL path prefix.
  @override
  operator []=(String key, dynamic function) {
    assert(function is js.HttpsFunction || function is js.CloudFunction);
    setExport(key, function);
  }
}

class _FirestoreFunctionsImpl implements f.FirestoreFunctions {
  final f.FirebaseFunctions _functions;

  _FirestoreFunctionsImpl(this._functions);

  @override
  f.DocumentBuilder document(String path) =>
      _DocumentBuilderImpl(_functions.firestore.document(path));
}

class _DocumentBuilderImpl implements f.DocumentBuilder {
  final f.DocumentBuilder _documentBuilder;

  _DocumentBuilderImpl(this._documentBuilder);

  @override
  js.DocumentBuilder get nativeInstance => _documentBuilder.nativeInstance;

  @Deprecated('please use .onCreateDocument')
  js.CloudFunction onCreate(handler) => throw UnimplementedError();

  /// Event handler that fires every time new data is created in Cloud Firestore.
  js.CloudFunction onCreateDocument(
          f.DataEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onCreate(
          (f.DocumentSnapshot data, f.EventContext context) =>
              handler(DocumentSnapshotImpl(data), context));

  @Deprecated('please use .onDeleteDocument')
  @override
  onDelete(handler) => throw UnimplementedError();

  /// Event handler that fires every time data is deleted from Cloud Firestore.
  js.CloudFunction onDeleteDocument(
          f.DataEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onDelete(
          (f.DocumentSnapshot data, f.EventContext context) =>
              handler(DocumentSnapshotImpl(data), context));

  @Deprecated('please use .onUpdateDocument')
  @override
  onUpdate(handler) => throw UnimplementedError();

  /// Event handler that fires every time data is updated in Cloud Firestore.
  js.CloudFunction onUpdateDocument(
          f.ChangeEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onUpdate(
          (f.Change<f.DocumentSnapshot> data, f.EventContext context) =>
              handler(
                  f.Change<DocumentSnapshot>(DocumentSnapshotImpl(data.before),
                      DocumentSnapshotImpl(data.after)),
                  context));

  @Deprecated('please use .onWriteDocument')
  @override
  onWrite(handler) {
    // TODO: implement onWrite
    throw UnimplementedError();
  }

  /// Event handler that fires every time a Cloud Firestore write of any
  /// kind (creation, update, or delete) occurs.
  js.CloudFunction onWriteDocument(
          f.ChangeEventHandler<DocumentSnapshot> handler) =>
      _documentBuilder.onWrite(
          (f.Change<f.DocumentSnapshot> data, f.EventContext context) =>
              handler(
                  f.Change<DocumentSnapshot>(DocumentSnapshotImpl(data.before),
                      DocumentSnapshotImpl(data.after)),
                  context));
}
