import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite/appwrite.dart';

import 'appwrite_notification_test.mocks.dart';

@GenerateMocks([Databases])
void main() {
  late MockDatabases mockDb;
  late AppwriteNotificationApi api;

  const databaseId = 'testDatabase';
  const collectionId = 'testCollection';

  setUp(() {
    mockDb = MockDatabases();
    api = AppwriteNotificationApi(
      db: mockDb,
      databaseId: databaseId,
      collectionId: collectionId,
    );
  });

  group('AppwriteNotificationApi Tests', () {
    test('getDataCollection returns DocumentList', () async {
      final fakeDocs = DocumentList(total: 1, documents: []);

      when(mockDb.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      )).thenAnswer((_) async => fakeDocs);

      final result = await api.getDataCollection();
      expect(result, fakeDocs);
    });

    test('streamDataCollection returns DocumentList with filters', () async {
      final userId = 'user123';
      final fakeDocs = DocumentList(total: 1, documents: []);

      when(mockDb.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => fakeDocs);

      final result = await api.streamDataCollection(userId);
      expect(result, fakeDocs);
    });

    test('getDocumentById returns Document', () async {
      const docId = 'doc123';
      final doc = Document(
        $id: docId,
        $collectionId: collectionId,
        $databaseId: databaseId,
        data: {'key': 'value'}, $createdAt: '', $updatedAt: '', $permissions: [],
      );

      when(mockDb.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: docId,
      )).thenAnswer((_) async => doc);

      final result = await api.getDocumentById(docId);
      expect(result.$id, docId);
    });

    test('removeDocument deletes document', () async {
      const docId = 'doc123';

      when(mockDb.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: docId,
      )).thenAnswer((_) async => Future.value());

      await api.removeDocument(docId);
      verify(mockDb.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: docId,
      )).called(1);
    });

    test('addDocument creates document', () async {
      final data = {'title': 'Test'};
      final doc = Document(
        $id: 'generatedId',
        $collectionId: collectionId,
        $databaseId: databaseId,
        data: data, $createdAt: '', $updatedAt: '', $permissions: [],
      );

      when(mockDb.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: anyNamed('documentId'),
        data: data,
      )).thenAnswer((_) async => doc);

      final result = await api.addDocument(data);
      expect(result.data['title'], 'Test');
    });

    // test('updateDocument updates isRead field', () async {
    //   const docId = 'doc123';
    //   final isRead = true;
    //
    //   when(mockDb.updateDocument(
    //     databaseId: databaseId,
    //     collectionId: collectionId,
    //     documentId: docId,
    //     data: {'isRead': isRead},
    //   )).thenAnswer((_) async => Future.value());
    //
    //   await api.updateDocument(isRead, docId);
    //   verify(mockDb.updateDocument(
    //     databaseId: databaseId,
    //     collectionId: collectionId,
    //     documentId: docId,
    //     data: {'isRead': isRead},
    //   )).called(1);
    // });
  });
}
