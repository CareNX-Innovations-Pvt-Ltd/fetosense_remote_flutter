import 'dart:async';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/services/testapi.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';

/// [TestCRUDModel] is a ChangeNotifier class that provides methods to interact with test data in Firestore.

class TestCRUDModel extends ChangeNotifier {
  /// Appwrite API instance for test-related operations
  final TestApi _api = locator<TestApi>();

  /// Cached list of test records
  List<Test>? tests;

  /// Fetch all tests (optional caching)
  Future<List<Test>?> fetchTests() async {
    final result = await _api.getDataCollection();
    tests = result.map((doc) => Test.fromMap(doc.data, doc.$id)).toList();
    return tests;
  }

  /// Stream tests for a specific mother
  Stream<List<Test>> fetchTestsAsStream(String? motherId) {
    return _api.streamTestsByMother(motherId).map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream BabyBeat tests for a specific mother
  Stream<List<Test>> fetchTestsAsStreamBabyBeat(String? motherId) {
    return _api.streamTestsByMotherBabyBeat(motherId).map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream all tests for a specific organization
  Stream<List<Test>> fetchAllTestsAsStream(String? orgId) {
    return _api.streamTestsByOrganization(orgId).map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream all BabyBeat tests for an organization and doctor
  Stream<List<Test>> fetchAllTestsAsStreamBabyBeat(
      String? orgId, String? docId) {
    return _api
        .streamTestsByOrganizationBabyBeat(orgId, docId)
        .map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream all BabyBeat tests for a doctor
  Stream<List<Test>> fetchAllTestsAsStreamBabyBeatAll(String? docId) {
    return _api.streamTestsByDoctorBabyBeatAll(docId).map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream org-specific tests
  Stream<List<Test>> fetchAllTestsAsStreamOrg(String orgId) {
    return _api.streamTestsByOrganizationOnly(orgId).map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream limited org tests for TV
  Stream<List<Test>> fetchAllTestsAsStreamForTV(String? orgId, int limit) {
    return _api
        .streamTestsByOrganizationForTV(orgId, limit)
        .map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Stream limited org-specific tests for TV
  Stream<List<Test>> fetchAllTestsAsStreamOrgForTV(String? orgId, int limit) {
    return _api
        .streamTestsByOrganizationOnlyForTV(orgId, limit)
        .map((docs) =>
        docs.map((doc) => Test.fromMap(doc.data, doc.$id)).toList());
  }

  /// Fetch a single test by ID
  Future<Test> getTestById(String id) async {
    final doc = await _api.getDocumentById(id);
    return Test.fromMap(doc.data, doc.$id);
  }

  /// Delete a test
  Future<void> removeTest(String id) async {
    await _api.removeDocument(id);
  }

  /// Optional: Update a test
  Future<void> updateTest(Test test, String id) async {
    await _api.updateDocument(id, test.toJson());
  }
}

