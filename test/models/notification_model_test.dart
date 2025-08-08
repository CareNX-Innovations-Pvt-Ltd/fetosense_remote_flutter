import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification model', () {
    test('Default constructor works', () {
      final notification = Notification();
      expect(notification.read, false);
      expect(notification.delete, false);
      expect(notification.documentId, isNull);
    });

    test('fromMap with full valid data', () {
      final dateTime = DateTime(2023, 5, 1);
      final fakeSnapshot = {
        'documentId': 'doc123',
        'module': 'module1',
        'type': 'type1',
        'title': 'Test Title',
        'body': 'Test Message',
        'isRead': true,
        'delete': true,
        'imageUrl': 'http://example.com/image.png',
        'link': 'http://example.com',
        'createdAt': _FakeTimestamp(dateTime),
        'createdBy': 'creator1',
      };

      final notification = Notification.fromMap(fakeSnapshot, 'id123');

      expect(notification.documentId, 'doc123');
      expect(notification.module, 'module1');
      expect(notification.type, 'type1');
      expect(notification.title, 'Test Title');
      expect(notification.message, 'Test Message');
      expect(notification.read, true);
      expect(notification.delete, true);
      expect(notification.imageUrl, 'http://example.com/image.png');
      expect(notification.link, 'http://example.com');
      expect(notification.createdOn, dateTime);
      expect(notification.createdBy, 'creator1');
    });

    test('fromMap with missing/null fields uses defaults', () {
      final dateTime = DateTime(2024, 1, 1);
      final fakeSnapshot = {
        'createdAt': _FakeTimestamp(dateTime),
      };

      final notification = Notification.fromMap(fakeSnapshot, 'id456');

      expect(notification.documentId, '');
      expect(notification.module, '');
      expect(notification.type, '');
      expect(notification.title, '');
      expect(notification.message, '');
      expect(notification.read, false);
      expect(notification.delete, false);
      expect(notification.imageUrl, '');
      expect(notification.link, '');
      expect(notification.createdOn, dateTime);
      expect(notification.createdBy, '');
    });
  });
}

/// Fake Timestamp class to mock Firestore Timestamp
class _FakeTimestamp {
  final DateTime _dateTime;
  _FakeTimestamp(this._dateTime);
  DateTime toDate() => _dateTime;
}
