import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart';
import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import your actual files - adjust paths as needed
import 'package:fetosense_remote_flutter/core/view_models/notification_crud_model.dart';
import 'package:get_it/get_it.dart';
import 'package:appwrite/models.dart';

import 'notification_crud_model_test.mocks.dart';

@GenerateMocks([AppwriteNotificationApi])

void main() {
  late NotificationCRUDModel model;
  late MockAppwriteNotificationApi mockApi;

  setUpAll(() {
    // Reset GetIt instance
    if (GetIt.instance.isRegistered<AppwriteNotificationApi>()) {
      GetIt.instance.unregister<AppwriteNotificationApi>();
    }
  });

  setUp(() {
    mockApi = MockAppwriteNotificationApi();

    // Register mock with GetIt/locator
    GetIt.instance.registerSingleton<AppwriteNotificationApi>(mockApi);

    // Create model instance
    model = NotificationCRUDModel();
  });

  tearDown(() {
    model.dispose();
    GetIt.instance.reset();
  });

  group('NotificationCRUDModel', () {

    test('fetchTests - should fetch and cache notifications', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );
      final doc2 = Document(
        $id: 'id2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 2', 'message': 'Message 2'},
      );

      final documentList = DocumentList(
        total: 2,
        documents: [doc1, doc2],
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => documentList);

      // Act
      final result = await model.fetchTests();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(model.notifications, isNotNull);
      expect(model.notifications!.length, 2);
      verify(mockApi.getDataCollection()).called(1);
    });

    test('fetchTests - should handle empty result', () async {
      // Arrange
      final documentList = DocumentList(
        total: 0,
        documents: [],
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => documentList);

      // Act
      final result = await model.fetchTests();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 0);
      expect(model.notifications, isNotNull);
      expect(model.notifications!.length, 0);
      verify(mockApi.getDataCollection()).called(1);
    });

    test('pollNotifications - should fetch and notify listeners with userId', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      final documentList = DocumentList(
        total: 1,
        documents: [doc1],
      );

      when(mockApi.streamDataCollection('user1')).thenAnswer((_) async => documentList);

      bool listenerCalled = false;
      model.addListener(() {
        listenerCalled = true;
      });

      // Act
      await model.pollNotifications('user1');

      // Assert
      expect(model.notifications, isNotNull);
      expect(model.notifications!.length, 1);
      expect(listenerCalled, isTrue);
      verify(mockApi.streamDataCollection('user1')).called(1);
    });

    test('pollNotifications - should handle null userId', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      final documentList = DocumentList(
        total: 1,
        documents: [doc1],
      );

      when(mockApi.streamDataCollection(null)).thenAnswer((_) async => documentList);

      bool listenerCalled = false;
      model.addListener(() {
        listenerCalled = true;
      });

      // Act
      await model.pollNotifications(null);

      // Assert
      expect(model.notifications, isNotNull);
      expect(model.notifications!.length, 1);
      expect(listenerCalled, isTrue);
      verify(mockApi.streamDataCollection(null)).called(1);
    });

    test('pollNotifications - should handle empty result', () async {
      // Arrange
      final documentList = DocumentList(
        total: 0,
        documents: [],
      );

      when(mockApi.streamDataCollection('user1')).thenAnswer((_) async => documentList);

      bool listenerCalled = false;
      model.addListener(() {
        listenerCalled = true;
      });

      // Act
      await model.pollNotifications('user1');

      // Assert
      expect(model.notifications, isNotNull);
      expect(model.notifications!.length, 0);
      expect(listenerCalled, isTrue);
      verify(mockApi.streamDataCollection('user1')).called(1);
    });

    test('pollNotifications - should notify multiple listeners', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      final documentList = DocumentList(
        total: 1,
        documents: [doc1],
      );

      when(mockApi.streamDataCollection('user1')).thenAnswer((_) async => documentList);

      int listenerCallCount = 0;
      model.addListener(() {
        listenerCallCount++;
      });
      model.addListener(() {
        listenerCallCount++;
      });

      // Act
      await model.pollNotifications('user1');

      // Assert
      expect(listenerCallCount, 2);
      verify(mockApi.streamDataCollection('user1')).called(1);
    });

    test('getTestById - should fetch single notification', () async {
      // Arrange
      final doc = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      when(mockApi.getDocumentById('id1')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getTestById('id1');

      // Assert
      expect(result, isA<Notification>());
      verify(mockApi.getDocumentById('id1')).called(1);
    });

    test('getTestById - should handle different id', () async {
      // Arrange
      final doc = Document(
        $id: 'id2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 2', 'message': 'Message 2'},
      );

      when(mockApi.getDocumentById('id2')).thenAnswer((_) async => doc);

      // Act
      final result = await model.getTestById('id2');

      // Assert
      expect(result, isA<Notification>());
      verify(mockApi.getDocumentById('id2')).called(1);
    });

    test('updateReadNotification - should update read status to true', () async {
      // Arrange
      when(mockApi.updateDocument(true, 'id1')).thenAnswer((_) async => {});

      // Act
      await model.updateReadNotification(true, 'id1');

      // Assert
      verify(mockApi.updateDocument(true, 'id1')).called(1);
    });

    test('updateReadNotification - should update read status to false', () async {
      // Arrange
      when(mockApi.updateDocument(false, 'id2')).thenAnswer((_) async => {});

      // Act
      await model.updateReadNotification(false, 'id2');

      // Assert
      verify(mockApi.updateDocument(false, 'id2')).called(1);
    });

    test('updateReadNotification - should handle null id', () async {
      // Arrange
      when(mockApi.updateDocument(true, null)).thenAnswer((_) async => {});

      // Act
      await model.updateReadNotification(true, null);

      // Assert
      verify(mockApi.updateDocument(true, null)).called(1);
    });

    test('updateReadNotification - should handle false with null id', () async {
      // Arrange
      when(mockApi.updateDocument(false, null)).thenAnswer((_) async => {});

      // Act
      await model.updateReadNotification(false, null);

      // Assert
      verify(mockApi.updateDocument(false, null)).called(1);
    });

    test('removeTest - should delete notification', () async {
      // Arrange
      when(mockApi.removeDocument('id1')).thenAnswer((_) async => {});

      // Act
      await model.removeTest('id1');

      // Assert
      verify(mockApi.removeDocument('id1')).called(1);
    });

    test('removeTest - should handle different id', () async {
      // Arrange
      when(mockApi.removeDocument('id2')).thenAnswer((_) async => {});

      // Act
      await model.removeTest('id2');

      // Assert
      verify(mockApi.removeDocument('id2')).called(1);
    });

    test('removeTest - should handle multiple deletions', () async {
      // Arrange
      when(mockApi.removeDocument('id1')).thenAnswer((_) async => {});
      when(mockApi.removeDocument('id2')).thenAnswer((_) async => {});

      // Act
      await model.removeTest('id1');
      await model.removeTest('id2');

      // Assert
      verify(mockApi.removeDocument('id1')).called(1);
      verify(mockApi.removeDocument('id2')).called(1);
    });

    test('model state - should maintain notifications state', () async {
      // Arrange
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      final documentList = DocumentList(
        total: 1,
        documents: [doc1],
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => documentList);

      // Act
      await model.fetchTests();
      final cachedNotifications = model.notifications;

      // Assert
      expect(cachedNotifications, isNotNull);
      expect(cachedNotifications!.length, 1);
      expect(model.notifications, same(cachedNotifications));
    });

    test('model state - should update notifications on poll', () async {
      // Arrange - Initial fetch
      final doc1 = Document(
        $id: 'id1',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-01',
        $updatedAt: '2024-01-01',
        $permissions: [],
        data: {'title': 'Notification 1', 'message': 'Message 1'},
      );

      final initialList = DocumentList(
        total: 1,
        documents: [doc1],
      );

      when(mockApi.getDataCollection()).thenAnswer((_) async => initialList);
      await model.fetchTests();

      // Arrange - Poll with new data
      final doc2 = Document(
        $id: 'id2',
        $collectionId: 'col1',
        $databaseId: 'db1',
        $createdAt: '2024-01-02',
        $updatedAt: '2024-01-02',
        $permissions: [],
        data: {'title': 'Notification 2', 'message': 'Message 2'},
      );

      final updatedList = DocumentList(
        total: 2,
        documents: [doc1, doc2],
      );

      when(mockApi.streamDataCollection('user1')).thenAnswer((_) async => updatedList);

      // Act
      await model.pollNotifications('user1');

      // Assert
      expect(model.notifications!.length, 2);
      verify(mockApi.streamDataCollection('user1')).called(1);
    });

    test('dispose - should properly dispose model', () {
      // Act
      model.dispose();

      // Assert - should not throw
      expect(() => model.dispose(), returnsNormally);
    });

    test('notifications - should initially be null', () {
      // Arrange
      final freshModel = NotificationCRUDModel();

      // Assert
      expect(freshModel.notifications, isNull);

      // Cleanup
      freshModel.dispose();
    });
  });
}