import 'package:cloud_firestore/cloud_firestore.dart';

// A general-purpose wrapper around Cloud Firestore: get a document, set a
// document, update a document, or query a collection where a field equals
// some value. Works with plain Maps only, it never builds a UserModel or
// any other domain model, and holds no app-specific rule. That work
// belongs in lib/repositories/, which calls this class.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(id).set(data);
  }

  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(id).update(data);
  }

  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String id,
  ) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String collection,
    String field,
    Object? isEqualTo,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Same idea as queryWhereOrdered, but with two equality filters. Needed
  // when a security rule checks a field the query itself isn't already
  // filtering on, Firestore rejects a list query unless its own filters
  // already prove every result satisfies the rule, see ChatRepository.
  Future<List<Map<String, dynamic>>> queryWhereTwo(
    String collection,
    String field1,
    Object? isEqualTo1,
    String field2,
    Object? isEqualTo2,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(field1, isEqualTo: isEqualTo1)
        .where(field2, isEqualTo: isEqualTo2)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data(), "id": doc.id})
        .toList();
  }

  // Adds a new document with a Firestore-generated id. Use this for
  // collections like bookings, reviews, and chats where nothing needs to
  // know the id before it's created. Also works for a subcollection, pass
  // a path like "chats/$chatId/messages" as the collection.
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final ref = await _firestore.collection(collection).add(data);
    return ref.id;
  }

  // Same as getDocument, but includes the document's own id under the
  // "id" key, since collections like bookings and payments don't store
  // their own id as a field the way users does with uid.
  Future<Map<String, dynamic>?> getDocumentWithId(
    String collection,
    String id,
  ) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return {...doc.data()!, "id": doc.id};
  }

  // Same idea as queryWhere, but includes each document's id, and can sort
  // by a field, for example bookings newest first. Use this instead of
  // queryWhere any time the caller needs the document's id or a sort order.
  Future<List<Map<String, dynamic>>> queryWhereOrdered(
    String collection,
    String field,
    Object? isEqualTo, {
    String? orderBy,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection).where(field, isEqualTo: isEqualTo);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => {...doc.data(), "id": doc.id})
        .toList();
  }

  // Every document in a collection, with no filter, for admin screens like
  // Manage Bookings that need to see everything rather than one person's.
  Future<List<Map<String, dynamic>>> getCollectionOrdered(
    String collection, {
    String? orderBy,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => {...doc.data(), "id": doc.id})
        .toList();
  }
}
