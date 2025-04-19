import 'dart:async';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/user_model.dart';
import 'package:fetosense_remote_flutter/core/services/appwrite_api.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:appwrite/models.dart' as models;

/// [CRUDModel] is a ChangeNotifier class that provides methods to interact with the mother, doctor, and user data.
/// It fetches, updates, and removes data from the Firestore database.
class CRUDModel with ChangeNotifier {
  final AppwriteApi _api = locator<AppwriteApi>();

  List<Mother>? mothers;

  /// Fetch all mothers
  Future<List<Mother>?> fetchProducts() async {
    var result = await _api.getDataCollection();
    mothers = result.map((doc) {
      return Mother.fromMap(doc.data, doc.$id);
    }).toList();
    return mothers;
  }

  /// Stream mothers by organizationId
  Stream<List<Mother>> fetchMothersAsStream(String organizationId) {
    return _api.streamMotherData(organizationId).map((documents) {
      return documents.map((doc) => Mother.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Stream searched mothers by name
  Stream<List<Mother>> fetchMothersAsStreamSearch(
      String organizationId, String start) {
    return _api.streamMotherDataSearch(organizationId, start).map((documents) {
      return documents.map((doc) => Mother.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Stream active mothers
  Stream<List<Mother>> fetchActiveMothersAsStream(String organizationId) {
    return _api.streamActiveMotherData(organizationId).map((documents) {
      return documents.map((doc) => Mother.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Search and map to model list
  Stream<List<Mother>> fetchMothersAsStreamSearchMothers(
      String organizationId, String start) {
    return _api.streamMotherDataSearch(organizationId, start).map((documents) {
      return documents.map((doc) => Mother.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Get doctor by document ID
  Future<Doctor> getDoctorById(String id) async {
    final doc = await _api.getDocumentById(id);
    return Doctor.fromMap(doc.data, doc.$id);
  }

  /// Stream doctor by email
  Stream<List<Doctor>> fetchDoctorByEmailId(String id) {
    return _api.streamDocumentByEmailId(id).map((docs) {
      return docs.map((doc) => Doctor.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Stream doctor by mobile number
  Stream<List<Doctor>> fetchDoctorByMobile(String id) {
    return _api.streamDocumentByMobile(id).map((docs) {
      return docs.map((doc) => Doctor.fromMap(doc.data, doc.$id)).toList();
    });
  }

  /// Get user by document ID
  Future<UserModel> getUserById(String id) async {
    final doc = await _api.getDocumentById(id);
    return UserModel.fromMap(doc.data, doc.$id);
  }

  /// Delete document
  Future<void> removeProduct(String id) async {
    await _api.removeDocument(id);
  }

  /// Update document
  Future<void> updateProduct(Mother data, String id) async {
    await _api.updateDocument(data.documentId!, data.toJson(), );
  }

  /// Add document
  Future<models.Document> addProduct(Mother data) async {
    return await _api.addDocument(data.toJson());
  }
}
