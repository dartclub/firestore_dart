library firestore_api;

import 'dart:async';

import 'dart:typed_data';

typedef OnEachDocumentSnapshot = Function(DocumentSnapshot snapshot);
typedef DynamicMap = Map<String, dynamic>;

abstract class DataWrapper {
  dynamic wrapValue(dynamic value);
  dynamic unwrapValue(dynamic value);
  dynamic unwrapFieldValue(FieldValue value);

  /// wraps Firestore library values into this API values
  ///
  /// returns a new Map
  DynamicMap? wrapMap(DynamicMap? data) {
    if (data == null) {
      return null;
    }
    DynamicMap result = {};
    data.forEach((key, value) {
      result[key] = wrapValue(value);
    });
    return result;
  }

  /// wraps Firestore library values into this API values
  ///
  /// returns a new List
  List<dynamic>? wrapList(List<dynamic>? data) {
    if (data == null) {
      return null;
    }
    List<dynamic> result = [];
    data.forEach((value) {
      result.add(wrapValue(value));
    });
    return result;
  }

  /// unwraps this API values into Firestore internal values
  ///
  /// returns a new Map
  DynamicMap unwrapMap(DynamicMap data) {
    DynamicMap result = {};
    data.forEach((key, value) {
      result[key] = unwrapValue(value);
    });
    return result;
  }

  /// unwraps this API values into Firestore internal values
  ///
  /// returns a new Map
  List<dynamic>? unwrapList(List? data) {
    if (data == null) {
      return null;
    }
    List<dynamic> result = [];
    data.forEach((value) {
      result.add(unwrapValue(value));
    });
    return result;
  }
}

/// Metadata about a snapshot, describing the state of the snapshot.
class SnapshotMetadata {
  SnapshotMetadata(this.hasPendingWrites, this.isFromCache);

  /// Whether the snapshot contains the result of local writes that have not yet
  /// been committed to the backend.
  ///
  /// If your listener has opted into metadata updates (via
  /// [DocumentListenOptions] or [QueryListenOptions]) you will receive another
  /// snapshot with `hasPendingWrites` equal to `false` once the writes have been
  /// committed to the backend.
  final bool hasPendingWrites;

  /// Whether the snapshot was created from cached data rather than guaranteed
  /// up-to-date server data.
  ///
  /// If your listener has opted into metadata updates (via
  /// [DocumentListenOptions] or [QueryListenOptions]) you will receive another
  /// snapshot with `isFomCache` equal to `false` once the client has received
  /// up-to-date data from the backend.
  final bool isFromCache;
}

/// An enumeration of firestore source types.
enum Source {
  /// Causes Firestore to try to retrieve an up-to-date (server-retrieved) snapshot, but fall back to
  /// returning cached data if the server can't be reached.
  serverAndCache,

  /// Causes Firestore to avoid the cache, generating an error if the server cannot be reached. Note
  /// that the cache will still be updated if the server request succeeds. Also note that
  /// latency-compensation still takes effect, so any pending write operations will be visible in the
  /// returned data (merged into the server-provided data).
  server,

  /// Causes Firestore to immediately return a value from the cache, ignoring the server completely
  /// (implying that the returned value may be stale with respect to the value on the server). If
  /// there is no data in the cache to satisfy the [get()] or [getDocuments()] call,
  /// [DocumentReference.get()] will return an error and [Query.getDocuments()] will return an empty
  /// [QuerySnapshot] with no documents.
  cache,
}

abstract class Firestore {
  CollectionReference collection(String path);
  Query collectionGroup(String path);

  DocumentReference document(String path);
  WriteBatch batch();
  Future<T> runTransaction<T>(
      Future<T> transactionHandler(Transaction transaction),
      {Duration timeout = const Duration(seconds: 5)});
}

abstract class Transaction {
  Future<DocumentSnapshot> get(DocumentReference documentReference);

  Future<void> delete(DocumentReference documentReference);

  Future<void> update(DocumentReference documentReference, DynamicMap data);

  Future<void> set(DocumentReference documentReference, DynamicMap data);
}

abstract class DocumentSnapshot {
  DynamicMap? get data;
  String get documentID;
  bool get exists;
  DocumentReference get reference;

  /// Metadata about this snapshot concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata;
}

abstract class DocumentReference {
  Future<DocumentSnapshot> get document;
  String get documentID;
  String get path;
  Future<void> setData(DynamicMap data, {bool merge: false});
  Future<void> update(DynamicMap data);
  Future<void> delete();
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false});
  CollectionReference collection(String collectionPath);
  CollectionReference get parent;

  @override
  bool operator ==(dynamic o) => o is DocumentReference && o.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    return path;
  }
}

abstract class CollectionReference extends Query {
  Future<DocumentReference> add(DynamicMap document);
  DocumentReference document([String path]);
  Query orderBy(String field, {bool descending: false});
  DocumentReference? get parent;
}

abstract class QuerySnapshot {
  List<DocumentSnapshot> get documents;
  List<DocumentChange> get documentChanges;
  bool get empty;
  SnapshotMetadata get metadata;
  void forEach(OnEachDocumentSnapshot onEach);
}

abstract class DocumentChange {
  int get oldIndex;
  int get newIndex;
  DocumentChangeType get type;
  DocumentSnapshot get document;
}

abstract class Query {
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false});
  Future<QuerySnapshot> getDocuments({Source source = Source.serverAndCache});
  Query where(
    String field, {
    dynamic? isEqualTo,
    dynamic? isLessThan,
    dynamic? isLessThanOrEqualTo,
    dynamic? isGreaterThan,
    dynamic? isGreaterThanOrEqualTo,
    dynamic? arrayContains,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    List<dynamic>? arrayContainsAny,
    bool? isNull,
  });
  Query orderBy(String field, {bool descending: false});
  Query limit(int length);

  Query startAfterDocument(DocumentSnapshot documentSnapshot);
  Query startAtDocument(DocumentSnapshot documentSnapshot);
  Query endAtDocument(DocumentSnapshot documentSnapshot);
  Query endBeforeDocument(DocumentSnapshot documentSnapshot);

  Query startAfter(List<dynamic> values);
  Query startAt(List<dynamic> values);
  Query endAt(List<dynamic> values);
  Query endBefore(List<dynamic> values);
}

enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

abstract class WriteBatch {
  Future<void> commit();
  void delete(DocumentReference document);
  void setData(DocumentReference document, DynamicMap data,
      {bool merge = false});
  void updateData(DocumentReference document, DynamicMap data);
}

enum FieldValueType {
  arrayUnion,
  arrayRemove,
  delete,
  serverTimestamp,
  increment,
}

class FieldValue {
  FieldValue._(this.type, this.value);

  final FieldValueType type;

  final dynamic value;

  static final FieldValue DELETE = FieldValue._(FieldValueType.delete, null);
  static final FieldValue SERVER_TIMESTAMP =
      FieldValue._(FieldValueType.serverTimestamp, null);

  static FieldValue delete() => DELETE;
  static FieldValue serverTimestamp() => DELETE;

  static FieldValue increment(num value) =>
      FieldValue._(FieldValueType.increment, value);
  static FieldValue arrayRemove(List<dynamic> value) =>
      FieldValue._(FieldValueType.arrayRemove, value);
  static FieldValue arrayUnion(List<dynamic> value) =>
      FieldValue._(FieldValueType.arrayUnion, value);
}

// oriented at the cloud_firestore package's Blob implementation
class Blob {
  const Blob(this.bytes);

  final Uint8List bytes;

  @override
  bool operator ==(dynamic other) => other is Blob && bytes == other.bytes;
}

abstract class BatchHelperService {
  static const MAX_ENTRIES_PER_BATCH = 450; // real limit is 500
  final Firestore firestore;
  final DocumentReference reference;

  late WriteBatch batch;
  int batchCount = 0;

  BatchHelperService(this.reference, this.firestore);

  processInternal({DynamicMap data});

  _addDeleteToBatch(DocumentReference ref,
      {int commitAfter = MAX_ENTRIES_PER_BATCH}) async {
    batch.delete(ref);
    await _processBatch(commitAfter);
  }

  _addUpdateToBatch(DocumentReference ref, DynamicMap data,
      {int commitAfter = MAX_ENTRIES_PER_BATCH}) async {
    batch.updateData(ref, data);
    await _processBatch(commitAfter);
  }

  Future _processBatch(int commitAfter) async {
    batchCount++;
    if (batchCount > commitAfter) {
      batchCount = 0;
      await batch.commit();
      batch = firestore.batch();
    }
  }

  delete() async {
    batch = firestore.batch();
    await processInternal();
    return _addDeleteToBatch(reference, commitAfter: 0);
  }

  update(DynamicMap data) async {
    batch = firestore.batch();
    await processInternal(data: data);
    return _addUpdateToBatch(reference, data, commitAfter: 0);
  }

  Future deleteSnapshots(Iterable<DocumentSnapshot> snapshots) async {
    for (DocumentSnapshot snapshot in snapshots) {
      await _addDeleteToBatch(snapshot.reference);
    }
  }

  Future updateSnapshots(
      Iterable<DocumentSnapshot> snapshots, DynamicMap data) async {
    for (DocumentSnapshot snapshot in snapshots) {
      await _addUpdateToBatch(snapshot.reference, data);
    }
  }
}

mixin BatchHelper {
  static const MAX_ENTRIES_PER_BATCH = 450; // real limit is 500
  late Firestore _batchFirestore;
  late WriteBatch _batch;
  int _batchCount = 0;
  bool logging = false;

  startBatch(Firestore firestore) {
    _batchFirestore = firestore;
    _batch = firestore.batch();
  }

  Future<void> finishBatch() async {
    if (_batchCount > 0) {
      return _batch.commit();
    }
  }

  Future<void> addDeleteToBatch(DocumentReference ref,
      {int commitAfter = MAX_ENTRIES_PER_BATCH}) async {
    _batch.delete(ref);
    if (logging) {
      print("batch delete: $ref");
    }
    await _processBatch(commitAfter);
  }

  Future<void> addUpdateToBatch(DocumentReference ref, DynamicMap data,
      {int commitAfter = MAX_ENTRIES_PER_BATCH}) async {
    _batch.updateData(ref, data);
    if (logging) {
      print("batch update: $ref => $data");
    }
    await _processBatch(commitAfter);
  }

  Future<void> addSetDataToBatch(DocumentReference ref, DynamicMap data,
      {int commitAfter = MAX_ENTRIES_PER_BATCH, bool merge = false}) async {
    _batch.setData(ref, data, merge: merge);
    if (logging) {
      print("batch set: $ref => $data");
    }
    await _processBatch(commitAfter);
  }

  Future _processBatch(int commitAfter) async {
    _batchCount++;
    if (_batchCount > commitAfter) {
      _batchCount = 0;
      await _batch.commit();
      _batch = _batchFirestore.batch();
    }
  }
}
