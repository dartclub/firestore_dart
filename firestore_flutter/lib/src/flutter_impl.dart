import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_api/firestore_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'dart:async';

class DataWrapperImpl extends DataWrapper {
  @override
  dynamic wrapValue(dynamic value) {
    if (value is fs.DocumentReference) {
      return _DocumentReferenceImpl(value as fs.DocumentReference<DynamicMap>);
    } else if (value is Map) {
      return wrapMap(Map.castFrom(value));
    } else if (value is List) {
      return wrapList(List.castFrom(value));
    } else if (value is fs.Timestamp) {
      return value.toDate();
    } else if (value is fs.Blob) {
      return _BlobImpl(value.bytes);
    } else {
      return value;
    }
  }

  @override
  dynamic unwrapValue(dynamic value) {
    if (value is _DocumentReferenceImpl) {
      return value._documentReference;
    } else if (value is FieldValue) {
      return unwrapFieldValue(value);
    } else if (value is Map) {
      return unwrapMap(Map.castFrom(value));
    } else if (value is DateTime) {
      return fs.Timestamp.fromDate(value);
    } else if (value is List) {
      return unwrapList(value);
    } else if (value is _BlobImpl) {
      return fs.Blob(value.bytes);
    } else {
      return value;
    }
  }

  @override
  dynamic unwrapFieldValue(FieldValue fieldValue) {
    switch (fieldValue.type) {
      case FieldValueType.increment:
        return fs.FieldValue.increment(fieldValue.value);
      case FieldValueType.delete:
        return fs.FieldValue.delete();
      case FieldValueType.serverTimestamp:
        return fs.FieldValue.serverTimestamp();
      case FieldValueType.arrayRemove:
        return fs.FieldValue.arrayRemove(unwrapList(fieldValue.value)!);
      case FieldValueType.arrayUnion:
        return fs.FieldValue.arrayUnion(unwrapList(fieldValue.value)!);
    }
  }
}

final DataWrapper _dataWrapper = DataWrapperImpl();

class _BlobImpl extends Blob {
  _BlobImpl(Uint8List l) : super(l);
}

class _DocumentSnapshotImpl extends DocumentSnapshot {
  final fs.DocumentSnapshot<DynamicMap> _documentSnapshot;

  _DocumentSnapshotImpl(this._documentSnapshot);

  @override
  Map<String, dynamic>? get data {
    DynamicMap? data = _documentSnapshot.data();
    return data != null ? _dataWrapper.wrapMap(data) : null;
  }

  @override
  String get documentID => _documentSnapshot.id;

  @override
  bool get exists => _documentSnapshot.exists;

  @override
  DocumentReference get reference =>
      _DocumentReferenceImpl(_documentSnapshot.reference);

  @override
  SnapshotMetadata get metadata => SnapshotMetadata(
      _documentSnapshot.metadata.hasPendingWrites,
      _documentSnapshot.metadata.isFromCache);
}

class _DocumentChangeImpl extends DocumentChange {
  final fs.DocumentChange<DynamicMap> _documentChange;

  _DocumentChangeImpl(this._documentChange);

  @override
  DocumentSnapshot get document => _DocumentSnapshotImpl(_documentChange.doc);

  @override
  int get newIndex => _documentChange.newIndex;

  @override
  int get oldIndex => _documentChange.oldIndex;

  @override
  DocumentChangeType get type {
    switch (_documentChange.type) {
      case fs.DocumentChangeType.added:
        return DocumentChangeType.added;
      case fs.DocumentChangeType.modified:
        return DocumentChangeType.modified;
      case fs.DocumentChangeType.removed:
        return DocumentChangeType.removed;
    }
  }
}

class _QuerySnapshotImpl extends QuerySnapshot {
  final fs.QuerySnapshot<DynamicMap> _querySnapshot;

  _QuerySnapshotImpl(this._querySnapshot);

  @override
  List<DocumentChange> get documentChanges => _querySnapshot.docChanges
      .map((docChange) => _DocumentChangeImpl(docChange))
      .toList();

  @override
  List<DocumentSnapshot> get documents => _querySnapshot.docs
      .map((snapshot) => _DocumentSnapshotImpl(snapshot))
      .toList();

  @override
  bool get empty => _querySnapshot.docs.isEmpty;

  @override
  void forEach(onEach) {
    _querySnapshot.docs.forEach((snapshot) {
      onEach(_DocumentSnapshotImpl(snapshot));
    });
  }

  @override
  SnapshotMetadata get metadata => SnapshotMetadata(
      _querySnapshot.metadata.hasPendingWrites,
      _querySnapshot.metadata.isFromCache);
}

class _DocumentReferenceImpl extends DocumentReference {
  final fs.DocumentReference<DynamicMap> _documentReference;

  _DocumentReferenceImpl(this._documentReference);

  @override
  CollectionReference collection(String collectionPath) {
    return _CollectionReferenceImpl(
        _documentReference.collection(collectionPath));
  }

  @override
  Future<void> delete() {
    return _documentReference.delete();
  }

  @override
  Future<DocumentSnapshot> get() async {
    return _DocumentSnapshotImpl(await _documentReference.get());
  }

  @override
  Future<DocumentSnapshot> get document async {
    return _DocumentSnapshotImpl(await _documentReference.get());
  }

  @override
  String get documentID => _documentReference.id;

  @override
  String get path => _documentReference.path;

  @override
  Future<void> set(Map<String, dynamic> data, {bool merge = false}) {
    return _documentReference.set(
        _dataWrapper.unwrapMap(data), fs.SetOptions(merge: true));
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    return _documentReference
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((snapshot) => _DocumentSnapshotImpl(snapshot));
  }

  @override
  Future<void> update(Map<String, dynamic> data) {
    return _documentReference.update(_dataWrapper.unwrapMap(data));
  }

  @override
  CollectionReference get parent {
    return _CollectionReferenceImpl(_documentReference.parent);
  }
}

class _CollectionReferenceImpl extends _QueryImpl
    implements CollectionReference {
  final fs.CollectionReference<DynamicMap> _collectionReference;

  _CollectionReferenceImpl(this._collectionReference)
      : super(_collectionReference);

  @override
  Future<DocumentReference> add(Map<String, dynamic> document) async {
    return _DocumentReferenceImpl(
        await _collectionReference.add(_dataWrapper.unwrapMap(document)));
  }

  @override
  DocumentReference doc([String? path]) {
    return _DocumentReferenceImpl(_collectionReference.doc(path));
  }

  @override
  DocumentReference? get parent {
    return _collectionReference.parent == null
        ? null
        : _DocumentReferenceImpl(_collectionReference.parent!);
  }
}

fs.Source _remapSource(Source source) {
  switch (source) {
    case Source.serverAndCache:
      return fs.Source.serverAndCache;
    case Source.cache:
      return fs.Source.cache;
    case Source.server:
      return fs.Source.server;
  }
}

fs.AggregateSource _remapAggregateSource(AggregateSource source) {
  switch (source) {
    case AggregateSource.server:
      return fs.AggregateSource.server;
  }
}

class _QueryImpl extends Query {
  final fs.Query<DynamicMap> _query;

  _QueryImpl(this._query);

  @override
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    return _QuerySnapshotImpl(
        await _query.get(fs.GetOptions(source: _remapSource(source))));
  }

  @override
  Query limit(int length) {
    return _QueryImpl(_query.limit(length));
  }

  @override
  Query orderBy(String field, {bool descending = false}) {
    return _QueryImpl(_query.orderBy(field, descending: descending));
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    return _query
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((snapshot) => _QuerySnapshotImpl(snapshot));
  }

  @override
  Query where(String field,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      whereIn,
      whereNotIn,
      arrayContainsAny,
      arrayContains,
      isNull}) {
    return _QueryImpl(
      _query.where(
        field,
        isEqualTo: isEqualTo == null
            // ignore: invalid_use_of_internal_member
            ? fs.notSetQueryParam
            : _dataWrapper.unwrapValue(isEqualTo),
        isGreaterThan: _dataWrapper.unwrapValue(isGreaterThan),
        isGreaterThanOrEqualTo:
            _dataWrapper.unwrapValue(isGreaterThanOrEqualTo),
        isLessThan: _dataWrapper.unwrapValue(isLessThan),
        isLessThanOrEqualTo: _dataWrapper.unwrapValue(isLessThanOrEqualTo),
        isNull: _dataWrapper.unwrapValue(isNull),
        arrayContains: _dataWrapper.unwrapValue(arrayContains),
        whereIn: _dataWrapper.unwrapList(whereIn),
        whereNotIn: _dataWrapper.unwrapList(whereNotIn),
        arrayContainsAny: _dataWrapper.unwrapList(arrayContainsAny),
      ),
    );
  }

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.endAtDocument(
        (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.endBeforeDocument(
        (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.startAfterDocument(
        (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.startAtDocument(
        (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query endAt(List<dynamic> values) {
    return _QueryImpl(_query.endAt(_dataWrapper.unwrapValue(values)));
  }

  @override
  Query endBefore(List<dynamic> values) {
    return _QueryImpl(_query.endBefore(_dataWrapper.unwrapValue(values)));
  }

  @override
  Query startAfter(List<dynamic> values) {
    return _QueryImpl(_query.startAfter(_dataWrapper.unwrapValue(values)));
  }

  @override
  Query startAt(List<dynamic> values) {
    return _QueryImpl(_query.startAt(_dataWrapper.unwrapValue(values)));
  }

  @override
  AggregateQuery count() {
    return _AggregateQueryImpl(_query.count());
  }
}

class _AggregateQueryImpl extends AggregateQuery {
  final fs.AggregateQuery _aggregateQuery;

  _AggregateQueryImpl(this._aggregateQuery);

  @override
  Future<AggregateQuerySnapshot> get(
      {AggregateSource source = AggregateSource.server}) async {
    fs.AggregateQuerySnapshot snapshot =
        await _aggregateQuery.get(source: _remapAggregateSource(source));
    return AggregateQuerySnapshot(snapshot.count);
  }
}

class _WriteBatch extends WriteBatch {
  final fs.WriteBatch _writeBatch;

  _WriteBatch(this._writeBatch);

  @override
  Future<void> commit() {
    return _writeBatch.commit();
  }

  @override
  void delete(DocumentReference document) {
    _writeBatch.delete((document as _DocumentReferenceImpl)._documentReference);
  }

  @override
  void set(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    _writeBatch.set((document as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data), fs.SetOptions(merge: merge));
  }

  @override
  void update(DocumentReference document, Map<String, dynamic> data) {
    _writeBatch.update((document as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data));
  }
}

class _Transaction extends Transaction {
  final fs.Transaction _transaction;

  _Transaction(this._transaction);

  @override
  Future<void> delete(DocumentReference documentReference) async {
    _transaction.delete(
        (documentReference as _DocumentReferenceImpl)._documentReference);
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    fs.DocumentSnapshot<DynamicMap> snapshot = await _transaction
        .get((documentReference as _DocumentReferenceImpl)._documentReference);
    return _DocumentSnapshotImpl(snapshot);
  }

  @override
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    await _transaction.set(
        (documentReference as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data));
  }

  @override
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    await _transaction.update(
        (documentReference as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data));
  }
}

class FirestoreImpl extends Firestore {
  final fs.FirebaseFirestore _firestore;

  FirestoreImpl._(this._firestore);

  static Firestore instance = FirestoreImpl._(fs.FirebaseFirestore.instance);

  fs.FirebaseFirestore get firebaseFirestore => _firestore;

  factory FirestoreImpl.fromInstance(fs.FirebaseFirestore instance) =>
      FirestoreImpl._(instance);

  @override
  WriteBatch batch() {
    return _WriteBatch(_firestore.batch());
  }

  @override
  CollectionReference collection(String path) {
    return _CollectionReferenceImpl(_firestore.collection(path));
  }

  @override
  DocumentReference doc(String path) {
    return _DocumentReferenceImpl(_firestore.doc(path));
  }

  @override
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return _firestore.runTransaction<T>((fs.Transaction transaction) {
      return transactionHandler(_Transaction(transaction));
    }, timeout: timeout);
  }

  @override
  Query collectionGroup(String path) {
    return _QueryImpl(_firestore.collectionGroup(path));
  }

  @override
  Future<void> waitForPendingWrites() {
    return _firestore.waitForPendingWrites();
  }
}

useFirestoreEmulator(FirebaseApp app, String host, int port) {
  fs.FirebaseFirestore firestore = fs.FirebaseFirestore.instanceFor(app: app);
  firestore.useFirestoreEmulator(host, port);
}
