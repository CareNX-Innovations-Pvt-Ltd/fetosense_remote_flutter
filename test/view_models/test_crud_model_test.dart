import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/services/testapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/models.dart';

import 'test_crud_model_test.mocks.dart';

@GenerateMocks([TestApi])

void main() {
  late TestCRUDModel model;
  late MockTestApi mockApi;

  setUpAll(() {
    // Reset GetIt instance
    if (GetIt.instance.isRegistered<TestApi>()) {
      GetIt.instance.unregister<TestApi>();
    }
  });

  setUp(() {
    mockApi = MockTestApi();

    // Register mock with GetIt/locator
    GetIt.instance.registerSingleton<TestApi>(mockApi);

    // Create model instance
    model = TestCRUDModel();
  });

  tearDown(() {
    model.dispose();
    GetIt.instance.reset();
  });

  group('TestCRUDModel', () {

    test('fetchTests - should fetch and cache tests', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );
      final doc2 = Document(
        $id: 'id2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test2'},
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => [doc1, doc2]);

      // Act
      final result = await model.fetchTests();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(model.tests, isNotNull);
      expect(model.tests!.length, 2);
      verify(mockApi.getDataCollection()).called(1);
    });

    test('fetchTestsAsStream - should return stream for mother', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByMother('mother1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchTestsAsStream('mother1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByMother('mother1')).called(1);
    });

    test('fetchTestsAsStream - should handle null mother id', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByMother(null))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchTestsAsStream(null);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByMother(null)).called(1);
    });

    test('fetchTestsAsStreamBabyBeat - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByMotherBabyBeat('mother1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchTestsAsStreamBabyBeat('mother1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByMotherBabyBeat('mother1')).called(1);
    });

    test('fetchTestsAsStreamBabyBeat - should handle null', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByMotherBabyBeat(null))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchTestsAsStreamBabyBeat(null);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByMotherBabyBeat(null)).called(1);
    });

    test('fetchAllTestsAsStream - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByOrganization('org1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStream('org1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByOrganization('org1')).called(1);
    });

    test('fetchAllTestsAsStream - should handle null', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByOrganization(null))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStream(null);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByOrganization(null)).called(1);
    });

    test('fetchAllTestsAsStreamBabyBeat - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByOrganizationBabyBeat('org1', 'doc1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamBabyBeat('org1', 'doc1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByOrganizationBabyBeat('org1', 'doc1')).called(1);
    });

    test('fetchAllTestsAsStreamBabyBeat - should handle nulls', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByOrganizationBabyBeat(null, null))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamBabyBeat(null, null);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByOrganizationBabyBeat(null, null)).called(1);
    });

    test('fetchAllTestsAsStreamBabyBeatAll - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByDoctorBabyBeatAll('doc1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamBabyBeatAll('doc1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByDoctorBabyBeatAll('doc1')).called(1);
    });

    test('fetchAllTestsAsStreamBabyBeatAll - should handle null', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByDoctorBabyBeatAll(null))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamBabyBeatAll(null);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByDoctorBabyBeatAll(null)).called(1);
    });

    test('fetchAllTestsAsStreamOrg - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByOrganizationOnly('org1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamOrg('org1');

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByOrganizationOnly('org1')).called(1);
    });

    test('testStream - should create controller on first access', () {
      // Act
      final stream = model.testStream;

      // Assert
      expect(stream, isA<Stream<Test>>());
    });

    test('testStream - should return same stream', () {
      // Act
      final stream1 = model.testStream;
      final stream2 = model.testStream;

      // Assert
      expect(identical(stream1, stream2), isTrue);
    });

    test('fetchTestById - should return stream', () {
      // Arrange
      final controller = StreamController<Test>();
      final testModel = Test.fromMap({'name': 'Test1'}, 'id1');

      when(mockApi.streamTestByDocumentId('test1'))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchTestById('test1');

      // Assert
      expect(stream, isA<Stream<Test>>());
      controller.add(testModel);
      controller.close();
      verify(mockApi.streamTestByDocumentId('test1')).called(1);
    });

    test('startLiveUpdates - should initialize controller', () async {
      // Arrange
      final controller = StreamController<Test>();
      final testModel = Test.fromMap({'name': 'Test1'}, 'id1');

      when(mockApi.streamTestByDocumentId('test1'))
          .thenAnswer((_) => controller.stream);

      // Act
      model.startLiveUpdates('test1');

      // Assert
      expect(model.testStream, isA<Stream<Test>>());
      controller.add(testModel);
      await Future.delayed(Duration(milliseconds: 50));
      controller.close();
      model.stopLiveUpdates();
      verify(mockApi.streamTestByDocumentId('test1')).called(1);
    });

    test('startLiveUpdates - should reuse controller', () {
      // Arrange
      final controller1 = StreamController<Test>();
      final controller2 = StreamController<Test>();

      when(mockApi.streamTestByDocumentId('test1'))
          .thenAnswer((_) => controller1.stream);
      when(mockApi.streamTestByDocumentId('test2'))
          .thenAnswer((_) => controller2.stream);

      // Act
      model.startLiveUpdates('test1');
      final stream1 = model.testStream;
      model.startLiveUpdates('test2');
      final stream2 = model.testStream;

      // Assert
      expect(identical(stream1, stream2), isTrue);
      model.stopLiveUpdates();
      controller1.close();
      controller2.close();
    });

    test('stopLiveUpdates - should cancel subscription', () async {
      // Arrange
      final controller = StreamController<Test>();

      when(mockApi.streamTestByDocumentId('test1'))
          .thenAnswer((_) => controller.stream);

      // Act
      model.startLiveUpdates('test1');
      await Future.delayed(Duration(milliseconds: 10));
      model.stopLiveUpdates();

      // Assert
      expect(() => model.stopLiveUpdates(), returnsNormally);
      controller.close();
    });

    test('stopLiveUpdates - should handle no subscription', () {
      // Act & Assert
      expect(() => model.stopLiveUpdates(), returnsNormally);
    });

    test('fetchAllTestsAsStreamForTV - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByOrganizationForTV('org1', 10))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamForTV('org1', 10);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByOrganizationForTV('org1', 10)).called(1);
    });

    test('fetchAllTestsAsStreamForTV - should handle null', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByOrganizationForTV(null, 5))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamForTV(null, 5);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByOrganizationForTV(null, 5)).called(1);
    });

    test('fetchAllTestsAsStreamOrgForTV - should return stream', () {
      // Arrange
      final controller = StreamController<List<Document>>();
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.streamTestsByOrganizationOnlyForTV('org1', 10))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamOrgForTV('org1', 10);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.add([doc]);
      controller.close();
      verify(mockApi.streamTestsByOrganizationOnlyForTV('org1', 10)).called(1);
    });

    test('fetchAllTestsAsStreamOrgForTV - should handle null', () {
      // Arrange
      final controller = StreamController<List<Document>>();

      when(mockApi.streamTestsByOrganizationOnlyForTV(null, 5))
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = model.fetchAllTestsAsStreamOrgForTV(null, 5);

      // Assert
      expect(stream, isA<Stream<List<Test>>>());
      controller.close();
      verify(mockApi.streamTestsByOrganizationOnlyForTV(null, 5)).called(1);
    });

    test('getTestById - should fetch single test', () async {
      // Arrange
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'name': 'Test1'},
      );

      when(mockApi.getDocumentById('id1')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getTestById('id1');

      // Assert
      expect(result, isA<Test>());
      verify(mockApi.getDocumentById('id1')).called(1);
    });

    test('removeTest - should delete test', () async {
      // Arrange
      when(mockApi.removeDocument('id1')).thenAnswer((_) async => {});

      // Act
      await model.removeTest('id1');

      // Assert
      verify(mockApi.removeDocument('id1')).called(1);
    });

    test('updateTest - should update test', () async {
      // Arrange
      final test = Test.fromMap({'name': 'Updated'}, 'id1');

      when(mockApi.updateDocument('id1', any)).thenAnswer((_) async => {});

      // Act
      await model.updateTest(test, 'id1');

      // Assert
      verify(mockApi.updateDocument('id1', test.toJson())).called(1);
    });
  });
}