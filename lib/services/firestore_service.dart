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
}
