import 'package:fetosense_remote_flutter/core/model/marker_indices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkerIndices', () {
    test('Default constructor initializes with null values', () {
      final marker = MarkerIndices();
      expect(marker.from, isNull);
      expect(marker.to, isNull);
    });

    test('fromData constructor sets values correctly', () {
      final marker = MarkerIndices.fromData(10, 20);
      expect(marker.from, 10);
      expect(marker.to, 20);
    });

    test('setFrom sets the from value correctly', () {
      final marker = MarkerIndices();
      marker.setFrom(15);
      expect(marker.from, 15);
    });

    test('setTo sets the to value correctly', () {
      final marker = MarkerIndices();
      marker.setTo(25);
      expect(marker.to, 25);
    });

    test('getFrom returns correct value when set', () {
      final marker = MarkerIndices();
      marker.setFrom(5);
      expect(marker.getFrom(), 5);
    });

    test('getTo returns correct value when set', () {
      final marker = MarkerIndices();
      marker.setTo(30);
      expect(marker.getTo(), 30);
    });

    test('getFrom throws error if from is null', () {
      final marker = MarkerIndices();
      expect(() => marker.getFrom(), throwsA(isA<TypeError>())); // or throwsA(isA<StateError>()) based on runtime
    });

    test('getTo throws error if to is null', () {
      final marker = MarkerIndices();
      expect(() => marker.getTo(), throwsA(isA<TypeError>()));
    });
  });
}
