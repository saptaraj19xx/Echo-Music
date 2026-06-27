import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore adapter hiding Firebase/collections from repositories.
class FirestoreAdapter {
  FirestoreAdapter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Basic document read helper.
  Future<Map<String, dynamic>?> getDoc(
    String collectionPath,
    String docId,
  ) async {
    final snap = await _firestore.collection(collectionPath).doc(docId).get();
    return snap.data();
  }

  /// Read all documents in a collection.
  ///
  /// Phase 3A uses this to fetch Songs/Albums/Artists/Playlists/Genres.
  Future<List<Map<String, dynamic>>> getCollection(
    String collectionPath,
  ) async {
    final querySnap = await _firestore.collection(collectionPath).get();
    return querySnap.docs.map((d) => d.data()).toList();
  }

  /// Best-effort list query for Phase 3A.
  ///
  /// NOTE: We keep this minimal so repositories can remain interface-stable
  /// and avoid schema coupling.
  Future<List<Map<String, dynamic>>> queryCollection(
    String collectionPath, {
    required String field,
    required Object value,
  }) async {
    final querySnap = await _firestore
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .get();
    return querySnap.docs.map((d) => d.data()).toList();
  }
}


