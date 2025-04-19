import 'dart:async';

/// A class that implements the [BaseAuth] interface using Firebase Authentication.
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteApi {
  final Databases database;
  final String databaseId;
  final String collectionId;

  AppwriteApi({
    required this.database,
    required this.databaseId,
    required this.collectionId,
  });

  Future<List<models.Document>> getDataCollection() async {
    final result = await database.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
    return result.documents;
  }

  Stream<List<models.Document>> streamMotherData(String organizationId) {
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("type", "mother"),
        Query.equal("organizationId", organizationId),
        Query.orderDesc("createdOn")
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Stream<List<models.Document>> streamActiveMotherData(String organizationId) {
    final daysAgo = DateTime.now().subtract(const Duration(days: 30)).toUtc().toIso8601String();
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("type", "mother"),
        Query.equal("organizationId", organizationId),
        Query.greaterThanEqual("edd", daysAgo),
        Query.orderAsc("edd")
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Stream<List<models.Document>> streamMotherDataSearch(String organizationId, String filter) {
    final nextChar = String.fromCharCode(filter.codeUnitAt(0) + 1);
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("type", "mother"),
        Query.equal("organizationId", organizationId),
        Query.orderAsc("name"),
        Query.startsWith("name", filter),
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Future<models.Document> getDocumentById(String documentId) async {
    return await database.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Stream<List<models.Document>> streamDocumentByEmailId(String email) {
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("type", "doctor"),
        Query.equal("email", email),
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Stream<List<models.Document>> streamDocumentByMobile(String mobileNo) {
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal("type", "doctor"),
        Query.equal("mobileNo", mobileNo),
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Future<void> removeDocument(String documentId) async {
    await database.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<models.Document> addDocument(Map<String, dynamic> data) async {
    return await database.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
    );
  }

  Future<models.Document> updateDocument(String documentId, Map<String, dynamic> data) async {
    return await database.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Stream<List<models.Document>> getUser(String phoneNo) {
    return database
        .listDocuments(
      databaseId: databaseId,
      collectionId: 'users', // use appropriate collection
      queries: [
        Query.equal("mobileNo", phoneNo),
      ],
    )
        .asStream()
        .map((r) => r.documents);
  }

  Future<bool> isNewUser(String phoneNo) async {
    final result = await database.listDocuments(
      databaseId: databaseId,
      collectionId: 'users',
      queries: [
        Query.equal("mobileNo", phoneNo),
        Query.equal("type", "doctor"),
      ],
    );
    return result.documents.isEmpty;
  }
}
