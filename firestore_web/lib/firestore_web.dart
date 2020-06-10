library firestore_web;

import 'package:firebase/firestore.dart' as fs;
import 'package:firestore_api/firestore_api.dart';
import 'dart:async';

class DataWrapperImpl extends DataWrapper {
  @override
  dynamic wrapValue(dynamic value) {
    if (value is fs.DocumentReference) {
      return _DocumentReferenceImpl(value);
    } else if (value is Map) {
      return wrapMap(Map.castFrom(value));
    } else if (value is List) {
      return wrapList(List.castFrom(value));
    } else if (value is fs.Blob) {
      return Blob(value.toUint8Array());
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
      return unwrapMap(value);
    } else if (value is List) {
      return unwrapList(value);
    } else if (value is Blob) {
      return fs.Blob.fromUint8Array(value.bytes);
    } else {
      return value;
    }
  }

  @override
  unwrapFieldValue(FieldValue fieldValue) {
    switch (fieldValue.type) {
      case FieldValueType.increment:
        return fs.FieldValue.increment(fieldValue.value);
      case FieldValueType.delete:
        return fs.FieldValue.delete();
      case FieldValueType.serverTimestamp:
        return fs.FieldValue.serverTimestamp();
      case FieldValueType.arrayRemove:
        return fs.FieldValue.arrayRemove(unwrapList(fieldValue.value));
      case FieldValueType.arrayUnion:
        return fs.FieldValue.arrayUnion(unwrapList(fieldValue.value));
    }
    throw Exception("unknown field value type $fieldValue");
  }
}

final DataWrapper _dataWrapper = DataWrapperImpl();

class _DocumentSnapshotImpl extends DocumentSnapshot {
  final fs.DocumentSnapshot _documentSnapshot;

  _DocumentSnapshotImpl(this._documentSnapshot);

  @override
  Map<String, dynamic> get data {
    return _dataWrapper.wrapMap(_documentSnapshot.data());
  }

  @override
  String get documentID => _documentSnapshot.id;

  @override
  bool get exists => _documentSnapshot.exists;

  @override
  DocumentReference get ref => _DocumentReferenceImpl(_documentSnapshot.ref);

  @override
  DocumentReference get reference =>
      _DocumentReferenceImpl(_documentSnapshot.ref);

  @override
  SnapshotMetadata get metadata => SnapshotMetadata(
      _documentSnapshot.metadata.hasPendingWrites,
      _documentSnapshot.metadata.fromCache);
}

class _DocumentChangeImpl extends DocumentChange {
  final fs.DocumentChange _documentChange;

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
      case "added":
        return DocumentChangeType.added;
      case "modified":
        return DocumentChangeType.modified;
      case "removed":
        return DocumentChangeType.removed;
    }
    throw Exception("Unknown type ${_documentChange.type}");
  }
}

class _QuerySnapshotImpl extends QuerySnapshot {
  final fs.QuerySnapshot _querySnapshot;

  _QuerySnapshotImpl(this._querySnapshot);

  @override
  List<DocumentChange> get documentChanges => _querySnapshot
      .docChanges()
      .map((docChange) => _DocumentChangeImpl(docChange))
      .toList();

  @override
  List<DocumentSnapshot> get documents => _querySnapshot.docs
      .map((snapshot) => _DocumentSnapshotImpl(snapshot))
      .toList();

  @override
  bool get empty => _querySnapshot.empty;

  @override
  void forEach(onEach) {
    _querySnapshot.docs.forEach((snapshot) {
      onEach(_DocumentSnapshotImpl(snapshot));
    });
  }

  @override
  SnapshotMetadata get metadata => SnapshotMetadata(
      _querySnapshot.metadata.hasPendingWrites,
      _querySnapshot.metadata.fromCache);
}

class _DocumentReferenceImpl extends DocumentReference {
  final fs.DocumentReference _documentReference;

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
  Future<DocumentSnapshot> get document async {
    return _DocumentSnapshotImpl(await _documentReference.get());
  }

  @override
  String get documentID => _documentReference.id;

  @override
  String get path => _documentReference.path;

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _documentReference.set(
        _dataWrapper.unwrapMap(data), fs.SetOptions(merge: merge));
  }

  @override
  Stream<DocumentSnapshot> get snapshots {
    return _documentReference.onSnapshot
        .map((snapshot) => _DocumentSnapshotImpl(snapshot));
  }

  @override
  Future<void> update(Map<String, dynamic> data) {
    return _documentReference.update(data: _dataWrapper.unwrapMap(data));
  }

  @override
  CollectionReference get parent =>
      _CollectionReferenceImpl(_documentReference.parent);
}

class _CollectionReferenceImpl extends _QueryImpl
    implements CollectionReference {
  final fs.CollectionReference _collectionReference;

  _CollectionReferenceImpl(this._collectionReference)
      : super(_collectionReference);

  @override
  Future<DocumentReference> add(Map<String, dynamic> document) async {
    return _DocumentReferenceImpl(
        await _collectionReference.add(_dataWrapper.unwrapMap(document)));
  }

  @override
  DocumentReference document([String path]) {
    return _DocumentReferenceImpl(_collectionReference.doc(path));
  }

  @override
  DocumentReference get parent =>
      _DocumentReferenceImpl(_collectionReference.parent);
}

class _QueryImpl extends Query {
  final fs.Query _query;

  _QueryImpl(this._query);

  @override
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    if (source != Source.serverAndCache) {
      throw Exception("only serverAndCache as Source supported at the moment");
    }
    return _QuerySnapshotImpl(await _query.get());
  }

  @override
  Query limit(int length) {
    return _QueryImpl(_query.limit(length));
  }

  @override
  Query orderBy(String field, {bool descending = false}) {
    return _QueryImpl(_query.orderBy(field, descending ? "desc" : null));
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    return includeMetadataChanges
        ? _query.onSnapshotMetadata
            .map((snapshot) => _QuerySnapshotImpl(snapshot))
        : _query.onSnapshot.map((snapshot) => _QuerySnapshotImpl(snapshot));
  }

  @override
  Query where(String field,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      bool isNull}) {
    String compareOperator = "";
    var value = null;
    if (isEqualTo != null) {
      compareOperator = "==";
      value = isEqualTo;
    } else if (isLessThan != null) {
      compareOperator = "<";
      value = isLessThan;
    } else if (isLessThanOrEqualTo != null) {
      compareOperator = "<=";
      value = isLessThanOrEqualTo;
    } else if (isGreaterThan != null) {
      compareOperator = ">";
      value = isGreaterThan;
    } else if (isGreaterThanOrEqualTo != null) {
      compareOperator = ">=";
      value = isGreaterThanOrEqualTo;
    } else if (arrayContains != null) {
      compareOperator = "array-contains";
      value = arrayContains;
    }
    if (compareOperator.isEmpty) {
      return this;
    }
    value = _dataWrapper.unwrapValue(value);
    return _QueryImpl(_query.where(field, compareOperator, value));
  }

  @override
  Query endAt(List values) {
    return _QueryImpl(
        _query.endAt(fieldValues: _dataWrapper.unwrapList(values)));
  }

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.endAt(
        snapshot:
            (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query endBefore(List values) {
    return _QueryImpl(
        _query.endBefore(fieldValues: _dataWrapper.unwrapList(values)));
  }

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.endBefore(
        snapshot:
            (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query startAfter(List values) {
    return _QueryImpl(
        _query.startAfter(fieldValues: _dataWrapper.unwrapList(values)));
  }

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.startAfter(
        snapshot:
            (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
  }

  @override
  Query startAt(List values) {
    return _QueryImpl(
        _query.startAt(fieldValues: _dataWrapper.unwrapList(values)));
  }

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    return _QueryImpl(_query.startAt(
        snapshot:
            (documentSnapshot as _DocumentSnapshotImpl)._documentSnapshot));
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
  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    _writeBatch.set((document as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data), fs.SetOptions(merge: merge));
  }

  @override
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    _writeBatch.update((document as _DocumentReferenceImpl)._documentReference,
        data: _dataWrapper.unwrapMap(data));
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
    fs.DocumentSnapshot snapshot = await _transaction
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
        data: _dataWrapper.unwrapMap(data));
  }
}

class FirestoreImpl extends Firestore {
  final fs.Firestore _firestore;

  FirestoreImpl(this._firestore);

  @override
  WriteBatch batch() {
    return _WriteBatch(_firestore.batch());
  }

  @override
  CollectionReference collection(String path) {
    return _CollectionReferenceImpl(_firestore.collection(path));
  }

  @override
  DocumentReference document(String path) {
    return _DocumentReferenceImpl(_firestore.doc(path));
  }

  @override
  Future<Map<String, dynamic>> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    Map<String, dynamic> result = Map.castFrom(
        await _firestore.runTransaction((fs.Transaction transaction) {
      return transactionHandler(_Transaction(transaction));
    }));
    return result;
  }

  @override
  Query collectionGroup(String path) {
    return _QueryImpl(_firestore.collectionGroup(path));
  }
}
