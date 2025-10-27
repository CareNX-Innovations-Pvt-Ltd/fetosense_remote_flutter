import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/user_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'package:fetosense_remote_flutter/core/services/appwrite_api.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/models.dart' as models;

import 'crud_view_model_test.mocks.dart';

@GenerateMocks([AppwriteApi])

void main() {
  late CRUDModel model;
  late MockAppwriteApi mockApi;

  setUpAll(() {
    // Reset GetIt instance
    if (GetIt.instance.isRegistered<AppwriteApi>()) {
      GetIt.instance.unregister<AppwriteApi>();
    }
  });

  setUp(() {
    mockApi = MockAppwriteApi();

    // Register mock with GetIt/locator
    GetIt.instance.registerSingleton<AppwriteApi>(mockApi);

    // Create model instance
    model = CRUDModel();
  });

  tearDown(() {
    model.dispose();
    GetIt.instance.reset();
  });

  group('CRUDModel', () {

    test('fetchProducts - should fetch and cache mothers', () async {
      // Arrange
      final doc1 = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Mother 1', 'age': 25},
      );
      final doc2 = models.Document(
        $id: 'id2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Mother 2', 'age': 30},
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => [doc1, doc2]);

      // Act
      final result = await model.fetchProducts();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(model.mothers, isNotNull);
      expect(model.mothers!.length, 2);
      verify(mockApi.getDataCollection()).called(1);
    });

    test('fetchProducts - should handle empty result', () async {
      // Arrange
      when(mockApi.getDataCollection()).thenAnswer((_) async => []);

      // Act
      final result = await model.fetchProducts();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 0);
      expect(model.mothers, isNotNull);
      expect(model.mothers!.length, 0);
      verify(mockApi.getDataCollection()).called(1);
    });

    test('fetchMothersAsStream - should return stream for organization', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Mother 1', 'age': 25},
      );

      when(mockApi.streamMotherData('org1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStream('org1');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamMotherData('org1')).called(1);
    });

    test('fetchMothersAsStream - should handle empty stream', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamMotherData('org2'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStream('org2');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamMotherData('org2')).called(1);
    });

    test('fetchMothersAsStreamSearch - should return search stream', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Mother Test', 'age': 25},
      );

      when(mockApi.streamMotherDataSearch('org1', 'Test'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStreamSearch('org1', 'Test');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamMotherDataSearch('org1', 'Test')).called(1);
    });

    test('fetchMothersAsStreamSearch - should handle empty search', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamMotherDataSearch('org1', ''))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStreamSearch('org1', '');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamMotherDataSearch('org1', '')).called(1);
    });

    test('fetchActiveMothersAsStream - should return active mothers stream', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Active Mother', 'age': 28, 'isActive': true},
      );

      when(mockApi.streamActiveMotherData('org1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchActiveMothersAsStream('org1');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamActiveMotherData('org1')).called(1);
    });

    test('fetchActiveMothersAsStream - should handle no active mothers', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamActiveMotherData('org2'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchActiveMothersAsStream('org2');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamActiveMotherData('org2')).called(1);
    });

    test('fetchMothersAsStreamSearchMothers - should return search stream', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Search Mother', 'age': 27},
      );

      when(mockApi.streamMotherDataSearch('org1', 'Search'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStreamSearchMothers('org1', 'Search');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamMotherDataSearch('org1', 'Search')).called(1);
    });

    test('fetchMothersAsStreamSearchMothers - should handle different search term', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamMotherDataSearch('org2', 'Another'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchMothersAsStreamSearchMothers('org2', 'Another');

      // Assert
      expect(stream, isA<Stream<List<Mother>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamMotherDataSearch('org2', 'Another')).called(1);
    });

    test('getDoctorById - should fetch single doctor', () async {
      // Arrange
      final doc = models.Document(
        $id: 'doc1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Dr. Smith', 'specialization': 'Gynecology'},
      );

      when(mockApi.getDocumentById('doc1')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getDoctorById('doc1');

      // Assert
      expect(result, isA<Doctor>());
      verify(mockApi.getDocumentById('doc1')).called(1);
    });

    test('getDoctorById - should handle different doctor id', () async {
      // Arrange
      final doc = models.Document(
        $id: 'doc2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Dr. Jones', 'specialization': 'Pediatrics'},
      );

      when(mockApi.getDocumentById('doc2')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getDoctorById('doc2');

      // Assert
      expect(result, isA<Doctor>());
      verify(mockApi.getDocumentById('doc2')).called(1);
    });

    test('fetchDoctorByEmailId - should return stream for email', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'doc1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Dr. Smith', 'email': 'smith@example.com'},
      );

      when(mockApi.streamDocumentByEmailId('smith@example.com'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchDoctorByEmailId('smith@example.com');

      // Assert
      expect(stream, isA<Stream<List<Doctor>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamDocumentByEmailId('smith@example.com')).called(1);
    });

    test('fetchDoctorByEmailId - should handle empty result', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamDocumentByEmailId('notfound@example.com'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchDoctorByEmailId('notfound@example.com');

      // Assert
      expect(stream, isA<Stream<List<Doctor>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamDocumentByEmailId('notfound@example.com')).called(1);
    });

    test('fetchDoctorByMobile - should return stream for mobile', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();
      final doc = models.Document(
        $id: 'doc1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Dr. Smith', 'mobile': '1234567890'},
      );

      when(mockApi.streamDocumentByMobile('1234567890'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchDoctorByMobile('1234567890');

      // Assert
      expect(stream, isA<Stream<List<Doctor>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamDocumentByMobile('1234567890')).called(1);
    });

    test('fetchDoctorByMobile - should handle different mobile', () {
      // Arrange
      final controller = StreamController<List<models.Document>>();

      when(mockApi.streamDocumentByMobile('9876543210'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchDoctorByMobile('9876543210');

      // Assert
      expect(stream, isA<Stream<List<Doctor>>>());
      controller.add([]);
      controller.close();
      verify(mockApi.streamDocumentByMobile('9876543210')).called(1);
    });

    test('getUserById - should fetch single user', () async {
      // Arrange
      final doc = models.Document(
        $id: 'user1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'John Doe', 'email': 'john@example.com'},
      );

      when(mockApi.getDocumentById('user1')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getUserById('user1');

      // Assert
      expect(result, isA<UserModel>());
      verify(mockApi.getDocumentById('user1')).called(1);
    });

    test('getUserById - should handle different user id', () async {
      // Arrange
      final doc = models.Document(
        $id: 'user2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Jane Doe', 'email': 'jane@example.com'},
      );

      when(mockApi.getDocumentById('user2')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getUserById('user2');

      // Assert
      expect(result, isA<UserModel>());
      verify(mockApi.getDocumentById('user2')).called(1);
    });

    test('removeProduct - should delete document', () async {
      // Arrange
      when(mockApi.removeDocument('id1')).thenAnswer((_) async => {});

      // Act
      await model.removeProduct('id1');

      // Assert
      verify(mockApi.removeDocument('id1')).called(1);
    });

    test('removeProduct - should handle different id', () async {
      // Arrange
      when(mockApi.removeDocument('id2')).thenAnswer((_) async => {});

      // Act
      await model.removeProduct('id2');

      // Assert
      verify(mockApi.removeDocument('id2')).called(1);
    });

    test('removeProduct - should handle multiple deletions', () async {
      // Arrange
      when(mockApi.removeDocument('id1')).thenAnswer((_) async => {});
      when(mockApi.removeDocument('id2')).thenAnswer((_) async => {});

      // Act
      await model.removeProduct('id1');
      await model.removeProduct('id2');

      // Assert
      verify(mockApi.removeDocument('id1')).called(1);
      verify(mockApi.removeDocument('id2')).called(1);
    });

    test('updateProduct - should update mother document', () async {
      // Arrange
      final mother = Mother.fromJson({'name': 'Updated Mother', 'documentId': 'mother1'});

      when(mockApi.updateDocument('mother1', any)).thenAnswer((_) async => Future.value());

      // Act
      await model.updateProduct(mother, 'mother1');

      // Assert
      verify(mockApi.updateDocument('mother1', mother.toJson())).called(1);
    });

    test('updateProduct - should handle different mother', () async {
      // Arrange
      final mother = Mother.fromJson({'name': 'Another Mother', 'documentId': 'mother2'});

      when(mockApi.updateDocument('mother2', any)).thenAnswer((_) async => Future.value());

      // Act
      await model.updateProduct(mother, 'mother2');

      // Assert
      verify(mockApi.updateDocument('mother2', mother.toJson())).called(1);
    });

    test('addProduct - should add new mother document', () async {
      // Arrange
      final mother = Mother.fromJson({'name': 'New Mother', 'age': 26});
      final newDoc = models.Document(
        $id: 'new1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: mother.toJson(),
      );

      when(mockApi.addDocument(any)).thenAnswer((_) async => newDoc);

      // Act
      final result = await model.addProduct(mother);

      // Assert
      expect(result, isA<models.Document>());
      expect(result.$id, 'new1');
      verify(mockApi.addDocument(mother.toJson())).called(1);
    });

    test('addProduct - should handle different mother data', () async {
      // Arrange
      final mother = Mother.fromJson({'name': 'Another New Mother', 'age': 30});
      final newDoc = models.Document(
        $id: 'new2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: mother.toJson(),
      );

      when(mockApi.addDocument(any)).thenAnswer((_) async => newDoc);

      // Act
      final result = await model.addProduct(mother);

      // Assert
      expect(result, isA<models.Document>());
      expect(result.$id, 'new2');
      verify(mockApi.addDocument(mother.toJson())).called(1);
    });

    test('model state - should maintain mothers cache', () async {
      // Arrange
      final doc = models.Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Mother 1', 'age': 25},
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => [doc]);

      // Act
      await model.fetchProducts();
      final cachedMothers = model.mothers;

      // Assert
      expect(cachedMothers, isNotNull);
      expect(cachedMothers!.length, 1);
      expect(model.mothers, same(cachedMothers));
    });

    test('dispose - should properly dispose model', () {
      // Act
      model.dispose();

      // Assert - should not throw
      expect(() => model.dispose(), returnsNormally);
    });

    test('mothers - should initially be null', () {
      // Arrange
      final freshModel = CRUDModel();

      // Assert
      expect(freshModel.mothers, isNull);

      // Cleanup
      freshModel.dispose();
    });
  });
}

