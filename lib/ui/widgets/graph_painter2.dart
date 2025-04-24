import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preferences/preference_service.dart';

import '../../core/model/marker_indices.dart';
import '../../core/model/test_model.dart';
import '../../core/utils/intrepretations2.dart';

class GraphPainter2 extends CustomPainter {
  /// Top padding for the graph area.
  late double paddingTop;

  /// Bottom padding for the graph area.
  late double paddingBottom;

  /// Right padding for the graph area.
  late double paddingRight;

  /// Scale factor for the time axis
  late int timeScaleFactor;

  /// Origin x-coordinate for the TOCO graph.
  late double xTocoOrigin;

  /// Origin y-coordinate for the TOCO graph.
  late double yTocoOrigin;

  /// Origin x-coordinate for the graph.
  late double xOrigin;

  /// Origin y-coordinate for the graph.
  late double yOrigin;

  /// Length of the y-axis.
  late double yAxisLength;

  /// Length of the x-axis.
  late double xAxisLength;

  /// Length of each division on the x-axis.
  late double xDivLength;

  /// Number of divisions on the x-axis.
  late int xDiv;

  /// Length of each division on the y-axis.
  late double yDivLength;

  /// End y-coordinate for the TOCO graph.
  late double yTocoEnd;

  /// Number of divisions on the y-axis for the TOCO graph.
  late double yTocoDiv;

  /// Number of divisions on the y-axis for the TOCO graph.
  late int pointsPerDiv;

  /// Number of points per page.
  late int pointsPerPage;

  /// Increment value for each point.
  late double mIncrement;

  /// Number of divisions on the y-axis.
  late double yDiv;

  /// Paint object for major grid lines.
  late Paint graphGridMainLines;

  /// Paint object for minor grid lines.
  late Paint graphGridSubLines;

  /// Paint object for regular grid lines.
  late Paint graphGridLines;

  /// Paint object for graph outlines.
  late Paint graphOutlines;

  /// Paint object for safe zone highlighting.
  late Paint graphSafeZone;

  /// Paint object for unsafe zone highlighting.
  late Paint graphUnSafeZone;

  /// Paint object for noise area highlighting.
  late Paint graphNoiseZone;

  /// Number of grid lines per minute.
  int gridPerMin = 3;

  /// Current scroll offset for horizontal panning.
  int mOffset = 0;

  /// Display mode for FHR (Fetal Heart Rate).
  int displayFhr = 0;

  /// Touch mode flag.
  bool mTouchMode = false;

  /// Paint object for BPM line.
  late Paint graphBpmLine;

  /// Paint object for second BPM line.
  late Paint graphBpmLine2;

  /// Paint object for third BPM line.
  late Paint graphBpmLine3;

  /// Paint object for fourth BPM line.
  late Paint graphBpmLine4;

  /// Paint object for baseline BPM line.
  late Paint graphBaseLine;

  /// Origin value for scaling.
  int scaleOrigin = 40;

  /// Starting x-coordinate for touch gestures.
  late double mTouchStart = 0;

  /// Initial start index for touch gestures.
  late int mTouchInitialStartIndex = 0;

  /// Interpretation results for the graph.
  Interpretations2? interpretations;

  /// Auto mode flag.
  bool auto = true;

  /// Highlight mode flag.
  bool highlight = true;

  /// Offset for FHR2 values.
  int fhr2Offset = 0;

  GraphPainter2(this.test, this.mOffset, this.gridPerMin,
      {this.interpretations, this.displayFhr = 0});

  /// Screen height.
  late double screenHeight;

  /// Screen width.
  late double screenWidth;

  /// Pixels per centimeter.
  late double pixelsPerOneCM;

  /// Pixels per millimeter.
  late double pixelsPerOneMM;

  /// Left offset start for drawing.
  late double leftOffsetStart;

  /// Top offset end for drawing.
  late double topOffsetEnd;

  /// Width of the drawing area.
  late double drawingWidth;

  /// Height of the drawing area.
  late double drawingHeight;

  /// Test data containing BPM, TOCO, and movement measurements.
  Test test;
  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  /// Main paint method that draws the entire graph.
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    screenHeight = size.height;
    screenWidth = size.width;

    pixelsPerOneCM = screenHeight / 16;
    pixelsPerOneMM = pixelsPerOneCM / 10;

    leftOffsetStart = size.width * 0.07;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.93;
    drawingHeight = topOffsetEnd;

    graphGridMainLines = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = pixelsPerOneMM * 0.25;
    graphGridLines = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = pixelsPerOneMM * 0.20;
    graphGridSubLines = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = pixelsPerOneMM * 0.10;
    graphOutlines = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = pixelsPerOneMM * .40;
    graphSafeZone = Paint()
      ..color = const Color.fromARGB(34, 123, 250, 66)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphUnSafeZone = Paint()
      ..color = const Color.fromARGB(90, 250, 30, 0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphNoiseZone = Paint()
      ..color = const Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine = Paint()
      ..color = const Color.fromRGBO(38, 164, 36, 1.0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine2 = Paint()
      ..color = const Color.fromRGBO(12, 227, 16, 1.0)
      ..strokeWidth = pixelsPerOneMM * .30;
    graphBpmLine3 = Paint()
      ..color = const Color.fromRGBO(197, 11, 95, 1.0)
      ..strokeWidth = pixelsPerOneMM * .20;
    graphBpmLine4 = Paint()
      ..color = const Color.fromRGBO(150, 163, 243, 1.0)
      ..strokeWidth = pixelsPerOneMM * .50;
    graphBaseLine = Paint()
      ..color = const Color.fromRGBO(180, 187, 180, 1.0)
      ..strokeWidth = pixelsPerOneMM * .20;

    init(size);

    drawGraph(canvas);
  }

  /// Determines whether the painter should repaint.
  /// [oldDelegate] is the previous painter instance.
  /// Returns true if the painter should repaint, false otherwise.
  @override
  bool shouldRepaint(GraphPainter2 oldDelegate) {
    if (oldDelegate.mOffset != mOffset) {
      return true;
    } else
      return false;
  }

  /// Initializes graph parameters and dimensions.
  /// [size] is the size of the canvas.
  void init(Size size) {
    var paddingLeft = size.width * 0.07;

    paddingTop = pixelsPerOneCM * 0.7;
    paddingBottom = pixelsPerOneMM;
    paddingRight = pixelsPerOneMM * 0.4;

    timeScaleFactor = gridPerMin == 1 ? 6 : 2;

    xTocoOrigin = paddingLeft;
    yTocoOrigin = screenHeight - (paddingBottom);

    xOrigin = paddingLeft;
    yOrigin = screenHeight - (paddingBottom);

    yAxisLength = yOrigin - paddingTop;
    xAxisLength = screenWidth - paddingLeft - paddingRight;

    xDivLength = pixelsPerOneCM;
    xDiv = ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM).truncate();

    yOrigin = yTocoOrigin - xDivLength * 6; // x= 2y

    yDivLength = xDivLength / 2;
    yDiv = (yOrigin - paddingTop) / pixelsPerOneCM * 2;

    yOrigin = yTocoOrigin - yDivLength * 12;

    yTocoEnd = yOrigin + xDivLength;
    yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM * 2;

    pointsPerDiv = (timeScaleFactor * 10);
    pointsPerPage = (pointsPerDiv * xDiv + (pointsPerDiv / 2)).truncate();

    mIncrement = (pixelsPerOneMM / timeScaleFactor);
    //nstTouchMove(offset);
    mOffset = trap(mOffset);
  }

  /// Draws the complete graph.
  /// [canvas] is the canvas to draw on.
  drawGraph(Canvas canvas) {
    auto = PrefService.getBool('liveInterpretations') ?? true;
    highlight = PrefService.getBool('liveHighlight') ?? true;
    fhr2Offset = PrefService.getInt('fhr2Offset') ?? 0;

    if (test.lengthOfTest! > 3600) {
      auto = false;
      highlight = false;
      gridPerMin = 1;
    }

    drawXAxis(canvas);
    drawYAxis(canvas);

    drawTocoXAxis(canvas);
    drawTocoYAxis(canvas);

    //drawBPMLine(canvas, /*interpretations.baselineBpmList*/, graphBaseLine);
    if (displayFhr != 2) {
      drawBPMLine(canvas, test.bpmEntries!, graphBpmLine);
    }
    //drawBPMLine(canvas, [150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142,150, 159, 169, 179,179,166,156,144,134,131,131,142], graphBpmLine);
    if (displayFhr != 1) {
      drawBPMLine(canvas, test.bpmEntries2!, graphBpmLine2,
          bpmOffset: fhr2Offset);
    }
    drawBPMLine(canvas, test.mhrEntries!, graphBpmLine3);
    drawMovements(canvas);
    drawAutoMovements(canvas);
    drawTocoLine(canvas, test.tocoEntries!, graphBpmLine);
    drawTocoLine(canvas, test.spo2Entries!, graphBpmLine4);

    if (interpretations != null && highlight) {
      drawInterpretationAreas(
          canvas, interpretations?.accelerationsList, graphSafeZone);
      drawInterpretationAreas(
          canvas, interpretations?.decelerationsList, graphUnSafeZone);
      drawInterpretationAreas(
          canvas, interpretations?.noiseList, graphNoiseZone);
    }

    // canvas.drawLine(
    //      Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneCM ),
    //      Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneMM * 3),
    //     graphOutlines);
  }

  /// Returns a [ui.Paragraph] object for the given text.
  /// [text] is the text to create the paragraph for.
  /// Returns a [ui.Paragraph] object.
  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: 12.sp, textAlign: TextAlign.right))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: 24.w));
    return paragraph;
  }

  // bool printMin = true;

  /// Draws the main x-axis with grid lines and time labels.
  /// [canvas] is the canvas to draw on.
  void drawXAxis(Canvas canvas) {
    //SafeZone
    int interval = 10;
    int ymin = 50;
    int safeZoneMax = 160;
    Rect safeZoneRect = Rect.fromLTRB(
        xOrigin,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin + xAxisLength,
        yOrigin - yDivLength * 8); //50
    canvas.drawRect(safeZoneRect, graphSafeZone);
    //safe zone end

    canvas.drawLine(Offset(xOrigin + ((xDivLength / 2)), paddingTop),
        Offset(xOrigin + ((xDivLength / 2)), yOrigin), graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(Offset(xOrigin + (xDivLength * i), paddingTop),
          Offset(xOrigin + (xDivLength * i), yOrigin), graphGridLines);

      canvas.drawLine(
          Offset(xOrigin + (xDivLength * i) + ((xDivLength / 2)), paddingTop),
          Offset(xOrigin + (xDivLength * i) + ((xDivLength / 2)), yOrigin),
          graphGridSubLines);
      int offset = (mOffset / pointsPerDiv).truncate();
      if ((i + offset) % gridPerMin == 0) {
        // if (gridPerMin == 1 && printMin) {
        //   canvas.drawParagraph(
        //       getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
        //        Offset(xOrigin + (xDivLength * i) - pixelsPerOneMM * 5,
        //           pixelsPerOneCM * 0.2));
        // } else if (gridPerMin == 3) {
        canvas.drawParagraph(
            getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
            Offset(xOrigin + (xDivLength * i) - pixelsPerOneMM * 5,
                pixelsPerOneCM * 0.2));
        // }
        // printMin = !printMin;
        canvas.drawLine(Offset(xOrigin + (xDivLength * i), paddingTop),
            Offset(xOrigin + (xDivLength * i), yOrigin), graphGridMainLines);
      }
    }
  }

  /// Draws the main y-axis with grid lines and BPM labels.
  /// [canvas] is the canvas to draw on.
  void drawYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(Offset(xOrigin, yOrigin),
        Offset(screenWidth - paddingRight, yOrigin), graphOutlines);
    canvas.drawLine(Offset(xOrigin, paddingTop),
        Offset(screenWidth - paddingRight, paddingTop), graphOutlines);

    int interval = 10;
    int ymin = 50;

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).truncate().toString()),
            Offset(pixelsPerOneMM * 2,
                yOrigin - (yDivLength * i + (pixelsPerOneMM * 3))));

        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);

        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Draws the TOCO x-axis with grid lines.
  /// [canvas] is the canvas to draw on.
  void drawTocoXAxis(Canvas canvas) {
    //int numberOffset = XDIV*(pageNumber);
    for (int j = 1; j < 2; j++) {
      canvas.drawLine(
          Offset(xOrigin + ((xDivLength / 2) * j), yTocoEnd),
          Offset(xOrigin + ((xDivLength / 2) * j), yTocoOrigin),
          graphGridSubLines);
    }

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(Offset(xOrigin + (xDivLength * i), yTocoEnd),
          Offset(xOrigin + (xDivLength * i), yTocoOrigin), graphGridLines);

      //for (int j = 1; j < 2; j++) `{
      canvas.drawLine(
          Offset(xOrigin + (xDivLength * i) + ((xDivLength / 2)), yTocoEnd),
          Offset(xOrigin + (xDivLength * i) + ((xDivLength / 2)), yTocoOrigin),
          graphGridSubLines);
      //}

      if ((i + mOffset / 60) % gridPerMin == 0) {
        canvas.drawLine(
            Offset(xOrigin + (xDivLength * i), yTocoEnd),
            Offset(xOrigin + (xDivLength * i), yTocoOrigin),
            graphGridMainLines);
      }
    }
  }

  /// Draws the TOCO y-axis with grid lines and pressure labels.
  /// [canvas] is the canvas to draw on.
  void drawTocoYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(Offset(xOrigin, yTocoOrigin),
        Offset(screenWidth - paddingRight, yTocoOrigin), graphOutlines);
    canvas.drawLine(Offset(xOrigin, yTocoEnd),
        Offset(screenWidth - paddingRight, yTocoEnd), graphOutlines);

    int interval = 10;
    int ymin = 10;

    for (int i = 1; i <= yTocoDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).toString()),
            Offset(pixelsPerOneMM * 2,
                yTocoOrigin - (yDivLength * i + (pixelsPerOneMM * 3))));

        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Draws data points and connecting lines for BPM measurements.
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of BPM values.
  /// [lineStyle] is the paint style for the line.
  /// [bpmOffset] is the optional offset for BPM values.
  void drawBPMLine(Canvas canvas, List<int> list, Paint lineStyle,
      {int bpmOffset = 0}) {
    if (list.length <= 0) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    for (; i < list.length - 1 && i < (mOffset + pointsPerPage); i++) {
      startData = stopData;
      stopData = list[i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenX(i);
      stopY = getYValueFromBPM(list[i] + bpmOffset); // getScreenY(stopData);

      if (i < 1) continue;
      if (startData == 0 ||
          stopData == 0 ||
          startData > 210 ||
          stopData > 210 ||
          (startData - stopData).abs() > 30) {
        continue;
      }

      // a. If the value is 0, it is not drawn
      // b. If the results of the two values before and after are different by more than 30, they are not connected.

      canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), lineStyle);
    }
  }

  /// Draws movement markers on the graph.
  /// [canvas] is the canvas to draw on.
  void drawMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int> movementList = test.movementEntries!;
    if (movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2),
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 4)),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM * 2),
            Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM,
                yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 2)),
            graphOutlines);
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws auto-detected movement markers on the graph.
  /// [canvas] is the canvas to draw on.
  void drawAutoMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int> movementList = test.autoFetalMovement!;
    if (movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM),
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneMM * 3),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM),
            Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM +
                    pixelsPerOneMM,
                yOrigin - pixelsPerOneMM * 7),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM + pixelsPerOneMM * 7),
            Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM +
                    pixelsPerOneMM,
                yOrigin - pixelsPerOneMM * 5),
            graphOutlines);
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws data points and connecting lines for TOCO measurements.
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of TOCO values.
  /// [lineStyle] is the paint style for the line.
  void drawTocoLine(Canvas canvas, List<int> list, Paint lineStyle) {
    if (list.isEmpty) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    stopX = getScreenXToco(i);
    stopY = getYValueFromToco(list[i]);
    for (; i < list.length - 1 && i < (mOffset + pointsPerPage); i++) {
      startData = stopData;
      stopData = list[i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenXToco(i);
      stopY = getYValueFromToco(list[i]); // getScreenY(stopData);

      if (i < 1) continue;
      if ((startData - stopData).abs() > 80) {
        continue;
      }
      /*if (Math.abs(startData - stopData) > 150) {
                continue;
            }*/

      // a. If the value is 0, it is not drawn
      // b. If the results of the two values before and after are different by more than 30, they are not connected.

      canvas.drawLine(Offset(startX, startY), Offset(stopX, stopY), lineStyle);
    }
  }

  /// Draws interpretation areas on the graph.
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of marker indices.
  /// [zoneStyle] is the paint style for the zone.
  void drawInterpretationAreas(
      Canvas canvas, List<MarkerIndices>? list, Paint? zoneStyle) {
    if (list == null || list.isEmpty) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {
      startX = getScreenX(list[i].getFrom()!);
      stopX = getScreenX(list[i].getTo()!);
      debugPrint("drawInterpretationAreas $startX, $stopX, $xOrigin");
      if (stopX < xOrigin) {
        continue;
      }

      if (startX < xOrigin) {
        startX = xOrigin;
      }
      //Marker
      Rect zoneRect =
          Rect.fromLTRB(startX, paddingTop, stopX, yTocoOrigin); //50
      canvas.drawRect(zoneRect, zoneStyle!);
    }
  }

  /*void drawInterpretationAreas(
      Canvas canvas, List<MarkerIndices> list, Paint zoneStyle) {
    if (list == null || list.length <= 0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {
      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());

      //Marker
      Rect zoneRect =
           Rect.fromLTRB(startX, paddingTop, stopX, yTocoOrigin); //50
      canvas.drawRect(zoneRect, zoneStyle);
    }
  }*/

/*  void drawDecelerationAreas(Canvas canvas,List<MarkerIndices> list) {
    if (list == null || list.length<=0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {

      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());


      //Marker
      Rect zoneRect =  Rect.fromLTRB(startX,
          paddingTop,
          stopX,
          yTocoOrigin );//50
      canvas.drawRect(zoneRect, graphSafeZone);
    }
  }

  void drawNoiseAreas(Canvas canvas,List<MarkerIndices> list) {
    if (list == null || list.length<=0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {

      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());


      //Marker
      Rect zoneRect =  Rect.fromLTRB(startX,
          paddingTop,
          stopX,
          yTocoOrigin );//50
      canvas.drawRect(zoneRect, graphSafeZone);
    }
  }*/

  /// Calculates screen x-coordinate from data index.
  /// [i] is the data index.
  /// Returns the x-coordinate on the screen.
  double getScreenX(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }

  /// Calculates screen x-coordinate for TOCO data from data index.
  /// [i] is the data index.
  /// Returns the x-coordinate on the screen.
  double getScreenXToco(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }

  /// Converts BPM value to screen y-coordinate.
  /// [bpm] is the BPM value.
  /// Returns the y-coordinate on the screen.
  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yOrigin - (adjustedBPM * pixelsPerOneMM);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Converts TOCO value to screen y-coordinate.
  /// [bpm] is the TOCO value.
  /// Returns the y-coordinate on the screen.
  double getYValueFromToco(int bpm) {
    double adjustedBPM = bpm.toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yTocoOrigin - (adjustedBPM * pixelsPerOneMM);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Ensures offset stays within valid range.
  /// [pos] is the proposed offset value.
  /// Returns clamped offset between 0 and maximum data points.
  int trap(int pos) {
    if (pos < 0) return 0;
    int max = test.bpmEntries!.length + pointsPerDiv - pointsPerPage;
    if (max < 0) max = 0;

    if (pos > max) pos = max;

    if (pos != 0) pos = pos - (pos % pointsPerDiv);

    print("$pos   $pointsPerPage   $pointsPerDiv");

    return pos;
  }
}
