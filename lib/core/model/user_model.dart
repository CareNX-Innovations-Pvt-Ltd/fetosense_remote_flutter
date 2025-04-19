
import 'dart:convert';

/// A model class representing a user.
class UserModel {
  String? type;
  String? organizationId;
  String? organizationName;
  String? organizationIdBabyBeat;
  String? organizationNameBabyBeat;
  String? name;
  String? email;
  String? mobileNo;
  String? uid;
  String? notificationToken;
  String? documentId;
  bool delete = false;
  DateTime? createdOn;
  String? createdBy;
  Map<String, dynamic>? associations;
  Map<String, dynamic>? babyBeatAssociation;

  UserModel.withData(
      {type,
      organizationId,
      organizationName,
      organizationIdBabyBeat,
      organizationNameBabyBeat,
      name,
      email,
      mobileNo,
      uid,
      notificationToken,
      documentId,
      delete = false,
      createdOn,
      createdBy,
      associations,
      babyBeatAssociation});

  /// Constructs a [UserModel] instance from a map.
  ///
  /// [snapshot] is a map containing the user data.
  /// [id] is the unique identifier of the user.
  UserModel.fromMap(Map snapshot, String id)
      : type = snapshot['type'] ?? '',
        organizationId = snapshot['organizationId'] ?? '',
        organizationName = snapshot['organizationName'] ?? '',
        organizationIdBabyBeat = snapshot['organizationIdBabyBeat'] ?? '',
        organizationNameBabyBeat = snapshot['organizationNameBabyBeat'] ?? '',
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        mobileNo = snapshot['mobileNo'] ?? '',
        uid = snapshot['uid'] ?? '',
        notificationToken = snapshot['notificationToken'] ?? '',
        documentId = snapshot['documentId'] ?? id,
        delete = snapshot['delete'] ?? false,
        createdOn = snapshot['createdOn'] is DateTime
            ? snapshot['createdOn']
            : null,
        createdBy = snapshot['createdBy'] ?? '',
        associations = snapshot['associations'] is String
            ? jsonDecode(snapshot['associations'])
            : snapshot['associations'],
        babyBeatAssociation = snapshot['babyBeatAssociation'] is String
            ? jsonDecode(snapshot['babyBeatAssociation'])
            : snapshot['babyBeatAssociation'];


  UserModel();
  /// Gets the type of the user.
  ///
  /// Returns the type as a [String].
  String? getType() {
    return type;
  }

  /// Sets the type of the user.
  ///
  /// [type] is the new type to be set.
  void setType(String type) {
    this.type = type;
  }

  /// Gets the organization name.
  ///
  /// Returns the organization name as a [String].
  String? getOrganizationName() {
    return organizationName;
  }

  /// Sets the organization name.
  ///
  /// [organizationName] is the new organization name to be set.
  void setOrganizationName(String organizationName) {
    this.organizationName = organizationName;
  }

  /// Gets the organization ID.
  ///
  /// Returns the organization ID as a [String].
  String? getOrganizationId() {
    return organizationId;
  }

  /// Sets the organization ID.
  ///
  /// [organizationId] is the new organization ID to be set.
  void setOrganizationId(String organizationId) {
    this.organizationId = organizationId;
  }

  /// Gets the BabyBeat organization name.
  ///
  /// Returns the BabyBeat organization name as a [String].
  String? getOrganizationNameBabyBeat() {
    return organizationNameBabyBeat;
  }

  /// Sets the BabyBeat organization name.
  ///
  /// [organizationNameBabyBeat] is the new BabyBeat organization name to be set.
  void setOrganizationNameBabyBeat(String organizationName) {
    organizationNameBabyBeat = organizationName;
  }

  /// Gets the BabyBeat organization ID.
  ///
  /// Returns the BabyBeat organization ID as a [String].
  String? getOrganizationIdBabyBeat() {
    return organizationIdBabyBeat;
  }

  /// Sets the BabyBeat organization ID.
  ///
  /// [organizationIdBabyBeat] is the new BabyBeat organization ID to be set.
  void setOrganizationIdBabyBeat(String organizationId) {
    organizationIdBabyBeat = organizationId;
  }

  /// Gets the name of the user.
  ///
  /// Returns the name as a [String].
  String? getName() {
    return name;
  }

  /// Sets the name of the user.
  ///
  /// [name] is the new name to be set.
  void setName(String name) {
    this.name = name;
  }

  /// Gets the email of the user.
  ///
  /// Returns the email as a [String].
  String? getEmail() {
    return email;
  }

  /// Sets the email of the user.
  ///
  /// [email] is the new email to be set.
  void setEmail(String email) {
    this.email = email;
  }

  /// Gets the mobile number of the user.
  ///
  /// Returns the mobile number as a [String].
  String? getMobileNo() {
    return mobileNo;
  }

  /// Sets the mobile number of the user.
  ///
  /// [mobileNo] is the new mobile number to be set.
  void setMobileNo(String mobileNo) {
    this.mobileNo = mobileNo;
  }

  /// Gets the unique identifier of the user.
  ///
  /// Returns the UID as a [String].
  String? getUid() {
    return uid;
  }

  /// Sets the unique identifier of the user.
  ///
  /// [uid] is the new UID to be set.
  void setUid(String uid) {
    this.uid = uid;
  }

  /// Gets the notification token of the user.
  ///
  /// Returns the notification token as a [String].
  String? getNotificationToken() {
    return notificationToken;
  }

  /// Sets the notification token of the user.
  ///
  /// [notificationToken] is the new notification token to be set.
  void setNotificationToken(String notificationToken) {
    this.notificationToken = notificationToken;
  }

  /// Gets the document ID of the user.
  ///
  /// Returns the document ID as a [String].
  String? getDocumentId() {
    return documentId;
  }

  /// Sets the document ID of the user.
  ///
  /// [documentId] is the new document ID to be set.
  void setDocumentId(String documentId) {
    this.documentId = documentId;
  }

  /// Gets the creation date of the user.
  ///
  /// Returns the creation date as a [DateTime].
  DateTime? getCreatedOn() {
    return createdOn;
  }

  /// Sets the creation date of the user.
  ///
  /// [createdOn] is the new creation date to be set.
  void setCreatedOn(DateTime createdOn) {
    this.createdOn = createdOn;
  }

  /// Gets the creator of the user.
  ///
  /// Returns the creator as a [String].
  String? getCreatedBy() {
    return createdBy;
  }

  /// Sets the creator of the user.
  ///
  /// [createdBy] is the new creator to be set.
  void setCreatedBy(String createdBy) {
    this.createdBy = createdBy;
  }

  /// Checks if the user is deleted.
  ///
  /// Returns `true` if the user is deleted, `false` otherwise.
  bool isDelete() {
    return delete;
  }

  /// Sets the delete status of the user.
  ///
  /// [delete] is the new delete status to be set.
  void setDelete(bool delete) {
    this.delete = delete;
  }

  /// Converts the [UserModel] instance to a JSON map.
  ///
  /// Returns a map containing the user data.
  Map<String, Object?> toJson() {
    return {
      'type': type,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationIdBabyBeat': organizationIdBabyBeat,
      'organizationNameBabyBeat': organizationNameBabyBeat,
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'uid': uid,
      'notificationToken': notificationToken,
      'documentId': documentId,
      'delete': delete,
      'createdOn': createdOn?.toIso8601String(),
      'createdBy': createdBy,
      'associations': jsonEncode(associations ?? {}),
      'babyBeatAssociation': jsonEncode(babyBeatAssociation ?? {})
    };
  }

  /// Creates a [UserModel] instance from a JSON map.
  ///
  /// [doc] is a map containing the user data.
  factory UserModel.fromJson(Map<String, dynamic> doc) {
    UserModel user = UserModel.withData(
        type: doc['type'],
        organizationId: doc['organizationId'],
        organizationName: doc['organizationName'],
        organizationIdBabyBeat: doc['organizationIdBabyBeat'],
        organizationNameBabyBeat: doc['organizationNameBabyBeat'],
        name: doc['name'],
        email: doc['email'],
        mobileNo: doc['mobileNo'],
        uid: doc['uid'],
        notificationToken: doc['notificationToken'],
        documentId: doc['documentId'],
        delete: doc['delete'],
        createdOn: doc['createdOn'],
        createdBy: doc['createdBy'],
        associations: doc['associations'],
        babyBeatAssociation: doc['babyBeatAssociation']);
    return user;
  }
}
