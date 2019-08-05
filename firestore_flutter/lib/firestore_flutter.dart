import 'dart:typed_data';

import 'package:firestore_api/firestore_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
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
    } else if (value == FieldValue.DELETE) {
      return fs.FieldValue.delete();
    } else if (value == FieldValue.SERVER_TIMESTAMP) {
      return fs.FieldValue.serverTimestamp();
    } else if (value is Map) {
      return unwrapMap(value);
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
}

final DataWrapper _dataWrapper = DataWrapperImpl();

class _BlobImpl extends Blob {
  _BlobImpl(Uint8List l) : super(l);
}

class _DocumentSnapshotImpl extends DocumentSnapshot {
  final fs.DocumentSnapshot _documentSnapshot;

  _DocumentSnapshotImpl(this._documentSnapshot);

  @override
  Map<String, dynamic> get data {
    return _dataWrapper.wrapMap(_documentSnapshot.data);
  }

  @override
  String get documentID => _documentSnapshot.documentID;

  @override
  bool get exists => _documentSnapshot.exists;

  @override
  DocumentReference get ref =>
      _DocumentReferenceImpl(_documentSnapshot.reference);

  @override
  DocumentReference get reference =>
      _DocumentReferenceImpl(_documentSnapshot.reference);
}

class _DocumentChangeImpl extends DocumentChange {
  final fs.DocumentChange _documentChange;

  _DocumentChangeImpl(this._documentChange);

  @override
  DocumentSnapshot get document =>
      _DocumentSnapshotImpl(_documentChange.document);

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
    throw Exception("Unknown type ${_documentChange.type}");
  }
}

class _QuerySnapshotImpl extends QuerySnapshot {
  final fs.QuerySnapshot _querySnapshot;

  _QuerySnapshotImpl(this._querySnapshot);

  @override
  List<DocumentChange> get documentChanges => _querySnapshot.documentChanges
      .map((docChange) => _DocumentChangeImpl(docChange))
      .toList();

  @override
  List<DocumentSnapshot> get documents => _querySnapshot.documents
      .map((snapshot) => _DocumentSnapshotImpl(snapshot))
      .toList();

  @override
  bool get empty => _querySnapshot.documents.isEmpty;

  @override
  void forEach(onEach) {
    _querySnapshot.documents.forEach((snapshot) {
      onEach(_DocumentSnapshotImpl(snapshot));
    });
  }
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
  String get documentID => _documentReference.documentID;

  @override
  String get path => _documentReference.path;

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _documentReference.setData(_dataWrapper.unwrapMap(data),
        merge: merge);
  }

  @override
  Stream<DocumentSnapshot> get snapshots {
    return _documentReference
        .snapshots()
        .map((snapshot) => _DocumentSnapshotImpl(snapshot));
  }

  @override
  Future<void> update(Map<String, dynamic> data) {
    return _documentReference.updateData(_dataWrapper.unwrapMap(data));
  }

  @override
  CollectionReference get parent {
    throw Exception(
        "not implemented yet"); // see https://github.com/flutter/flutter/issues/30103
  }
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
    return _DocumentReferenceImpl(_collectionReference.document(path));
  }

  @override
  DocumentReference get parent {
    throw Exception(
        "not implemented yet"); // see https://github.com/flutter/flutter/issues/30103
  }
}

class _QueryImpl extends Query {
  final fs.Query _query;

  _QueryImpl(this._query);

  @override
  Future<QuerySnapshot> getDocuments() async {
    return _QuerySnapshotImpl(await _query.getDocuments());
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
  Stream<QuerySnapshot> snapshots() {
    return _query.snapshots().map((snapshot) => _QuerySnapshotImpl(snapshot));
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
    return _QueryImpl(_query.where(field,
        isEqualTo: _dataWrapper.unwrapValue(isEqualTo),
        isGreaterThan: _dataWrapper.unwrapValue(isGreaterThan),
        isGreaterThanOrEqualTo:
            _dataWrapper.unwrapValue(isGreaterThanOrEqualTo),
        isLessThan: _dataWrapper.unwrapValue(isLessThan),
        isLessThanOrEqualTo: _dataWrapper.unwrapValue(isLessThanOrEqualTo),
        isNull: _dataWrapper.unwrapValue(isNull),
        arrayContains: _dataWrapper.unwrapValue(arrayContains)));
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
    _writeBatch.setData((document as _DocumentReferenceImpl)._documentReference,
        _dataWrapper.unwrapMap(data),
        merge: merge);
  }

  @override
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    _writeBatch.updateData(
        (document as _DocumentReferenceImpl)._documentReference,
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
        _dataWrapper.unwrapMap(data));
  }
}

class FirestoreImpl extends Firestore {
  final fs.Firestore _firestore = fs.Firestore.instance;

  static Firestore instance = FirestoreImpl();

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
    return _DocumentReferenceImpl(_firestore.document(path));
  }

  @override
  Future<void> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return _firestore.runTransaction((fs.Transaction transaction) {
      return transactionHandler(_Transaction(transaction));
    }, timeout: timeout);
  }
}
