import 'dart:async';
import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';
import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart'
    as n;

class NotificationCRUDModel extends ChangeNotifier {
  final AppwriteNotificationApi _api = locator<AppwriteNotificationApi>();

  List<n.Notification>? notifications;

  /// Fetches all notifications from Appwrite.
  Future<List<n.Notification>?> fetchTests() async {
    final result = await _api.getDataCollection();
    notifications = result.documents.map((doc) {
      return n.Notification.fromMap(doc.data, doc.$id);
    }).toList();
    return notifications;
  }

  /// Polling (since Appwrite doesn't support Firestore-like snapshots)
  /// You may alternatively implement Appwrite Realtime for document changes.
  Future<void> pollNotifications(String? userId) async {
    final result = await _api.streamDataCollection(userId);
    notifications = result.documents.map((doc) {
      return n.Notification.fromMap(doc.data, doc.$id);
    }).toList();
    notifyListeners();
  }

  /// Fetch a single notification by ID
  Future<n.Notification> getTestById(String id) async {
    final doc = await _api.getDocumentById(id);
    return n.Notification.fromMap(doc.data, doc.$id);
  }

  /// Update read status
  Future<void> updateReadNotification(bool isRead, String? id) async {
    await _api.updateDocument(isRead, id);
  }

  /// Remove a notification
  Future<void> removeTest(String id) async {
    await _api.removeDocument(id);
  }

  // Stream<List<Notification>> fetchTestsAsStream(String doctorId) {
  //   return _api.streamNotificationsByDoctor(doctorId).map(
  //         (docs) => docs
  //             .map((doc) => n.Notification.fromMap(doc.data, doc.$id))
  //             .whereType<Notification>() // removes any nulls safely
  //             .toList(),
  //       );
  // }
}
