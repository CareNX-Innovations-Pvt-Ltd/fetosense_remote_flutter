import 'dart:convert';

class UserModel {
  String? name;
  String? email;
  int? mobileNo;
  String? organizationId;
  String? organizationName;
  int? age;
  String? documentId;
  bool delete = false;
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
  String? organizationNameBabyBeat;
  Map<String, dynamic>? babyBeatAssociation;

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
    this.babyBeatAssociation,
    this.organizationNameBabyBeat,
  });

  UserModel();

  UserModel.fromMap(Map snapshot,)
      : type = snapshot['type'],
        organizationId = snapshot['organizationId'],
        organizationName = snapshot['organizationName'],
        name = snapshot['name'],
        email = snapshot['email'],
        mobileNo = snapshot['mobileNo'],
        uid = snapshot['uid'],
        notificationToken = snapshot['notificationToken'],
        delete = snapshot['delete'] ?? false,
        createdOn =
            snapshot['createdOn'] is DateTime ? snapshot['createdOn'] : null,
        createdBy = snapshot['createdBy'],
        associations = snapshot['associations'] is String
            ? jsonDecode(snapshot['associations'])
            : snapshot['associations'],
        bulletin = snapshot['bulletin'] is String
            ? jsonDecode(snapshot['bulletin'])
            : snapshot['bulletin'],
        age = snapshot['age'],
        autoModifiedTimeStamp = snapshot['autoModifiedTimeStamp'],
        deviceId = snapshot['deviceId'],
        deviceName = snapshot['deviceName'],
        doctorId = snapshot['doctorId'],
        amcLog = snapshot['amcLog'],
        amcPayment = snapshot['amcPayment'],
        amcStartDate = snapshot['amcStartDate'],
        amcValidity = snapshot['amcValidity'],
        appVersion = snapshot['appVersion'],
        deviceCode = snapshot['deviceCode'],
        isActive = snapshot['isActive'],
        lastSeenTime = snapshot['lastSeenTime'],
        modifiedAt = snapshot['modifiedAt'],
        modifiedTimeStamp = snapshot['modifiedTimeStamp'],
        noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        sync = snapshot['sync'],
        testAccount = snapshot['testAccount'],
        weight = snapshot['weight'],
        patientId = snapshot['patientId'],
        platformId = snapshot['platformId'],
        documentId = snapshot['documentId'],
        platformRegAt = snapshot['platformRegAt'],
        organizationNameBabyBeat = snapshot['organizationNameBabyBeat'],
        babyBeatAssociation = (() {
          final data = snapshot['babyBeatAssociation'];
          if (data == null) return null;
          if (data is String) {
            try {
              return jsonDecode(data);
            } catch (_) {
              return {}; // or null, depending on how you want to handle bad JSON
            }
          }
          return data;
        })();

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
      'autoModifiedTimeStamp': autoModifiedTimeStamp,
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
      'modifiedAt': modifiedAt,
      'modifiedTimeStamp': modifiedTimeStamp,
      'noOfMother': noOfMother,
      'noOfTests': noOfTests,
      'sync': sync,
      'testAccount': testAccount,
      'weight': weight,
      'patientId': patientId,
      'platformId': platformId,
      'platformRegAt': platformRegAt,
      'babyBeatAssociation': babyBeatAssociation,
      'documentId': documentId,
      'organizationNameBabyBeat': organizationNameBabyBeat,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> doc) {
    return UserModel.withData(
      type: doc['type'],
      organizationId: doc['organizationId'],
      organizationName: doc['organizationName'],
      name: doc['name'],
      email: doc['email'],
      mobileNo: doc['mobileNo'],
      uid: doc['uid'],
      notificationToken: doc['notificationToken'],
      delete: doc['delete'],
      createdOn: doc['createdOn'],
      createdBy: doc['createdBy'],
      associations: doc['associations'] is String
          ? jsonDecode(doc['associations'])
          : doc['associations'],
      bulletin: doc['bulletin'] is String
          ? jsonDecode(doc['bulletin'])
          : doc['bulletin'],
      age: doc['age'],
      autoModifiedTimeStamp: doc['autoModifiedTimeStamp'],
      deviceId: doc['deviceId'],
      deviceName: doc['deviceName'],
      doctorId: doc['doctorId'],
      amcLog: doc['amcLog'],
      amcPayment: doc['amcPayment'],
      amcStartDate: doc['amcStartDate'],
      amcValidity: doc['amcValidity'],
      appVersion: doc['appVersion'],
      deviceCode: doc['deviceCode'],
      isActive: doc['isActive'],
      lastSeenTime: doc['lastSeenTime'],
      modifiedAt: doc['modifiedAt'],
      modifiedTimeStamp: doc['modifiedTimeStamp'],
      noOfMother: doc['noOfMother'],
      noOfTests: doc['noOfTests'],
      sync: doc['sync'],
      testAccount: doc['testAccount'],
      weight: doc['weight'],
      patientId: doc['patientId'],
      platformId: doc['platformId'],
      platformRegAt: doc['platformRegAt'],
      documentId: doc['documentId'],
      organizationNameBabyBeat: doc['organizationNameBabyBeat'],
      babyBeatAssociation: (() {
        final data = doc['babyBeatAssociation'];
        if (data == null) return null;
        if (data is String) {
          try {
            return jsonDecode(data);
          } catch (_) {
            return {}; // or null
          }
        }
        return data;
      })(),
    );
  }
}
