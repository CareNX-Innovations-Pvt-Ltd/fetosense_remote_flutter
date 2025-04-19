import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/ui/views/mothers_details.dart';
import 'package:flutter/material.dart';

import 'graphPainter.dart';

/// A widget that displays an interactive NST (Non-Stress Test) graph with drag functionality.
class Graph extends StatefulWidget {
  /// The test data containing BPM and other measurements.
  final Test test;

  /// The number of grid lines per minute.
  final int? gridPerMin;

  /// The interpretations of the test data.
  Interpretations2? interpretations;

  Graph({required this.test, this.gridPerMin, this.interpretations});

  @override
  GraphState createState() {
    return new GraphState();
  }
}

class GraphState extends State<Graph> {
  /// Horizontal offset for graph scrolling, controlled by drag gestures.
  int mOffset = 0;

  /// Starting x-coordinate of drag gesture.
  double mTouchStart = 0;

  GraphState();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragStart: (DragStartDetails start) =>
            _onDragStart(context, start),
        onHorizontalDragUpdate: (DragUpdateDetails update) =>
            _onDragUpdate(context, update),
        child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: CustomPaint(
              painter: GraphPainter(widget.test, this.mOffset,
                  widget.gridPerMin, widget.interpretations),
            )));
  }

  /// Handles the start of a horizontal drag gesture.
  /// Records initial touch position for calculating drag distance.
  /// [context] is the build context.
  /// [start] contains the drag start details.
  _onDragStart(BuildContext context, DragStartDetails start) {
    print(start.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  /// Handles updates during drag gesture.
  /// Updates graph offset based on drag distance.
  /// [context] is the build context.
  /// [update] contains the drag update details.
  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      this.mOffset = trap(this.mOffset + (newChange / 20).truncate());
    });
    print(this.mOffset.toString());
  }

  /// Constrains the graph offset within valid bounds.
  /// [pos] is the proposed offset value.
  /// Returns clamped offset between 0 and maximum data points.
  int trap(int pos) {
    if (pos < 0)
      return 0;
    else if (pos > widget.test.bpmEntries!.length)
      pos = widget.test.bpmEntries!.length;

    return pos;
  }
}
