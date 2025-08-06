import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';

class _TestUserModel extends Organization {
  // Helper to set base UserModel fields
  void setBaseData() {
    name = 'OrgName';
    age = 5;
    deviceId = 'dev1';
    deviceName = 'Device1';
    type = 'organization';
    noOfTests = 7;
  }
}

void main() {
  group('Organization model', () {
    test('Default constructor works', () {
      final org = Organization();
      expect(org.noOfDevices, 0);
      expect(org, isA<Organization>());
    });

    test('fromMap sets noOfDevices when noOfTests provided', () {
      final map = {
        'name': 'TestOrg',
        'noOfTests': 15,
      };
      final org = Organization.fromMap(map);
      expect(org.noOfDevices, 15);
      expect(org.name, 'TestOrg'); // from UserModel
    });

    test('fromMap defaults noOfDevices to 0 if missing', () {
      final map = {
        'name': 'OrgWithoutTests',
      };
      final org = Organization.fromMap(map);
      expect(org.noOfDevices, 0);
      expect(org.name, 'OrgWithoutTests');
    });
  });
}
