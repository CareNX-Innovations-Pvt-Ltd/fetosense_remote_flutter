import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/user_model.dart';

void main() {
  group('UserModel', () {
    test('UserModel.withData sets all fields correctly', () {
      final model = UserModel.withData(
        name: 'John',
        email: 'john@example.com',
        mobileNo: 1234567890,
        organizationId: 'org123',
        organizationName: 'OrgName',
        age: 30,
        documentId: 'doc123',
        delete: true,
        autoModifiedTimeStamp: DateTime.utc(2025, 1, 1),
        createdBy: 'admin',
        createdOn: DateTime.utc(2025, 1, 2),
        deviceId: 'dev123',
        deviceName: 'DeviceName',
        doctorId: 'docId',
        amcLog: ['log1'],
        amcPayment: 'payment',
        amcStartDate: '2025-01-03',
        amcValidity: '2026-01-03',
        appVersion: '1.0.0',
        associations: {'a': 1},
        bulletin: {'b': 2},
        deviceCode: 'devCode',
        isActive: true,
        lastSeenTime: 'yesterday',
        modifiedAt: DateTime.utc(2025, 1, 4),
        modifiedTimeStamp: 'timestamp',
        noOfMother: 10,
        noOfTests: 20,
        notificationToken: 'token',
        sync: 1,
        testAccount: true,
        type: 'type',
        uid: 'uid123',
        weight: 70.5,
        patientId: 'pat123',
        platformId: 'plat123',
        platformRegAt: 'now',
      );

      final json = model.toJson();
      expect(json['name'], 'John');
      expect(json['organizationName'], 'OrgName');
      expect(json['amcLog'], ['log1']);
    });

    test('UserModel() default constructor sets delete to false', () {
      final model = UserModel();
      expect(model.delete, false);
    });

    test('fromMap handles all _safeMap branches', () {
      final now = DateTime.utc(2025, 1, 1);

      // null branch
      final m1 = UserModel.fromMap({'associations': null, 'bulletin': null});
      expect(m1.associations, null);
      expect(m1.bulletin, null);

      // Map branch
      final m2 = UserModel.fromMap({
        'associations': {'key': 'value'},
        'bulletin': {'b': 2}
      });
      expect(m2.associations, {'key': 'value'});
      expect(m2.bulletin, {'b': 2});

      // Valid JSON string branch
      final m3 = UserModel.fromMap({
        'associations': jsonEncode({'k': 'v'}),
        'bulletin': jsonEncode({'b': 3})
      });
      expect(m3.associations, {'k': 'v'});
      expect(m3.bulletin, {'b': 3});

      // Invalid JSON string branch
      final m4 = UserModel.fromMap({
        'associations': 'not-json',
        'bulletin': 'not-json'
      });
      expect(m4.associations, null);
      expect(m4.bulletin, null);

      // Unsupported type branch
      final m5 = UserModel.fromMap({
        'associations': 123,
        'bulletin': 456,
        'createdOn': now,
        'weight': 60,
      });
      expect(m5.associations, null);
      expect(m5.bulletin, null);
      expect(m5.weight, 60.0);
      expect(m5.createdOn, now);
    });

    test('fromJson covers all _safeMap branches', () {
      // Map branch
      final m1 = UserModel.fromJson({
        'associations': {'x': 1},
        'bulletin': {'y': 2}
      });
      expect(m1.associations, {'x': 1});
      expect(m1.bulletin, {'y': 2});

      // String JSON branch
      final m2 = UserModel.fromJson({
        'associations': jsonEncode({'p': 1}),
        'bulletin': jsonEncode({'q': 2})
      });
      expect(m2.associations, {'p': 1});
      expect(m2.bulletin, {'q': 2});

      // Invalid string branch
      final m3 = UserModel.fromJson({
        'associations': 'bad-json',
        'bulletin': 'bad-json'
      });
      expect(m3.associations, null);
      expect(m3.bulletin, null);

      // null branch
      final m4 = UserModel.fromJson({'associations': null, 'bulletin': null});
      expect(m4.associations, null);
      expect(m4.bulletin, null);
    });

    test('toJson outputs expected values', () {
      final now = DateTime.utc(2025, 1, 1);
      final model = UserModel.withData(
        name: 'Test',
        createdOn: now,
        autoModifiedTimeStamp: now,
        modifiedAt: now,
        associations: {'a': 1},
        bulletin: {'b': 2},
        weight: 50.0,
      );
      final json = model.toJson();
      expect(json['name'], 'Test');
      expect(json['createdOn'], now.toIso8601String());
      expect(json['weight'], 50.0);
      expect(json['associations'], jsonEncode({'a': 1}));
    });
  });
}
