/// A model class representing a notification.
class Notification {
  String? documentId;
  String? module;
  String? type;
  String? title;
  String? message;
  bool read = false;
  bool delete = false;
  String? imageUrl;
  String? link;
  DateTime? createdOn;
  String? createdBy;

  /// Default constructor for the [Notification] class.
  Notification(){}

  /// Constructs a [Notification] instance from a map.
  ///
  /// [snapshot] is a map containing the notification data.
  /// [id] is the unique identifier of the notification.
  Notification.fromMap(Map snapshot, String id)
      : documentId = snapshot['documentId'] ?? '',
        module = snapshot['module'] ?? '',
        type = snapshot['type'] ?? '',
        title = snapshot['title'] ?? '',
        message = snapshot['body'] ?? '',
        read = snapshot['isRead'] ?? false,
        delete = snapshot['delete'] ?? false,
        imageUrl = snapshot['imageUrl'] ?? '',
        link = snapshot['link'] ?? '',
        createdOn = snapshot['createdAt'].toDate(),
        createdBy = snapshot['createdBy'] ?? '';
}