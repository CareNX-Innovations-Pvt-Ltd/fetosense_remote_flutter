import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/widgets/graph_painter.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/model/marker_indices.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';

class DummyMarkerIndices extends MarkerIndices {
  DummyMarkerIndices(int fromVal, int toVal) {
    from = fromVal;
    to = toVal;
  }

  @override
  int getFrom() => from!;

  @override
  int getTo() => to!;
}

class DummyInterpretations extends Interpretations2 {
  @override
  List<MarkerIndices> getAccelerationsList() => [DummyMarkerIndices(0, 5)];

  @override
  List<MarkerIndices> getDecelerationsList() => [DummyMarkerIndices(10, 15)];

  @override
  List<MarkerIndices> getNoiseAreaList() => [DummyMarkerIndices(20, 25)];
}

void main() {
  final test1 = Test.withData(
    bpmEntries: List.generate(100, (i) => 120 + (i % 5)),
    bpmEntries2: List.generate(100, (i) => 100 + (i % 3)),
    tocoEntries: List.generate(100, (i) => 30 + (i % 4)),
    movementEntries: [10, 20, 30],
    autoFetalMovement: [15, 25, 35],
  );

  final dummyInterpretations = DummyInterpretations();

  testWidgets('GraphPainter logic methods', (tester) async {
    final painter = GraphPainter(test1, 0, 3, dummyInterpretations);
    final size = const Size(360, 640);
    final canvas = Canvas(PictureRecorder());

    painter.paint(canvas, size);

    expect(painter.getScreenX(10), isA<double>());
    expect(painter.getScreenXToco(10), isA<double>());
    expect(painter.getYValueFromBPM(120), isA<double>());
    expect(painter.getYValueFromToco(60), isA<double>());
    expect(painter.trap(-10), equals(0));
  });

  test('trap clamps offset correctly', () {
    final painter = GraphPainter(test1, 0, 3, dummyInterpretations);
    painter.pointsPerDiv = 20;
    painter.pointsPerPage = 60;

    final result = painter.trap(1000); // Excessive offset
    expect(result, isNonNegative);
    expect(result <= test1.bpmEntries!.length + 20 - 60, isTrue);
  });

  test('getScreenX and getScreenXToco calculate correctly', () {
    final painter = GraphPainter(test1, 0, 3, dummyInterpretations);
    painter.xOrigin = 50;
    painter.mIncrement = 2;
    painter.mOffset = 0;

    expect(painter.getScreenX(0), equals(52));
    expect(painter.getScreenXToco(10), equals(72));
  });

  test('getYValueFromBPM scales BPM correctly', () {
    final painter = GraphPainter(test1, 0, 3, dummyInterpretations);
    painter.yOrigin = 400;
    painter.pixelsPerOneMM = 2.0;
    painter.scaleOrigin = 40;

    final y = painter.getYValueFromBPM(120); // → (120-40)/2 * 2 = 80 → 400-80 = 320
    expect(y, equals(320));
  });

  test('getYValueFromToco scales TOCO correctly', () {
    final painter = GraphPainter(test1, 0, 3, dummyInterpretations);
    painter.yTocoOrigin = 500;
    painter.pixelsPerOneMM = 2.0;

    final y = painter.getYValueFromToco(60); // → 60/2 * 2 = 60 → 500 - 60 = 440
    expect(y, equals(440));
  });

  test('shouldRepaint returns true only if mOffset changed', () {
    final painter1 = GraphPainter(test1, 0, 3, dummyInterpretations);
    final painter2 = GraphPainter(test1, 10, 3, dummyInterpretations);
    final painter3 = GraphPainter(test1, 0, 3, dummyInterpretations);

    expect(painter1.shouldRepaint(painter2), isTrue);
    expect(painter1.shouldRepaint(painter3), isFalse);
  });
}
