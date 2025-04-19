import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

/// A class that provides methods to interact with the Firestore database for notifications.
class AppwriteNotificationApi {
  final Databases _db;
  final String databaseId;
  final String collectionId;

  AppwriteNotificationApi({
    required Databases db,
    required this.databaseId,
    required this.collectionId,
  }) : _db = db;

  /// Fetches all documents in the collection.
  Future<DocumentList> getDataCollection() async {
    return await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
  }

  /// Simulates streaming documents for a user.
  /// You can set up Appwrite Realtime or poll this periodically.
  Future<DocumentList> streamDataCollection(String? userId) async {
    return await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("userId", userId),
        Query.equal("isShownInList", true),
        Query.orderDesc("createdAt"),
        Query.limit(20),
      ],
    );
  }

  /// Gets a document by its ID
  Future<Document> getDocumentById(String documentId) async {
    return await _db.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  /// Deletes a document by its ID
  Future<void> removeDocument(String documentId) async {
    await _db.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  /// Adds a new document
  Future<Document> addDocument(Map<String, dynamic> data) async {
    return await _db.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
    );
  }

  /// Updates a document's read status
  Future<void> updateDocument(bool isRead, String? documentId) async {
    await _db.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId!,
      data: {
        "isRead": isRead,
      },
    );
  }
}

