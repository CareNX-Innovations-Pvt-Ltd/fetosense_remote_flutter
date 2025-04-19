import 'dart:ui' as ui;

import 'package:fetosense_remote_flutter/core/model/marker_indices.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:flutter/material.dart';

class GraphPainterTV extends CustomPainter {
  final Test? test;

  late double paddingTop;

  double? paddingBottom;

  late double paddingRight;

  late int timeScaleFactor;

  double? xTocoOrigin;

  late double yTocoOrigin;

  late double xOrigin;

  late double yOrigin;

  double? yAxisLength;

  late double xAxisLength;

  double? xDivLength;

  late int xDiv;

  late double yDivLength;

  late double yTocoEnd;

  late double yTocoDiv;

  late int pointsPerDiv;

  late int pointsPerPage;

  late double mIncrement;

  late double yDiv;

  late Paint graphGridMainLines;

  late Paint graphGridSubLines;

  late Paint graphGridLines;

  late Paint graphOutlines;

  Paint? graphSafeZone;
  Paint? graphUnSafeZone;
  Paint? graphNoiseZone;

  int gridPerMin = 3;
  int mOffset = 0;

  bool mTouchMode = false;

  Paint? graphBpmLine;
  Paint? graphBaseLine;
  int scaleOrigin = 40;

  double mTouchStart = 0;

  int mTouchInitialStartIndex = 0;

  Interpretations2? interpretations;

  GraphPainterTV(
      this.test, this.mOffset, this.gridPerMin, this.interpretations);

  late double screenHeight;
  late double screenWidth;
  double? pixelsPerOneCM;
  double? pixelsPerOneMM;

  double? leftOffsetStart;
  double? topOffsetEnd;
  double? drawingWidth;
  double? drawingHeight;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  /// Paints the graph on the given canvas with the specified size.
  ///
  /// [canvas] is the canvas to draw on.
  /// [size] is the size of the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    screenHeight = size.height;
    screenWidth = size.width;

    pixelsPerOneCM = screenHeight / 16;
    pixelsPerOneMM = pixelsPerOneCM! / 10;

    leftOffsetStart = size.width * 0.07;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.93;
    drawingHeight = topOffsetEnd;

    graphGridMainLines = new Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.65;
    graphGridLines = new Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.40;
    graphGridSubLines = new Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.20;
    graphOutlines = new Paint()
      ..color = Colors.black
      ..strokeWidth = pixelsPerOneMM! * .80;
    graphSafeZone = new Paint()
      ..color = Color.fromARGB(40, 100, 200, 0)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphUnSafeZone = new Paint()
      ..color = Color.fromARGB(40, 250, 30, 0)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphNoiseZone = new Paint()
      ..color = Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphBpmLine = new Paint()
      ..color = Colors.blue
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphBaseLine = new Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = pixelsPerOneMM! * .50;

    init(size);

    drawGraph(canvas);
  }

  /// Determines whether the painter should repaint.
  ///
  /// [oldDelegate] is the previous painter.
  ///
  /// Returns true if the painter should repaint, false otherwise.
  @override
  bool shouldRepaint(GraphPainterTV oldDelegate) {
    if (oldDelegate.mOffset != mOffset) {
      return true;
    } else
      return false;
  }

  /// Initializes the graph settings based on the given size.
  ///
  /// [size] is the size of the canvas.
  void init(Size size) {
    var paddingLeft = size.width * 0.07;

    paddingTop = pixelsPerOneCM! * 0.3;
    paddingBottom = pixelsPerOneMM;
    paddingRight = pixelsPerOneMM! * 2;

    timeScaleFactor = this.gridPerMin == 1 ? 6 : 2;

    xTocoOrigin = paddingLeft;
    yTocoOrigin = screenHeight - paddingBottom!;

    xOrigin = paddingLeft;
    yOrigin = screenHeight - paddingBottom!;

    yAxisLength = yOrigin - paddingTop;
    xAxisLength = screenWidth - paddingLeft - paddingRight;

    xDivLength = pixelsPerOneCM;
    xDiv = ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM!).truncate();

    yOrigin = yTocoOrigin - xDivLength! * 6; // x= 2y

    yDivLength = xDivLength! / 2;
    yDiv = (yOrigin - paddingTop) / pixelsPerOneCM! * 2;

    yOrigin = yTocoOrigin - yDivLength * 12;

    yTocoEnd = yOrigin + xDivLength!;
    yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM! * 2;

    pointsPerDiv = (timeScaleFactor * 10);
    pointsPerPage = (pointsPerDiv * xDiv + (pointsPerDiv / 2)).truncate();

    mIncrement = (pixelsPerOneMM! / timeScaleFactor);
    //nstTouchMove(offset);
    mOffset = trap(mOffset);
  }

  /// Draws the graph on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  drawGraph(Canvas canvas) {
    drawXAxis(canvas);
    drawYAxis(canvas);

    drawTocoXAxis(canvas);
    drawTocoYAxis(canvas);

    drawBPMLine(canvas, interpretations!.baselineBpmList, graphBaseLine);
    drawBPMLine(canvas, test!.bpmEntries, graphBpmLine);
    drawMovements(canvas);
    drawAutoMovements(canvas);
    drawTocoLine(canvas);

    drawInterpretationAreas(
        canvas, interpretations!.getAccelerationsList(), graphSafeZone);
    drawInterpretationAreas(
        canvas, interpretations!.getDecelerationsList(), graphUnSafeZone);
    drawInterpretationAreas(
        canvas, interpretations!.getNoiseAreaList(), graphNoiseZone);
  }

  /// Returns a [ui.Paragraph] object for the given text.
  ///
  /// [text] is the text to create the paragraph for.
  ///
  /// Returns a [ui.Paragraph] object.
  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 8.0, textAlign: TextAlign.right))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 20));
    return paragraph;
  }

  bool printMin = true;

  /// Draws the X-axis on the given canvas.
  ///
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
    canvas.drawRect(safeZoneRect, graphSafeZone!);
    //safe zone end

    canvas.drawLine(new Offset(xOrigin + xDivLength! / 2, paddingTop),
        new Offset(xOrigin + xDivLength! / 2, yOrigin), graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(new Offset(xOrigin + (xDivLength! * i), paddingTop),
          new Offset(xOrigin + (xDivLength! * i), yOrigin), graphGridLines);

      canvas.drawLine(
          new Offset(
              xOrigin + (xDivLength! * i) + xDivLength! / 2, paddingTop),
          new Offset(xOrigin + (xDivLength! * i) + xDivLength! / 2, yOrigin),
          graphGridSubLines);
      int offset = (mOffset / pointsPerDiv).truncate();
      if ((i + offset) % gridPerMin == 0) {
        if (gridPerMin == 1 && printMin) {
          canvas.drawParagraph(
              getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
              new Offset(xOrigin + (xDivLength! * i) - pixelsPerOneCM! * 1.5,
                  pixelsPerOneCM! * 0.2));
        } else if (gridPerMin == 3) {
          canvas.drawParagraph(
              getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
              new Offset(xOrigin + (xDivLength! * i) - pixelsPerOneCM! * 1.5,
                  pixelsPerOneCM! * 0.2));
        }
        printMin = !printMin;
        canvas.drawLine(
            new Offset(xOrigin + (xDivLength! * i), paddingTop),
            new Offset(xOrigin + (xDivLength! * i), yOrigin),
            graphGridMainLines);
      }
    }
  }


  /// Draws the Y-axis on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(new Offset(xOrigin, yOrigin),
        new Offset(screenWidth - paddingRight, yOrigin), graphOutlines);
    canvas.drawLine(new Offset(xOrigin, paddingTop),
        new Offset(screenWidth - paddingRight, paddingTop), graphOutlines);

    int interval = 10;
    int ymin = 50;

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            new Offset(xOrigin, yOrigin - (yDivLength * i)),
            new Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).truncate().toString()),
            new Offset(pixelsPerOneMM! * 2,
                yOrigin - (yDivLength * i + (pixelsPerOneMM! * 3))));

        canvas.drawLine(
            new Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            new Offset(xOrigin, yOrigin - (yDivLength * i)),
            new Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);

        canvas.drawLine(
            new Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }


  /// Draws the TOCO X-axis on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawTocoXAxis(Canvas canvas) {
    //int numberOffset = XDIV*(pageNumber);
    for (int j = 1; j < 2; j++) {
      canvas.drawLine(
          new Offset(xOrigin + ((xDivLength! / 2) * j), yTocoEnd),
          new Offset(xOrigin + ((xDivLength! / 2) * j), yTocoOrigin),
          graphGridSubLines);
    }

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(new Offset(xOrigin + (xDivLength! * i), yTocoEnd),
          new Offset(xOrigin + (xDivLength! * i), yTocoOrigin), graphGridLines);

      //for (int j = 1; j < 2; j++) `{
      canvas.drawLine(
          new Offset(xOrigin + (xDivLength! * i) + xDivLength! / 2, yTocoEnd),
          new Offset(
              xOrigin + (xDivLength! * i) + xDivLength! / 2, yTocoOrigin),
          graphGridSubLines);
      //}

      if ((i + mOffset / 60) % gridPerMin == 0) {
        canvas.drawLine(
            new Offset(xOrigin + (xDivLength! * i), yTocoEnd),
            new Offset(xOrigin + (xDivLength! * i), yTocoOrigin),
            graphGridMainLines);
      }
    }
  }


  /// Draws the TOCO Y-axis on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawTocoYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(new Offset(xOrigin, yTocoOrigin),
        new Offset(screenWidth - paddingRight, yTocoOrigin), graphOutlines);
    canvas.drawLine(new Offset(xOrigin, yTocoEnd),
        new Offset(screenWidth - paddingRight, yTocoEnd), graphOutlines);

    int interval = 10;
    int ymin = 10;

    for (int i = 1; i <= yTocoDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            new Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            new Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).toString()),
            new Offset(pixelsPerOneMM! * 2,
                yTocoOrigin - (yDivLength * i + (pixelsPerOneMM! * 3))));

        canvas.drawLine(
            new Offset(
                xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            new Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            new Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas.drawLine(
            new Offset(
                xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }


  /// Draws the BPM line on the given canvas with the specified list and line style.
  ///
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of BPM values.
  /// [lineStyle] is the paint style to use for the line.
  void drawBPMLine(Canvas canvas, List<int>? list, Paint? lineStyle) {
    if (list == null || list.length <= 0) {
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
      stopY = getYValueFromBPM(list[i]); // getScreenY(stopData);

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

      canvas.drawLine(
          new Offset(startX, startY), new Offset(stopX, stopY), lineStyle!);
    }
  }


  /// Draws the movements on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int>? movementList = test!.movementEntries;
    if (movementList == null || movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM! / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            new Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2),
            new Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 4)),
            graphOutlines);
        canvas.drawLine(
            new Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2),
            new Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM!,
                yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 2)),
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


  /// Draws the auto movements on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawAutoMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int>? movementList = test!.autoFetalMovement;
    if (movementList == null || movementList.length <= 0) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM! / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            new Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
            new Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneMM! * 3),
            graphOutlines);
        canvas.drawLine(
            new Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
            new Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM! +
                    pixelsPerOneMM!,
                yOrigin - pixelsPerOneMM! * 7),
            graphOutlines);
        canvas.drawLine(
            new Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM! * 7),
            new Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM! +
                    pixelsPerOneMM!,
                yOrigin - pixelsPerOneMM! * 5),
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


  /// Draws the TOCO line on the given canvas.
  ///
  /// [canvas] is the canvas to draw on.
  void drawTocoLine(Canvas canvas) {
    if (test!.tocoEntries == null || test!.tocoEntries!.length <= 0) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    stopX = getScreenXToco(i);
    stopY = getYValueFromToco(test!.tocoEntries![i]);
    for (;
        i < test!.tocoEntries!.length - 1 && i < (mOffset + pointsPerPage);
        i++) {
      startData = stopData;
      stopData = test!.tocoEntries![i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenXToco(i);
      stopY = getYValueFromToco(test!.tocoEntries![i]); // getScreenY(stopData);

      if (i < 1) continue;
      /*if (Math.abs(startData - stopData) > 150) {
                continue;
            }*/

      // a. If the value is 0, it is not drawn
      // b. If the results of the two values before and after are different by more than 30, they are not connected.

      canvas.drawLine(
          new Offset(startX, startY), new Offset(stopX, stopY), graphBpmLine!);
    }
  }


  /// Draws the interpretation areas on the given canvas with the specified list and zone style.
  ///
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of marker indices.
  /// [zoneStyle] is the paint style to use for the interpretation areas.
  void drawInterpretationAreas(
      Canvas canvas, List<MarkerIndices>? list, Paint? zoneStyle) {
    if (list == null || list.length <= 0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {
      startX = getScreenX(list[i].getFrom()!);
      stopX = getScreenX(list[i].getTo()!);

      //Marker
      Rect zoneRect =
          new Rect.fromLTRB(startX, paddingTop, stopX, yTocoOrigin); //50
      canvas.drawRect(zoneRect, zoneStyle!);
    }
  }

/*  void drawDecelerationAreas(Canvas canvas,List<MarkerIndices> list) {
    if (list == null || list.length<=0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {

      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());


      //Marker
      Rect zoneRect = new Rect.fromLTRB(startX,
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
      Rect zoneRect = new Rect.fromLTRB(startX,
          paddingTop,
          stopX,
          yTocoOrigin );//50
      canvas.drawRect(zoneRect, graphSafeZone);
    }
  }*/


  /// Returns the X-coordinate on the screen for the given index.
  ///
  /// [i] is the index of the data point.
  ///
  /// Returns the X-coordinate on the screen.
  double getScreenX(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }


  /// Returns the X-coordinate on the screen for the TOCO graph for the given index.
  ///
  /// [i] is the index of the data point.
  ///
  /// Returns the X-coordinate on the screen.
  double getScreenXToco(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }


  /// Returns the Y-coordinate on the screen for the given BPM value.
  ///
  /// [bpm] is the BPM value.
  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }


  /// Returns the Y-coordinate on the screen for the given TOCO value.
  ///
  /// [bpm] is the TOCO value.
  double getYValueFromToco(int bpm) {
    double adjustedBPM = bpm.toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yTocoOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }


  /// Adjusts the given position to be within valid bounds.
  ///
  /// [pos] is the position to adjust.
  ///
  /// Returns the adjusted position.
  int trap(int pos) {
    if (pos < 0) return 0;
    int max = test!.bpmEntries!.length + pointsPerDiv - pointsPerPage;
    if (max < 0) max = 0;

    if (pos > max) pos = max;

    if (pos != 0) pos = pos - (pos % pointsPerDiv);

    print(pos.toString() +
        "   " +
        pointsPerPage.toString() +
        "   " +
        pointsPerDiv.toString());

    return pos;
  }
}
