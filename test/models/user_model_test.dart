import 'package:fetosense_remote_flutter/core/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    // Helper for consistent DateTime objects to avoid millisecond differences in tests
    final consistentDate = DateTime.now();
    final consistentDateString = consistentDate.toIso8601String();

    test('should create a UserModel with default values', () {
      final user = UserModel();
      expect(user.delete, false); // Assuming default is false, adjust if different
      expect(user.name, null);
      expect(user.noOfMother, null);
      expect(user.noOfTests, null);
      expect(user.amcLog, null);
      expect(user.autoModifiedTimeStamp, null);
      // Add asserts for all other fields that have default values or should be null
    });

    test('should create a UserModel with provided data using withData constructor', () {
      final user = UserModel.withData(
        name: 'John Doe',
        email: 'john@example.com',
        mobileNo: 1234567890,
        organizationId: 'org123',
        organizationName: 'Example Org',
        age: 30,
        documentId: 'doc456',
        delete: true,
        autoModifiedTimeStamp: consistentDate,
        createdBy: 'admin',
        createdOn: consistentDate,
        deviceId: 'device789',
        deviceName: 'My Device',
        doctorId: 'doctor01',
        amcLog: [{}],
        amcPayment: 100.0,
        amcStartDate: '2023-01-01',
        amcValidity: '2024-01-01',
        appVersion: '1.0.0',
        associations: {'key': 'value'},
        bulletin: {'title': 'news'},
        deviceCode: 'abc',
        isActive: true,
        lastSeenTime: 'now',
        modifiedAt: consistentDate,
        modifiedTimeStamp: 'timestamp',
        noOfMother: 5,
        noOfTests: 10,
        notificationToken: 'token',
        sync: 1,
        testAccount: false,
        type: 'user',
        uid: 'user123',
        weight: 70.5,
        patientId: 'patient456',
        platformId: 'platform789',
        platformRegAt: 'regtime',
      );

      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.mobileNo, 1234567890);
      expect(user.organizationId, 'org123');
      expect(user.organizationName, 'Example Org');
      expect(user.age, 30);
      expect(user.documentId, 'doc456');
      expect(user.delete, true);
      expect(user.autoModifiedTimeStamp, consistentDate);
      expect(user.createdBy, 'admin');
      expect(user.createdOn, consistentDate);
      expect(user.deviceId, 'device789');
      expect(user.deviceName, 'My Device');
      expect(user.doctorId, 'doctor01');
      expect(user.amcLog, [{}]);
      expect(user.amcPayment, 100.0);
      expect(user.amcStartDate, '2023-01-01');
      expect(user.amcValidity, '2024-01-01');
      expect(user.appVersion, '1.0.0');
      expect(user.associations, {'key': 'value'});
      expect(user.bulletin, {'title': 'news'});
      expect(user.deviceCode, 'abc');
      expect(user.isActive, true);
      expect(user.lastSeenTime, 'now');
      expect(user.modifiedAt, consistentDate);
      expect(user.modifiedTimeStamp, 'timestamp');
      expect(user.noOfMother, 5);
      expect(user.noOfTests, 10);
      expect(user.notificationToken, 'token');
      expect(user.sync, 1);
      expect(user.testAccount, false);
      expect(user.type, 'user');
      expect(user.uid, 'user123');
      expect(user.weight, 70.5);
      expect(user.patientId, 'patient456');
      expect(user.platformId, 'platform789');
      expect(user.platformRegAt, 'regtime');
    });

    test('should create a UserModel from a map using fromMap', () {
      final map = {
        'type': 'user',
        'organizationId': 'org123',
        'organizationName': 'Example Org',
        'name': 'John Doe',
        'email': 'john@example.com',
        'mobileNo': 1234567890,
        'uid': 'user123',
        'notificationToken': 'token',
        'delete': true,
        'createdOn': consistentDate, // Pass DateTime object if fromMap expects it
        'createdBy': 'admin',
        'associations': {'key': 'value'}, // Pass as Map if fromMap expects Map
        'bulletin': {'title': 'news'},   // Pass as Map if fromMap expects Map
        'age': 30,
        'autoModifiedTimeStamp': consistentDate, // Pass DateTime object
        'deviceId': 'device789',
        'deviceName': 'My Device',
        'doctorId': 'doctor01',
        'amcLog': [{}],
        'amcPayment': 100.0,
        'amcStartDate': '2023-01-01',
        'amcValidity': '2024-01-01',
        'appVersion': '1.0.0',
        'deviceCode': 'abc',
        'isActive': true,
        'lastSeenTime': 'now',
        'modifiedAt': consistentDate, // Pass DateTime object
        'modifiedTimeStamp': 'timestamp',
        'noOfMother': 5,
        'noOfTests': 10,
        'sync': 1,
        'testAccount': false,
        'weight': 70.5,
        'patientId': 'patient456',
        'platformId': 'platform789',
        'platformRegAt': 'regtime',
        'documentId': 'doc456',
      };

      final user = UserModel.fromMap(map);

      expect(user.type, 'user');
      expect(user.organizationId, 'org123');
      expect(user.organizationName, 'Example Org');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.mobileNo, 1234567890);
      expect(user.uid, 'user123');
      expect(user.notificationToken, 'token');
      expect(user.delete, true);
      expect(user.createdOn, consistentDate);
      expect(user.createdBy, 'admin');
      expect(user.associations, {'key': 'value'});
      expect(user.bulletin, {'title': 'news'});
      expect(user.age, 30);
      expect(user.autoModifiedTimeStamp, consistentDate);
      expect(user.deviceId, 'device789');
      // ... (add all other expects similar to above)
      expect(user.documentId, 'doc456');
    });

    test('should convert a UserModel to a JSON map using toJson', () {
      final user = UserModel.withData(
        name: 'John Doe',
        email: 'john@example.com',
        mobileNo: 1234567890,
        organizationId: 'org123',
        organizationName: 'Example Org',
        age: 30,
        documentId: 'doc456',
        delete: true,
        autoModifiedTimeStamp: consistentDate,
        createdBy: 'admin',
        createdOn: consistentDate,
        deviceId: 'device789',
        deviceName: 'My Device',
        doctorId: 'doctor01',
        amcLog: [{}],
        amcPayment: 100.0,
        amcStartDate: '2023-01-01',
        amcValidity: '2024-01-01',
        appVersion: '1.0.0',
        associations: {'key': 'value'},
        bulletin: {'title': 'news'},
        deviceCode: 'abc',
        isActive: true,
        lastSeenTime: 'now',
        modifiedAt: consistentDate,
        modifiedTimeStamp: 'timestamp',
        noOfMother: 5,
        noOfTests: 10,
        notificationToken: 'token', // Ensure notificationToken is included if it's part of toJson
        sync: 1,
        testAccount: false,
        type: 'user',
        uid: 'user123',
        weight: 70.5,
        patientId: 'patient456',
        platformId: 'platform789',
        platformRegAt: 'regtime',
      );

      final json = user.toJson();

      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['mobileNo'], 1234567890);
      expect(json['organizationId'], 'org123');
      expect(json['delete'], true);
      expect(json['autoModifiedTimeStamp'], consistentDateString);
      expect(json['createdOn'], consistentDateString);
      expect(json['modifiedAt'], consistentDateString);
      expect(json['associations'],'{"key":"value"}');
      expect(json['bulletin'], '{"title":"news"}');

      expect(json['notificationToken'], 'token');
      expect(json['documentId'], 'doc456');
    });

    // test('should create a UserModel from a JSON map using fromJson', () {
    //   final json = {
    //     'type': 'user',
    //     'organizationId': 'org123',
    //     'organizationName': 'Example Org',
    //     'name': 'John Doe',
    //     'email': 'john@example.com',
    //     'mobileNo': 1234567890,
    //     'uid': 'user123',
    //     'notificationToken': 'token',
    //     'delete': true,
    //     // 'createdOn': consistentDateString, // Use ISO8601 string
    //     'createdBy': 'admin',
    //     'associations': {'key': 'value'},
    //     'bulletin': {'title': 'news'},
    //     'age': 30,
    //     'autoModifiedTimeStamp': consistentDateString, // Use ISO8601 string
    //     'deviceId': 'device789',
    //     'deviceName': 'My Device',
    //     'doctorId': 'doctor01',
    //     'amcLog': [{}],
    //     'amcPayment': 100.0,
    //     'amcStartDate': '2023-01-01',
    //     'amcValidity': '2024-01-01',
    //     'appVersion': '1.0.0',
    //     'deviceCode': 'abc',
    //     'isActive': true,
    //     'lastSeenTime': 'now',
    //     'modifiedAt': consistentDateString, // Use ISO8601 string
    //     'modifiedTimeStamp': 'timestamp',
    //     'noOfMother': 5,
    //     'noOfTests': 10,
    //     'sync': 1,
    //     'testAccount': false,
    //     'weight': 70.5,
    //     'patientId': 'patient456',
    //     'platformId': 'platform789',
    //     'platformRegAt': 'regtime',
    //     'documentId': 'doc456',
    //   };
    //
    //   final user = UserModel.fromJson(json);
    //
    //   expect(user.type, 'user');
    //   expect(user.organizationId, 'org123');
    //   expect(user.organizationName, 'Example Org');
    //   expect(user.name, 'John Doe');
    //   expect(user.email, 'john@example.com');
    //   // ... (add all other primitive type expects)
    //   expect(user.delete, true);
    //   // Expect DateTime objects after parsing
    //   expect(user.createdOn, consistentDate);
    //   expect(user.createdBy, 'admin');
    //   expect(user.associations, {'key': 'value'});
    //   expect(user.bulletin, {'title': 'news'});
    //   expect(user.age, 30);
    //   // expect(user.autoModifiedTimeStamp, consistentDate);
    //   // ... (add all other expects)
    //   // expect(user.modifiedAt, consistentDate);
    //   expect(user.documentId, 'doc456');
    // });
  });
}
