import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firestore operations
/// This service provides CRUD operations for various collections in Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String membersCollection = 'members';
  static const String consentsCollection = 'consents';
  static const String hraScreeningsCollection = 'hra_screenings';
  static const String hivScreeningsCollection = 'hiv_screenings';
  static const String hivResultsCollection = 'hiv_results';
  static const String tbScreeningsCollection = 'tb_screenings';
  static const String cancerScreeningsCollection = 'cancer_screenings';

  /// Create a document in a collection
  Future<void> createDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
      debugPrint('Document created in $collection: $documentId');
    } catch (e, stackTrace) {
      debugPrint('Error creating document: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Read a document from a collection
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    } catch (e, stackTrace) {
      debugPrint('Error reading document: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update a document in a collection
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
      debugPrint('Document updated in $collection: $documentId');
    } catch (e, stackTrace) {
      debugPrint('Error updating document: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a document from a collection
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      debugPrint('Document deleted from $collection: $documentId');
    } catch (e, stackTrace) {
      debugPrint('Error deleting document: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get all documents from a collection
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    try {
      CollectionReference<Map<String, dynamic>> collectionRef =
          _firestore.collection(collection);

      Query<Map<String, dynamic>> query =
          queryBuilder != null ? queryBuilder(collectionRef)! : collectionRef;

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error getting collection: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stream a collection for real-time updates
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>>? Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    try {
      CollectionReference<Map<String, dynamic>> collectionRef =
          _firestore.collection(collection);

      Query<Map<String, dynamic>> query =
          queryBuilder != null ? queryBuilder(collectionRef)! : collectionRef;

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e, stackTrace) {
      debugPrint('Error streaming collection: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stream a single document for real-time updates
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    try {
      return _firestore
          .collection(collection)
          .doc(documentId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data();
        if (data != null) {
          data['id'] = doc.id;
        }
        return data;
      });
    } catch (e, stackTrace) {
      debugPrint('Error streaming document: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Query documents with a where clause
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: isEqualTo)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error querying documents: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Batch write operations
  Future<void> batchWrite(
    Future<void> Function(WriteBatch batch) operations,
  ) async {
    try {
      final batch = _firestore.batch();
      await operations(batch);
      await batch.commit();
      debugPrint('Batch write completed');
    } catch (e, stackTrace) {
      debugPrint('Error in batch write: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a reference to a collection
  CollectionReference<Map<String, dynamic>> getCollectionReference(
      String collection) {
    return _firestore.collection(collection);
  }

  /// Get a reference to a document
  DocumentReference<Map<String, dynamic>> getDocumentReference({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId);
  }
}
