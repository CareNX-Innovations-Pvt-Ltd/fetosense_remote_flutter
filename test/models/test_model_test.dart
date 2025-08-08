import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() {
  group('Test model', () {
    test('Constructor withData and getters/setters', () {
      final now = DateTime.now();
      final testModel = Test.withData(
        id: '1',
        documentId: 'doc1',
        motherId: 'm1',
        deviceId: 'd1',
        doctorId: 'dr1',
        weight: 70,
        gAge: 30,
        fisherScore: 5,
        fisherScore2: 6,
        motherName: 'Mother',
        deviceName: 'Device',
        doctorName: 'Doctor',
        patientId: 'p1',
        age: 28,
        organizationId: 'org1',
        organizationName: 'Org',
        imageLocalPath: 'local.png',
        imageFirePath: 'fire.png',
        audioLocalPath: 'local.mp3',
        audioFirePath: 'fire.mp3',
        isImgSynced: true,
        isAudioSynced: false,
        bpmEntries: [1, 2],
        bpmEntries2: [3, 4],
        baseLineEntries: [5],
        movementEntries: [6],
        autoFetalMovement: [7],
        tocoEntries: [8],
        lengthOfTest: 100,
        averageFHR: 120,
        live: true,
        testByMother: false,
        testById: 'tb1',
        interpretationType: 'type',
        interpretationExtraComments: 'comments',
        associations: {'a': 'b'},
        autoInterpretations: {'x': 'y'},
        delete: true,
        createdOn: now,
        createdBy: 'creator',
      );

      // Getters and Setters
      expect(testModel.getOrganizationName(), 'Org');
      testModel.setOrganizationName('Org2');
      expect(testModel.organizationName, 'Org2');

      expect(testModel.getOrganizationId(), 'org1');
      testModel.setOrganizationId('org2');
      expect(testModel.organizationId, 'org2');

      expect(testModel.getDocumentId(), '1');
      testModel.setDocumentId('2');
      expect(testModel.id, '2');

      expect(testModel.getCreatedOn(), now);
      final newDate = now.add(Duration(days: 1));
      testModel.setCreatedOn(newDate);
      expect(testModel.createdOn, newDate);

      expect(testModel.getCreatedBy(), 'creator');
      testModel.setCreatedBy('newCreator');
      expect(testModel.createdBy, 'newCreator');

      expect(testModel.isDelete(), true);
      testModel.setDelete(false);
      expect(testModel.delete, false);

      expect(testModel.isLive(), true);
      testModel.setLive(false);
      expect(testModel.live, false);

      // expect(testModel.getAssociations(), {'a': 'b'});
      testModel.setAssociations({'c': 'd'});
      expect(testModel.associations, {'c': 'd'});

      // expect(testModel.getautoInterpretations(), {'x': 'y'});
      testModel.setautoInterpretations({'z': 'w'});
      expect(testModel.autoInterpretations, {'z': 'w'});

      // toJson
      testModel.createdOn = now;
      final json = testModel.toJson();
      expect(json['organizationName'], 'Org2');
      expect(json['createdOn'], now.millisecondsSinceEpoch);

      // printDetails (covered by kDebugMode)
      debugPrint = (String? message, {int? wrapWidth}) {};
      testModel.printDetails();
    });

    test('Constructor data works', () {
      final now = DateTime.now();
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
      expect(test.organizationName, 'Organization One');
    });

    test('fromMap with full data', () {
      final map = {
        'id': 'id',
        'documentId': 'doc',
        'motherId': 'm1',
        'deviceId': 'd1',
        'doctorId': 'dr1',
        'weight': 70,
        'gAge': 30,
        'age': 28,
        'fisherScore': 5,
        'fisherScore2': 6,
        'motherName': 'Mother',
        'deviceName': 'Device',
        'doctorName': 'Doctor',
        'patientId': 'p1',
        'organizationId': 'org1',
        'organizationName': 'Org',
        'imageLocalPath': 'local.png',
        'imageFirePath': 'fire.png',
        'audioLocalPath': 'local.mp3',
        'audioFirePath': 'fire.mp3',
        'isImgSynced': true,
        'isAudioSynced': false,
        'bpmEntries': [1, 2],
        'bpmEntries2': [3, 4],
        'mhrEntries': [5],
        'spo2Entries': [6],
        'baseLineEntries': [7],
        'movementEntries': [8],
        'autoFetalMovement': [9],
        'tocoEntries': [10],
        'lengthOfTest': 100,
        'averageFHR': 120,
        'live': true,
        'testByMother': false,
        'testById': 'tb1',
        'interpretationType': 'type',
        'interpretationExtraComments': 'comments',
        'association': jsonEncode({'a': 'b'}),
        'delete': false,
        'createdOn': DateTime.now().toIso8601String(),
        'createdBy': 'creator',
      };
      final t = Test.fromMap(map, 'id');
      expect(t.bpmEntries, [1, 2]);
      expect(t.associations, {'a': 'b'});
    });

    test('fromMap with null lists', () {
      final map = {
        'id': 'id',
        'documentId': null,
        'bpmEntries': null,
        'bpmEntries2': null,
        'mhrEntries': null,
        'spo2Entries': null,
        'baseLineEntries': null,
        'movementEntries': null,
        'autoFetalMovement': null,
        'tocoEntries': null,
        'association': {'x': 'y'},
        'live': null,
        'createdOn': DateTime.now().toIso8601String(),
      };
      final t = Test.fromMap(map, 'id');
      expect(t.bpmEntries, []);
      expect(t.live, false);
      expect(t.associations, {'x': 'y'});
    });

    test('default constructor works', () {
      final t = Test();
      expect(t, isA<Test>());
    });
  });
}
