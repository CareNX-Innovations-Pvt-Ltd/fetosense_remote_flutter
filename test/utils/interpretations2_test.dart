import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';


class MockDatabases extends Mock implements Databases {}
class MockDocumentList extends Mock implements DocumentList {}
class MockDocument extends Mock implements Document {}

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
    final mockList = MockDocumentList();
    when(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
    )).thenAnswer((_) async => mockList);

    final result = await api.getDataCollection();
    expect(result, mockList);
    verify(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
    )).called(1);
  });

  test('streamDataCollection returns filtered DocumentList', () async {
    final mockList = MockDocumentList();
    const userId = 'user123';

    when(() => mockDb.listDocuments(
      databaseId: dbId,
      collectionId: collectionId,
      queries: any(named: 'queries'),
    )).thenAnswer((_) async => mockList);

    final result = await api.streamDataCollection(userId);
    expect(result, mockList);
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
    const docId = 'docToDelete';

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
    final data = {'title': 'Test Notification'};

    when(() => mockDb.createDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: any(named: 'documentId'),
      data: data,
    )).thenAnswer((_) async => mockDoc);

    final result = await api.addDocument(data);
    expect(result, mockDoc);

    verify(() => mockDb.createDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: any(named: 'documentId'),
      data: data,
    )).called(1);
  });

  test('updateDocument calls updateDocument with isRead value', () async {
    const docId = 'docToUpdate';
    final isRead = true;

    when(() => mockDb.updateDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
      data: {'isRead': isRead},
    )).thenAnswer((_) async => MockDocument());

    await api.updateDocument(isRead, docId);

    verify(() => mockDb.updateDocument(
      databaseId: dbId,
      collectionId: collectionId,
      documentId: docId,
      data: {'isRead': isRead},
    )).called(1);
  });
}
