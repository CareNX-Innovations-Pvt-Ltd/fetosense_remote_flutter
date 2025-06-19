import 'dart:convert';

class UserModel {
  String? name;
  String? email;
  int? mobileNo;
  String? organizationId;
  String? organizationName;
  int? age;
  String? documentId;
  bool delete;
  DateTime? autoModifiedTimeStamp;
  String? createdBy;
  DateTime? createdOn;
  String? deviceId;
  String? deviceName;
  String? doctorId;
  List<dynamic>? amcLog;
  dynamic amcPayment;
  String? amcStartDate;
  String? amcValidity;
  String? appVersion;
  Map<String, dynamic>? associations;
  Map<String, dynamic>? bulletin;
  String? deviceCode;
  bool? isActive;
  String? lastSeenTime;
  DateTime? modifiedAt;
  String? modifiedTimeStamp;
  int? noOfMother;
  int? noOfTests;
  String? notificationToken;
  int? sync;
  bool? testAccount;
  String? type;
  String? uid;
  double? weight;
  String? patientId;
  String? platformId;
  String? platformRegAt;

  UserModel.withData({
    this.name = '',
    this.email,
    this.mobileNo,
    this.organizationId,
    this.organizationName = '',
    this.age,
    this.documentId,
    this.delete = false,
    this.autoModifiedTimeStamp,
    this.createdBy,
    this.createdOn,
    this.deviceId,
    this.deviceName,
    this.doctorId,
    this.amcLog = const [],
    this.amcPayment,
    this.amcStartDate,
    this.amcValidity,
    this.appVersion,
    this.associations,
    this.bulletin,
    this.deviceCode,
    this.isActive,
    this.lastSeenTime,
    this.modifiedAt,
    this.modifiedTimeStamp,
    this.noOfMother = 0,
    this.noOfTests = 0,
    this.notificationToken,
    this.sync,
    this.testAccount,
    this.type,
    this.uid,
    this.weight,
    this.patientId,
    this.platformId,
    this.platformRegAt,
  });

  UserModel() : delete = false;

  UserModel.fromMap(Map snapshot)
      : type = snapshot['type'] as String?,
        organizationId = snapshot['organizationId'] as String?,
        organizationName = snapshot['organizationName'] as String?,
        name = snapshot['name'] as String?,
        email = snapshot['email'] as String?,
        mobileNo = snapshot['mobileNo'] as int?,
        uid = snapshot['uid'] as String?,
        notificationToken = snapshot['notificationToken'] as String?,
        delete = snapshot['delete'] as bool? ?? false,
        createdOn = snapshot['createdOn'] is DateTime
            ? snapshot['createdOn']
            : null,
        createdBy = snapshot['createdBy'] as String?,
        associations = _safeMap(snapshot['associations']),
        bulletin = _safeMap(snapshot['bulletin']),
        age = snapshot['age'] as int?,
        autoModifiedTimeStamp = snapshot['autoModifiedTimeStamp'] as DateTime?,
        deviceId = snapshot['deviceId'] as String?,
        deviceName = snapshot['deviceName'] as String?,
        doctorId = snapshot['doctorId'] as String?,
        amcLog = snapshot['amcLog'] as List<dynamic>?,
        amcPayment = snapshot['amcPayment'],
        amcStartDate = snapshot['amcStartDate'] as String?,
        amcValidity = snapshot['amcValidity'] as String?,
        appVersion = snapshot['appVersion'] as String?,
        deviceCode = snapshot['deviceCode'] as String?,
        isActive = snapshot['isActive'] as bool?,
        lastSeenTime = snapshot['lastSeenTime'] as String?,
        modifiedAt = snapshot['modifiedAt'] as DateTime?,
        modifiedTimeStamp = snapshot['modifiedTimeStamp'] as String?,
        noOfMother = snapshot['noOfMother'] as int?,
        noOfTests = snapshot['noOfTests'] as int?,
        sync = snapshot['sync'] as int?,
        testAccount = snapshot['testAccount'] as bool?,
        weight = (snapshot['weight'] is int)
            ? (snapshot['weight'] as int).toDouble()
            : snapshot['weight'] as double?,
        patientId = snapshot['patientId'] as String?,
        platformId = snapshot['platformId'] as String?,
        platformRegAt = snapshot['platformRegAt'] as String?,
        documentId = snapshot['documentId'] as String?;

  static Map<String, dynamic>? _safeMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'uid': uid,
      'notificationToken': notificationToken,
      'delete': delete,
      'createdOn': createdOn?.toIso8601String(),
      'createdBy': createdBy,
      'associations': jsonEncode(associations ?? {}),
      'bulletin': jsonEncode(bulletin ?? {}),
      'age': age,
      'autoModifiedTimeStamp': autoModifiedTimeStamp?.toIso8601String(),
      'deviceId': deviceId,
      'deviceName': deviceName,
      'doctorId': doctorId,
      'amcLog': amcLog,
      'amcPayment': amcPayment,
      'amcStartDate': amcStartDate,
      'amcValidity': amcValidity,
      'appVersion': appVersion,
      'deviceCode': deviceCode,
      'isActive': isActive,
      'lastSeenTime': lastSeenTime,
      'modifiedAt': modifiedAt?.toIso8601String(),
      'modifiedTimeStamp': modifiedTimeStamp,
      'noOfMother': noOfMother,
      'noOfTests': noOfTests,
      'sync': sync,
      'testAccount': testAccount,
      'weight': weight,
      'patientId': patientId,
      'platformId': platformId,
      'platformRegAt': platformRegAt,
      'documentId': documentId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> doc) {
    return UserModel.withData(
      type: doc['type'] as String?,
      organizationId: doc['organizationId'] as String?,
      organizationName: doc['organizationName'] as String?,
      name: doc['name'] as String?,
      email: doc['email'] as String?,
      mobileNo: doc['mobileNo'] as int?,
      uid: doc['uid'] as String?,
      notificationToken: doc['notificationToken'] as String?,
      delete: doc['delete'] as bool? ?? false,
      createdOn: doc['createdOn'] is DateTime
          ? doc['createdOn']
          : null,
      createdBy: doc['createdBy'] as String?,
      associations: _safeMap(doc['associations']),
      bulletin: _safeMap(doc['bulletin']),
      age: doc['age'] as int?,
      autoModifiedTimeStamp: doc['autoModifiedTimeStamp'] as DateTime?,
      deviceId: doc['deviceId'] as String?,
      deviceName: doc['deviceName'] as String?,
      doctorId: doc['doctorId'] as String?,
      amcLog: doc['amcLog'] as List<dynamic>?,
      amcPayment: doc['amcPayment'],
      amcStartDate: doc['amcStartDate'] as String?,
      amcValidity: doc['amcValidity'] as String?,
      appVersion: doc['appVersion'] as String?,
      deviceCode: doc['deviceCode'] as String?,
      isActive: doc['isActive'] as bool?,
      lastSeenTime: doc['lastSeenTime'] as String?,
      modifiedAt: doc['modifiedAt'] as DateTime?,
      modifiedTimeStamp: doc['modifiedTimeStamp'] as String?,
      noOfMother: doc['noOfMother'] as int?,
      noOfTests: doc['noOfTests'] as int?,
      sync: doc['sync'] as int?,
      testAccount: doc['testAccount'] as bool?,
      weight: (doc['weight'] is int)
          ? (doc['weight'] as int).toDouble()
          : doc['weight'] as double?,
      patientId: doc['patientId'] as String?,
      platformId: doc['platformId'] as String?,
      platformRegAt: doc['platformRegAt'] as String?,
      documentId: doc['documentId'] as String?,
    );
  }
}
