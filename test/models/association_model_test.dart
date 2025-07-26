import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/association_model.dart';

void main() {
  group('Association', () {
    test('should create an instance with provided values', () {
      var association = Association(
        id: '123',
        name: 'Test Association',
        type: 'Type A',
      );

      expect(association.id, '123');
      expect(association.name, 'Test Association');
      expect(association.type, 'Type A');
    });

    test('should create an instance from a map', () {
      final map = {
        'id': '456',
        'name': 'Another Association',
        'type': 'Type B',
      };

      final association = Association.fromMap(map);

      expect(association.id, '456');
      expect(association.name, 'Another Association');
      expect(association.type, 'Type B');
    });

    test('should handle null or missing values when creating from map', () {
      final map = {'id': '789'};

      final association = Association.fromMap(map);

      expect(association.id, '789');
      expect(association.name, '');
      expect(association.type, '');
    });

    test('should convert an instance to a map', () {
      var association = Association(
        id: 'abc',
        name: 'Map Association',
        type: 'Type C',
      );

      final map = association.toMap();

      expect(map['id'], 'abc');
      expect(map['name'], 'Map Association');
      expect(map['type'], 'Type C');
    });
  });
}