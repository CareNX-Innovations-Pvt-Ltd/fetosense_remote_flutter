import 'package:fetosense_remote_flutter/core/services/appwrite_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class MockDatabases extends Mock implements Databases {}
class MockDocumentList extends Mock implements models.DocumentList {}
class MockDocument extends Mock implements models.Document {}

void main() {
  late MockDatabases mockDatabases;
  late AppwriteApi api;
  late MockDocumentList mockDocList;
  late MockDocument mockDoc;

  const dbId = 'db1';
  const colId = 'col1';

  setUp(() {
    mockDatabases = MockDatabases();
    api = AppwriteApi(
      database: mockDatabases,
      databaseId: dbId,
      collectionId: colId,
    );
    mockDocList = MockDocumentList();
    mockDoc = MockDocument();

    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
  });

  group('AppwriteApi', () {
    test('getDataCollection returns documents', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final result = await api.getDataCollection();

      expect(result, [mockDoc]);
      verify(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
      )).called(1);
    });

    test('streamMotherData works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final stream = api.streamMotherData('org1');
      final result = await stream.first;

      expect(result, [mockDoc]);
    });

    test('streamActiveMotherData works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final stream = api.streamActiveMotherData('org1');
      final result = await stream.first;

      expect(result, [mockDoc]);
    });

    test('streamMotherDataSearch works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final stream = api.streamMotherDataSearch('org1', 'filter');
      final result = await stream.first;

      expect(result, [mockDoc]);
    });

    test('getDocumentById works', () async {
      when(() => mockDatabases.getDocument(
        databaseId: dbId,
        collectionId: colId,
        documentId: 'doc1',
      )).thenAnswer((_) async => mockDoc);

      final result = await api.getDocumentById('doc1');

      expect(result, mockDoc);
    });

    test('streamDocumentByEmailId works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final result = await api.streamDocumentByEmailId('email@test.com').first;
      expect(result, [mockDoc]);
    });

    test('streamDocumentByMobile works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: colId,
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final result = await api.streamDocumentByMobile('9999').first;
      expect(result, [mockDoc]);
    });

    test('removeDocument works', () async {
      when(() => mockDatabases.deleteDocument(
        databaseId: dbId,
        collectionId: colId,
        documentId: 'doc1',
      )).thenAnswer((_) async => {});

      await api.removeDocument('doc1');

      verify(() => mockDatabases.deleteDocument(
        databaseId: dbId,
        collectionId: colId,
        documentId: 'doc1',
      )).called(1);
    });

    test('addDocument works', () async {
      when(() => mockDatabases.createDocument(
        databaseId: dbId,
        collectionId: colId,
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockDoc);

      final result = await api.addDocument({'key': 'value'});

      expect(result, mockDoc);
    });

    test('updateDocument works', () async {
      when(() => mockDatabases.updateDocument(
        databaseId: dbId,
        collectionId: colId,
        documentId: 'doc1',
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockDoc);

      final result = await api.updateDocument('doc1', {'key': 'value'});

      expect(result, mockDoc);
    });

    test('getUser works', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: 'users',
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final result = await api.getUser('9999').first;
      expect(result, [mockDoc]);
    });

    test('isNewUser returns true when no documents', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: 'users',
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([]);

      final result = await api.isNewUser('9999');
      expect(result, true);
    });

    test('isNewUser returns false when documents exist', () async {
      when(() => mockDatabases.listDocuments(
        databaseId: dbId,
        collectionId: 'users',
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);
      when(() => mockDocList.documents).thenReturn([mockDoc]);

      final result = await api.isNewUser('9999');
      expect(result, false);
    });
  });
}
