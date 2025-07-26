import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';

void main() {
  group('Test', () {
    test('should create a Test object with withData constructor', () {
      final test = Test.withData(
        id: '1',
        documentId: 'doc1',
        motherId: 'mother1',
        deviceId: 'device1',
        doctorId: 'doctor1',
        weight: 70,
        gAge: 30,
        age: 25,
        fisherScore: 8,
        fisherScore2: 9,
        motherName: 'Mother One',
        deviceName: 'Device One',
        doctorName: 'Doctor One',
        patientId: 'patient1',
        organizationId: 'org1',
        organizationName: 'Organization One',
        imageLocalPath: '/local/path',
        imageFirePath: '/fire/path',
        audioLocalPath: '/local/audio/path',
        audioFirePath: '/fire/audio/path',
        isImgSynced: true,
        isAudioSynced: true,
        bpmEntries: [120, 130, 140],
        bpmEntries2: [125, 135, 145],
        baseLineEntries: [130, 130, 130],
        movementEntries: [1, 0, 1],
        autoFetalMovement: [0, 1, 0],
        tocoEntries: [10, 20, 15],
        lengthOfTest: 30,
        averageFHR: 135,
        live: true,
        testByMother: false,
        testById: 'tester1',
        interpretationType: 'Normal',
        interpretationExtraComments: 'No issues',
        associations: {'key1': 'value1'},
        autoInterpretations: {'autoKey1': 'autoValue1'},
        delete: false,
        createdOn: DateTime.parse('2023-10-27T10:00:00.000Z'),
        createdBy: 'creator1',
      );

      expect(test.id, '1');
      expect(test.documentId, 'doc1');
      expect(test.motherId, 'mother1');
      expect(test.deviceId, 'device1');
      expect(test.doctorId, 'doctor1');
      expect(test.weight, 70);
      expect(test.gAge, 30);
      expect(test.age, 25);
      expect(test.fisherScore, 8);
      expect(test.fisherScore2, 9);
      expect(test.motherName, 'Mother One');
      expect(test.deviceName, 'Device One');
      expect(test.doctorName, 'Doctor One');
      expect(test.patientId, 'patient1');
      expect(test.organizationId, 'org1');
      expect(test.organizationName, 'Organization One');
      expect(test.imageLocalPath, '/local/path');
      expect(test.imageFirePath, '/fire/path');
      expect(test.audioLocalPath, '/local/audio/path');
      expect(test.audioFirePath, '/fire/audio/path');
      expect(test.isImgSynced, true);
      expect(test.isAudioSynced, true);
      expect(test.bpmEntries, [120, 130, 140]);
      expect(test.bpmEntries2, [125, 135, 145]);
      expect(test.baseLineEntries, [130, 130, 130]);
      expect(test.movementEntries, [1, 0, 1]);
      expect(test.autoFetalMovement, [0, 1, 0]);
      expect(test.tocoEntries, [10, 20, 15]);
      expect(test.lengthOfTest, 30);
      expect(test.averageFHR, 135);
      expect(test.live, true);
      expect(test.testByMother, false);
      expect(test.testById, 'tester1');
      expect(test.interpretationType, 'Normal');
      expect(test.interpretationExtraComments, 'No issues');
      expect(test.associations, {'key1': 'value1'});
      expect(test.autoInterpretations, {'autoKey1': 'autoValue1'});
      expect(test.delete, false);
      expect(test.createdOn, DateTime.parse('2023-10-27T10:00:00.000Z'));
      expect(test.createdBy, 'creator1');
    });

    test('should create a Test object with data constructor', () {
      final test = Test.data(
        '1',
        'mother1',
        'device1',
        'doctor1',
        70,
        30,
        25,
        8,
        9,
        'Mother One',
        'Device One',
        'Doctor One',
        'patient1',
        'org1',
        'Organization One',
        '/local/path',
        '/fire/path',
        '/local/audio/path',
        '/fire/audio/path',
        true,
        true,
        [120, 130, 140],
        [125, 135, 145],
        [10, 20, 30],
        [40, 50, 60],
        [130, 130, 130],
        [1, 0, 1],
        [0, 1, 0],
        [10, 20, 15],
        30,
        135,
        true,
        false,
        'tester1',
        'Normal',
        'No issues',
        {'key1': 'value1'},
        {'autoKey1': 'autoValue1'},
        false,
        DateTime.parse('2023-10-27T10:00:00.000Z'),
        'creator1',
      );

      expect(test.id, '1');
      expect(test.motherId, 'mother1');
      expect(test.deviceId, 'device1');
      expect(test.doctorId, 'doctor1');
      expect(test.weight, 70);
      expect(test.gAge, 30);
      expect(test.age, 25);
      expect(test.fisherScore, 8);
      expect(test.fisherScore2, 9);
      expect(test.motherName, 'Mother One');
      expect(test.deviceName, 'Device One');
      expect(test.doctorName, 'Doctor One');
      expect(test.patientId, 'patient1');
      expect(test.organizationId, 'org1');
      expect(test.organizationName, 'Organization One');
      expect(test.imageLocalPath, '/local/path');
      expect(test.imageFirePath, '/fire/path');
      expect(test.audioLocalPath, '/local/audio/path');
      expect(test.audioFirePath, '/fire/audio/path');
      expect(test.isImgSynced, true);
      expect(test.isAudioSynced, true);
      expect(test.bpmEntries, [120, 130, 140]);
      expect(test.bpmEntries2, [125, 135, 145]);
      expect(test.mhrEntries, [10, 20, 30]);
      expect(test.spo2Entries, [40, 50, 60]);
      expect(test.baseLineEntries, [130, 130, 130]);
      expect(test.movementEntries, [1, 0, 1]);
      expect(test.autoFetalMovement, [0, 1, 0]);
      expect(test.tocoEntries, [10, 20, 15]);
      expect(test.lengthOfTest, 30);
      expect(test.averageFHR, 135);
      expect(test.live, true);
      expect(test.testByMother, false);
      expect(test.testById, 'tester1');
      expect(test.interpretationType, 'Normal');
      expect(test.interpretationExtraComments, 'No issues');
      expect(test.associations, {'key1': 'value1'});
      expect(test.autoInterpretations, {'autoKey1': 'autoValue1'});
      expect(test.delete, false);
      expect(test.createdOn, DateTime.parse('2023-10-27T10:00:00.000Z'));
      expect(test.createdBy, 'creator1');
    });

    test('should create a Test object from a map', () {
      final Map<String, dynamic> testMap = {
        'id': '1',
        'documentId': 'doc1',
        'motherId': 'mother1',
        'deviceId': 'device1',
        'doctorId': 'doctor1',
        'weight': 70,
        'gAge': 30,
        'age': 25,
        'fisherScore': 8,
        'fisherScore2': 9,
        'motherName': 'Mother One',
        'deviceName': 'Device One',
        'doctorName': 'Doctor One',
        'patientId': 'patient1',
        'organizationId': 'org1',
        'organizationName': 'Organization One',
        'imageLocalPath': '/local/path',
        'imageFirePath': '/fire/path',
        'audioLocalPath': '/local/audio/path',
        'audioFirePath': '/fire/audio/path',
        'isImgSynced': true,
        'isAudioSynced': true,
        'bpmEntries': [120, 130, 140],
        'bpmEntries2': [125, 135, 145],
        'mhrEntries': [10, 20, 30],
        'spo2Entries': [40, 50, 60],
        'baseLineEntries': [130, 130, 130],
        'movementEntries': [1, 0, 1],
        'autoFetalMovement': [0, 1, 0],
        'tocoEntries': [10, 20, 15],
        'lengthOfTest': 30,
        'averageFHR': 135,
        'live': true,
        'testByMother': false,
        'testById': 'tester1',
        'interpretationType': 'Normal',
        'interpretationExtraComments': 'No issues',
        'association': {'key1': 'value1'},
        'autoInterpretations': "{'autoKey1':'autoValue1'}",
        'delete': false,
        'createdOn': DateTime.parse('2023-10-27T10:00:00.000Z').toIso8601String(),
        'createdBy': 'creator1',
      };

      final test = Test.fromMap(testMap, '1');

      expect(test.id, '1');
      expect(test.documentId, 'doc1');
      expect(test.motherId, 'mother1');
      expect(test.deviceId, 'device1');
      expect(test.doctorId, 'doctor1');
      expect(test.weight, 70);
      expect(test.gAge, 30);
      expect(test.age, 25);
      expect(test.fisherScore, 8);
      expect(test.fisherScore2, 9);
      expect(test.motherName, 'Mother One');
      expect(test.deviceName, 'Device One');
      expect(test.doctorName, 'Doctor One');
      expect(test.patientId, 'patient1');
      expect(test.organizationId, 'org1');
      expect(test.organizationName, 'Organization One');
      expect(test.imageLocalPath, '/local/path');
      expect(test.imageFirePath, '/fire/path');
      expect(test.audioLocalPath, '/local/audio/path');
      expect(test.audioFirePath, '/fire/audio/path');
      expect(test.isImgSynced, true);
      expect(test.isAudioSynced, true);
      expect(test.bpmEntries, [120, 130, 140]);
      expect(test.bpmEntries2, [125, 135, 145]);
      expect(test.mhrEntries, [10, 20, 30]);
      expect(test.spo2Entries, [40, 50, 60]);
      expect(test.baseLineEntries, [130, 130, 130]);
      expect(test.movementEntries, [1, 0, 1]);
      expect(test.autoFetalMovement, [0, 1, 0]);
      expect(test.tocoEntries, [10, 20, 15]);
      expect(test.lengthOfTest, 30);
      expect(test.averageFHR, 135);
      expect(test.live, true);
      expect(test.testByMother, false);
      expect(test.testById, 'tester1');
      expect(test.interpretationType, 'Normal');
      expect(test.interpretationExtraComments, 'No issues');
      expect(test.associations, {'key1': 'value1'});
      // expect(test.autoInterpretations, {'autoKey1': 'autoValue1'});
      expect(test.delete, false);
      expect(test.createdOn, DateTime.parse('2023-10-27T10:00:00.000Z'));
      expect(test.createdBy, 'creator1');
    });

    test('should convert a Test object to JSON', () {
      final test = Test.withData(
        id: '1',
        documentId: 'doc1',
        motherId: 'mother1',
        deviceId: 'device1',
        doctorId: 'doctor1',
        weight: 70,
        gAge: 30,
        age: 25,
        fisherScore: 8,
        fisherScore2: 9,
        motherName: 'Mother One',
        deviceName: 'Device One',
        doctorName: 'Doctor One',
        patientId: 'patient1',
        organizationId: 'org1',
        organizationName: 'Organization One',
        imageLocalPath: '/local/path',
        imageFirePath: '/fire/path',
        audioLocalPath: '/local/audio/path',
        audioFirePath: '/fire/audio/path',
        isImgSynced: true,
        isAudioSynced: true,
        bpmEntries: [120, 130, 140],
        bpmEntries2: [125, 135, 145],
        baseLineEntries: [130, 130, 130],
        movementEntries: [1, 0, 1],
        autoFetalMovement: [0, 1, 0],
        tocoEntries: [10, 20, 15],
        lengthOfTest: 30,
        averageFHR: 135,
        live: true,
        testByMother: false,
        testById: 'tester1',
        interpretationType: 'Normal',
        interpretationExtraComments: 'No issues',
        associations: {'key1': 'value1'},
        autoInterpretations: {'autoKey1': 'autoValue1'},
        delete: false,
        createdOn: DateTime.parse('2023-10-27T10:00:00.000Z'),
        createdBy: 'creator1',
      );

      final json = test.toJson();

      expect(json['documentId'], 'doc1');
      expect(json['motherId'], 'mother1');
      expect(json['deviceId'], 'device1');
      expect(json['doctorId'], 'doctor1');
      expect(json['weight'], 70);
      expect(json['gAge'], 30);
      expect(json['fisherScore'], 8);
      expect(json['fisherScore2'], 9);
      expect(json['motherName'], 'Mother One');
      expect(json['deviceName'], 'Device One');
      expect(json['doctorName'], 'Doctor One');
      expect(json['patientId'], 'patient1');
      expect(json['organizationId'], 'org1');
      expect(json['organizationName'], 'Organization One');
      expect(json['audioLocalPath'], '/local/audio/path');
      expect(json['bpmEntries'], [120, 130, 140]);
      expect(json['bpmEntries2'], [125, 135, 145]);
      expect(json['baseLineEntries'], [130, 130, 130]);
      expect(json['movementEntries'], [1, 0, 1]);
      expect(json['autoFetalMovement'], [0, 1, 0]);
      expect(json['tocoEntries'], [10, 20, 15]);
      expect(json['lengthOfTest'], 30);
      expect(json['averageFHR'], 135);
      expect(json['live'], true);
      expect(json['testByMother'], false);
      expect(json['testById'], 'tester1');
      expect(json['interpretationType'], 'Normal');
      expect(json['interpretationExtraComments'], 'No issues');
      expect(json['association'], {'key1': 'value1'});
      expect(json['autoInterpretations'], {'autoKey1': 'autoValue1'});
      expect(json['type'], 'test');
      expect(json['delete'], false);
      expect(json['createdOn'], DateTime.parse('2023-10-27T10:00:00.000Z').millisecondsSinceEpoch);
      expect(json['createdBy'], 'creator1');
    });

    test('should correctly use getter and setter for organizationName', () {
      final test = Test();
      test.setOrganizationName('New Organization');
      expect(test.getOrganizationName(), 'New Organization');
    });

    test('should correctly use getter and setter for organizationId', () {
      final test = Test();
      test.setOrganizationId('newOrgId');
      expect(test.getOrganizationId(), 'newOrgId');
    });

    test('should correctly use getter and setter for documentId', () {
      final test = Test();
      test.setDocumentId('newDocId');
      expect(test.getDocumentId(), 'newDocId');
    });

    test('should correctly use getter and setter for createdOn', () {
      final test = Test();
      final newDateTime = DateTime.now();
      test.setCreatedOn(newDateTime);
      expect(test.getCreatedOn(), newDateTime);
    });

    test('should correctly use getter and setter for createdBy', () {
      final test = Test();
      test.setCreatedBy('newCreator');
      expect(test.getCreatedBy(), 'newCreator');
    });

    test('should correctly use getter and setter for delete', () {
      final test = Test();
      test.setDelete(true);
      expect(test.isDelete(), true);
    });

    test('should correctly use getter and setter for live', () {
      final test = Test();
      test.setLive(true);
      expect(test.isLive(), true);
    });

    test('should correctly use getter and setter for associations', () {
      final test = Test();
      final newAssociations = {'key2': 'value2'};
      test.setAssociations(newAssociations);
      expect(test.getAssociations(), newAssociations);
    });

    test('should correctly use getter and setter for autoInterpretations', () {
      final test = Test();
      final newAutoInterpretations = {'autoKey2': 'autoValue2'};
      test.setautoInterpretations(newAutoInterpretations);
      expect(test.getautoInterpretations(), newAutoInterpretations);
    });

    test('fromMap should handle null and string association', () {
      final mapWithNullAssociation = {
        'createdOn': DateTime.now().toIso8601String(),
      };
      final testFromNull = Test.fromMap(mapWithNullAssociation, '1');
      expect(testFromNull.associations, null);

      final mapWithStringAssociation = {
        'association': '{"key":"value"}',
        'createdOn': DateTime.now().toIso8601String(),
      };
      final testFromString = Test.fromMap(mapWithStringAssociation, '2');
      expect(testFromString.associations, {'key': 'value'});
    });

    test('fromMap should handle missing list fields', () {
      final mapWithMissingLists = {
        'createdOn': DateTime.now().toIso8601String(),
      };
      final test = Test.fromMap(mapWithMissingLists, '1');
      expect(test.bpmEntries, []);
      expect(test.bpmEntries2, []);
      expect(test.mhrEntries, []);
      expect(test.spo2Entries, []);
      expect(test.baseLineEntries, []);
      expect(test.movementEntries, []);
      expect(test.autoFetalMovement, []);
      expect(test.tocoEntries, []);
    });

    test('fromMap should handle live field correctly when null', () {
      final mapWithNullLive = {
        'createdOn': DateTime.now().toIso8601String(),
      };
      final test = Test.fromMap(mapWithNullLive, '1');
      expect(test.live, false);
    });
  });
}