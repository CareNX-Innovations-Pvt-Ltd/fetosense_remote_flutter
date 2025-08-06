import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class MockDatabases extends Mock implements Databases {}
class MockDocumentList extends Mock implements DocumentList {}
class MockDocument extends Mock implements Document {}
class MockID extends Mock implements ID {}

void main() {
  late MockDatabases mockDb;
  late AppwriteNotificationApi api;

  const dbId = 'testDb';
  const collectionId = 'testCollection';

  setUp(() {
    mockDb = MockDatabases();
    api = AppwriteNotificationApi(
      db: mockDb,
      databaseId: dbId,
      collectionId: collectionId,
    );
  });

  test('getDataCollection returns DocumentList', () async {
    final mockDocList = MockDocumentList();
    when(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
    )).thenAnswer((_) async => mockDocList);

    final result = await api.getDataCollection();
    expect(result, mockDocList);
    verify(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
    )).called(1);
  });

  test('streamDataCollection returns filtered DocumentList', () async {
    final mockDocList = MockDocumentList();
    const userId = 'user123';
    when(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
      queries: any(named: 'queries'),
    )).thenAnswer((_) async => mockDocList);

    final result = await api.streamDataCollection(userId);
    expect(result, mockDocList);
    verify(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
      queries: any(named: 'queries'),
    )).called(1);
  });

  test('getDocumentById returns Document', () async {
    final mockDoc = MockDocument();
    const docId = 'doc123';
    when(() => mockDb.getDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
    )).thenAnswer((_) async => mockDoc);

    final result = await api.getDocumentById(docId);
    expect(result, mockDoc);
    verify(() => mockDb.getDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
    )).called(1);
  });

  test('removeDocument calls deleteDocument', () async {
    const docId = 'doc123';
    when(() => mockDb.deleteDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
    )).thenAnswer((_) async {});

    await api.removeDocument(docId);
    verify(() => mockDb.deleteDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
    )).called(1);
  });

  test('addDocument calls createDocument and returns Document', () async {
    final mockDoc = MockDocument();
    final mockData = {"title": "New Notification"};

    String generateUniqueId() => ID.unique();

    when(() => mockDb.createDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: 'unique-id',
      data: mockData,
    )).thenAnswer((_) async => mockDoc);

    final result = await api.addDocument(mockData);
    expect(result, mockDoc);
    verify(() => mockDb.createDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: generateUniqueId(),
      data: mockData,
    )).called(1);

  });

  test('updateDocument updates isRead field', () async {
    const docId = 'doc123';
    when(() => mockDb.updateDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
      data: {"isRead": true},
    )).thenAnswer((_) async => MockDocument());

    await api.updateDocument(true, docId);
    verify(() => mockDb.updateDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
      data: {"isRead": true},
    )).called(1);
  });
}
