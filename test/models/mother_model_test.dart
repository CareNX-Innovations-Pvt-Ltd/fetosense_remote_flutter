import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';

class _TestUserModel extends Mother {
  // Helper to set base UserModel properties
  void setBaseData() {
    name = 'Jane';
    age = 30;
    deviceId = 'dev1';
    deviceName = 'DeviceName';
    type = 'mother';
    noOfTests = 3;
  }
}

void main() {
  group('Mother Model', () {
    test('Default constructor works', () {
      final mother = Mother();
      expect(mother, isA<Mother>());
      expect(mother.lmp, isNull);
      expect(mother.edd, isNull);
    });

    test('fromJson parses valid data', () {
      final json = {
        'name': 'Jane',
        'age': 30,
        'lmp': DateTime(2023, 5, 1).toIso8601String(),
        'deviceId': 'dev1',
        'deviceName': 'DeviceName',
        'type': 'mother',
        'noOfTests': 5,
      };
      final mother = Mother.fromJson(json);
      expect(mother.name, 'Jane');
      expect(mother.age, 30);
      expect(mother.lmp, DateTime(2023, 5, 1));
      expect(mother.deviceId, 'dev1');
      expect(mother.deviceName, 'DeviceName');
      expect(mother.type, 'mother');
      expect(mother.noOfTests, 5);
    });

    test('fromJson handles invalid date string', () {
      final json = {
        'name': 'InvalidDateMother',
        'lmp': 'not-a-date',
        'deviceId': 'dev2',
        'deviceName': 'DevName2',
        'type': 'mother',
        'noOfTests': 0,
      };
      final mother = Mother.fromJson(json);
      expect(mother.name, 'InvalidDateMother');
      expect(mother.lmp, isNull); // because DateTime.tryParse fails
    });

    test('toJson includes lmp and edd', () {
      final mother = _TestUserModel();
      mother.setBaseData();
      mother.lmp = DateTime(2023, 5, 1);
      mother.edd = DateTime(2023, 12, 1);

      final json = mother.toJson();
      expect(json['lmp'], DateTime(2023, 5, 1).toIso8601String());
      expect(json['edd'], DateTime(2023, 12, 1).toIso8601String());
      expect(json['name'], 'Jane'); // from super.toJson()
    });

    test('toJson handles null lmp and edd', () {
      final mother = _TestUserModel();
      mother.setBaseData();

      final json = mother.toJson();
      expect(json['lmp'], isNull);
      expect(json['edd'], isNull);
    });
  });
}
