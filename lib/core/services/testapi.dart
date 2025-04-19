import 'dart:async';

/// A class that provides methods to interact with the Firestore database for test data.
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;


class TestApi {
  final Databases _db;
  final String databaseId;
  final String collectionId;

  /// [collectionId] - Appwrite collection where tests are stored.
  TestApi({
    required this.databaseId,
    required this.collectionId,
    required Databases databaseInstance,
  }) : _db = databaseInstance;

  /// Fetch all test documents in the collection
  Future<List<models.Document>> getDataCollection() async {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
    return response.documents;
  }

  /// Stream tests for a mother
  Stream<List<models.Document>> streamTestsByMother(String? motherId) async* {
    final result = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal('motherId', motherId),
        Query.orderAsc('createdOn'),
      ],
    );
    yield result.documents;
  }

  /// Stream BabyBeat tests for a mother
  Stream<List<models.Document>> streamTestsByMotherBabyBeat(String? motherId) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: 'BabyBeat', // Replace with actual BabyBeat collection ID
      queries: [
        Query.equal('motherId', motherId),
        Query.orderAsc('createdOn'),
      ],
    );
    yield response.documents;
  }

  /// Stream all tests for an organization
  Stream<List<models.Document>> streamTestsByOrganization(String? orgId) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.orderDesc('createdOn'),
        Query.limit(30),
      ],
    );
    yield response.documents;
  }

  /// Stream BabyBeat tests for organization and doctor
  Stream<List<models.Document>> streamTestsByOrganizationBabyBeat(String? orgId, String? docId) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: 'BabyBeat', // Replace with actual BabyBeat collection ID
      queries: [
        Query.equal('association.babybeat_org.documentId', orgId),
        Query.equal('association.babybeat_doctor.documentId', docId),
        Query.orderDesc('createdOn'),
        Query.limit(30),
      ],
    );
    yield response.documents;
  }

  /// Stream all BabyBeat tests for a doctor
  Stream<List<models.Document>> streamTestsByDoctorBabyBeatAll(String? docId) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: 'BabyBeat',
      queries: [
        Query.equal('association.babybeat_doctor.documentId', docId),
        Query.orderDesc('createdOn'),
        Query.limit(30),
      ],
    );
    yield response.documents;
  }

  /// Stream tests for a specific organization
  Stream<List<models.Document>> streamTestsByOrganizationOnly(String orgId) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.orderDesc('createdOn'),
        Query.limit(30),
      ],
    );
    yield response.documents;
  }

  /// Stream tests for TV view
  Stream<List<models.Document>> streamTestsByOrganizationForTV(String? orgId, int limit) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.orderDesc('createdOn'),
        Query.limit(limit),
      ],
    );
    yield response.documents;
  }

  /// Stream tests for TV view (org-specific)
  Stream<List<models.Document>> streamTestsByOrganizationOnlyForTV(String? orgId, int limit) async* {
    final response = await _db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [
        Query.equal('organizationId', orgId),
        Query.orderDesc('createdOn'),
        Query.limit(limit),
      ],
    );
    yield response.documents;
  }

  /// Fetch test by ID
  Future<models.Document> getDocumentById(String id) async {
    return await _db.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: id,
    );
  }

  /// Remove test by ID
  Future<void> removeDocument(String id) async {
    await _db.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: id,
    );
  }

  /// Add a test
  Future<models.Document> addDocument(Map<String, dynamic> data) async {
    return await _db.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
    );
  }

  /// Update a test
  Future<void> updateDocument(String id, Map<String, dynamic> data) async {
    await _db.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: id,
      data: data,
    );
  }
}


