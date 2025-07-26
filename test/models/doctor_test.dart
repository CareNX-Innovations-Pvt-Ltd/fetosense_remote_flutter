import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';

void main() {
  group('Doctor Model Tests', () {
    test('Default constructor creates a Doctor with default values', () {
      final doctor = Doctor();
      expect(doctor.name, null);
      expect(doctor.email, null);
      expect(doctor.documentId, null);
      expect(doctor.noOfMother, 0);
      expect(doctor.noOfTests, 0);
    });

    test('Constructor with data creates a Doctor with provided values', () {
      final doctor = Doctor(
        name: 'Dr. Smith',
        email: 'smith@example.com',
        documentId: 'doc123',
        noOfMother: 10,
        noOfTests: 50,
      );
      expect(doctor.name, 'Dr. Smith');
      expect(doctor.email, 'smith@example.com');
      expect(doctor.documentId, 'doc123');
      expect(doctor.noOfMother, 10);
      expect(doctor.noOfTests, 50);
    });

    test('fromMap factory creates a Doctor from a map', () {
      final map = {
        'name': 'Dr. Jones',
        'email': 'jones@example.com',
        'documentId': 'doc456',
        'noOfMother': 20,
        'noOfTests': 100,
      };
      final doctor = Doctor.fromMap(map);
      expect(doctor.name, 'Dr. Jones');
      expect(doctor.email, 'jones@example.com');
      expect(doctor.documentId, 'doc456');
      expect(doctor.noOfMother, 20);
      expect(doctor.noOfTests, 100);
    });

    test('fromJson factory creates a Doctor from a JSON map', () {
      final json = {
        'name': 'Dr. Brown',
        'email': 'brown@example.com',
        'documentId': 'doc789',
        'noOfMother': 30,
        'noOfTests': 150,
      };
      final doctor = Doctor.fromJson(json);
      expect(doctor.name, 'Dr. Brown');
      expect(doctor.email, 'brown@example.com');
      expect(doctor.documentId, 'doc789');
      expect(doctor.noOfMother, 30);
      expect(doctor.noOfTests, 150);
    });
  });
}