import 'package:fetosense_remote_flutter/core/model/marker_indices.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:preferences/preferences.dart';

const directoryName = 'fetosense';

/// [FhrPdfView] is a class responsible for generating and managing the PDF view of the FHR (Fetal Heart Rate) data.
/// It handles the creation of graphs, drawing of lines, and saving images to files.
class FhrPdfView {
  var WIDTH_PX = 2620;
  var HEIGHT_PX = 1770;

  double? pixelsPerOneMM;
  double? pixelsPerOneCM;

  double touched_down = 0;
  double touched_up = 0;
  late Paint graphOutlines;
  late Paint graphMovement;
  late Paint graphGridLines;
  Paint? graphBackGround;
  Paint? graphSafeZone;
  Paint? graphUnSafeZone;
  Paint? graphNoiseZone;
  Paint? graphAxisText;
  late Paint graphGridSubLines;
  late double yDivLength;
  late double yOrigin;
  late double axisFontSize;
  double? paddingLeft;
  double? paddingTop;
  double? paddingBottom;
  double? paddingRight;
  double? xOrigin;
  Paint? graphBpmLine;
  double? xDivLength;
  late int xDiv;
  late int screenHeight;
  late int screenWidth;
  late double xAxisLength;
  late double yDiv;
  double? yAxisLength;
  late List<Canvas> canvas;
  late List<ui.PictureRecorder> recorder;
  late List<ui.Image> images;
  List<String>? paths;
  late int timeScaleFactor;
  late int pointsPerPage;
  Paint? informationText;
  int XDIV = 20;
  int? pointsPerDiv;
  Test? mData;
  double? xTocoOrigin;
  late double yTocoOrigin;
  late double yTocoEnd;
  late double yTocoDiv;

  Interpretations2? interpretation;

  int? scale;

  late bool comments;
  late bool auto;
  late bool highlight;

  /// Initializes the [FhrPdfView] with the given length of the test.
  /// [lengthOfTest] is the duration of the test in seconds.
  FhrPdfView(int lengthOfTest) {
    initialize(lengthOfTest);
  }

  /// Generates the NST (Non-Stress Test) graph and returns a list of file paths to the generated images.
  /// [data] contains the test data.
  /// [_interpretation] is the interpretation data.
  /// Returns a [Future] that completes with a list of file paths to the generated images.
  Future<List<String>?> getNSTGraph(
      Test? data, Interpretations2? _interpretation) async {
    this.mData = data;
    if (mData!.lengthOfTest! > 3600) {
      auto = false;
      scale = 1;
      timeScaleFactor = 6;
    }

    this.interpretation = _interpretation;

    pointsPerPage = (10 * timeScaleFactor * XDIV);
    pointsPerDiv = timeScaleFactor * 10;
    int pages = (mData!.bpmEntries!.length / pointsPerPage).truncate();
    //pages += 1;
    if (mData!.bpmEntries!.length % pointsPerPage > 20) pages++;
    //pages++;
    //bitmaps = new Bitmap[pages];
    recorder = <ui.PictureRecorder>[];
    canvas = <Canvas>[];
    images = <ui.Image>[];
    paths = <String>[];
    for (int i = 0; i < pages; i++) {
      recorder.add(ui.PictureRecorder());
      canvas.add(Canvas(
          recorder[i],
          Rect.fromPoints(Offset(0.0, 0.0),
              Offset(WIDTH_PX.toDouble(), HEIGHT_PX.toDouble()))));
      canvas.last.scale(0.3,0.3);
    }

    drawGraph(pages);
    //drawBpmLine(bpmList, pages);
    drawLine(mData!.bpmEntries, pages, graphBpmLine);
    //await drawLine(interpretation.baselineBpmList,pages,graphBpmLine);
    drawTocoLine(mData!.tocoEntries, pages);
    drawMovements(mData!.movementEntries, pages);
    drawAutoMovements(mData!.autoFetalMovement, pages);
    //return bitmaps;

    if (interpretation != null && auto && highlight) {
      drawInterpretationAreas(
          interpretation!.getAccelerationsList(), pages, graphSafeZone);
      drawInterpretationAreas(
          interpretation!.getDecelerationsList(), pages, graphUnSafeZone);
      drawInterpretationAreas(
          interpretation!.getNoiseAreaList(), pages, graphNoiseZone);
    }

    for (int i = 0; i < pages; i++) {
      final picture = recorder[i].endRecording();
      images.add(await picture.toImage(WIDTH_PX, HEIGHT_PX));
      paths!.add(await saveImage(i));
    }
    return paths;
  }

  /// Saves the generated image to a file and returns the file path.
  /// [i] is the index of the image to save.
  /// Returns a [Future] that completes with the file path of the saved image.
  Future<String> saveImage(int i) async {
    var pngBytes = (await images[i].toByteData(format: ui.ImageByteFormat.png))!;
    // Use plugin [path_provider] to export image to storage
    io.Directory directory = await getTemporaryDirectory();
    String path = directory.path;
    print(path);
    await io.Directory('$path/$directoryName').create(recursive: true);
    var file = io.File('$path/$directoryName/temp${i}.png');
    file.writeAsBytesSync(pngBytes.buffer.asInt8List());
    print(file.path);
    return file.path;
  }

  /// Initializes the graph settings based on the length of the test and user preferences.
  /// [lengthOfTest] is the duration of the test in seconds.
  void initialize(int lengthOfTest) {
    this.scale = PrefService.getInt('scale') ?? 1;
    this.comments = PrefService.getBool('comments') ?? false;
    this.auto = PrefService.getBool('interpretations') ?? false;
    this.highlight = PrefService.getBool('highlight') ?? false;
    if (lengthOfTest < 180 || lengthOfTest > 3600) {
      this.auto = false;
      this.highlight = false;
      this.scale = 1;
    }

    timeScaleFactor = scale == 3 ? 2 : 6;
    //timeScaleFactor = 6;

    pixelsPerOneCM = 100;
    pixelsPerOneMM = 10;

    /*graphGridMainLines = new Paint()
      ..color = Colors.grey[400]
      ..strokeWidth = 1.5;*/
    graphGridLines = new Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.1;
    graphGridSubLines = new Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 0.6;
    graphOutlines = new Paint()
      ..color = Colors.black
      ..strokeWidth = 2.25;
    graphMovement = new Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    graphSafeZone = new Paint()
      ..color = Color.fromARGB(20, 100, 200, 0)
      ..strokeWidth = 1.0;
    graphUnSafeZone = new Paint()
      ..color = Color.fromARGB(40, 250, 30, 0)
      ..strokeWidth = 1.0;
    graphNoiseZone = new Paint()
      ..color = Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = 1.0;
    graphBpmLine = new Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.75;

    graphAxisText = new Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.75;

    informationText = new Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.75;

    axisFontSize = pixelsPerOneMM! * 5;

    paddingLeft = HEIGHT_PX / 3;
    paddingTop = pixelsPerOneMM;
    paddingBottom = pixelsPerOneCM;
    paddingRight = pixelsPerOneMM;
  }

  /// Draws the graph for the given number of pages.
  /// [pages] is the number of pages to draw.
  void drawGraph(int pages) {
    screenHeight = HEIGHT_PX; //canvas.getHeight();//1440
    screenWidth = WIDTH_PX; //canvas.getWidth();//2560

    xTocoOrigin = paddingLeft;
    yTocoOrigin = screenHeight - paddingBottom! - pixelsPerOneCM! * 2;

    xOrigin = paddingLeft;
    yOrigin = screenHeight - paddingBottom!;

    xDivLength = pixelsPerOneCM;
    // programatically decide
    //xDiv = (int) ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM);
    // static
    xDiv = 20;

    yAxisLength = yOrigin - paddingTop!;
    xAxisLength = xDiv *
        xDivLength!; //screenWidth - paddingLeft - pixelsPerOneCM - paddingRight;

    yOrigin = yTocoOrigin - xDivLength! * 6; // x= 2y

    yDivLength = xDivLength! / 2;
    yDiv = (yOrigin - paddingTop!) / pixelsPerOneCM! * 2;

    //reinitialize for toco
    //xOrigin = paddingLeft;
    yOrigin = yTocoOrigin - yDivLength * 12;

    yTocoEnd = yOrigin + xDivLength!;
    yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM! * 2;

    pointsPerPage = 10 * timeScaleFactor * xDiv;
    pointsPerDiv = timeScaleFactor * 10;

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      /*Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
      bitmaps[pageNumber] = Bitmap.createBitmap(screenWidth, screenHeight, conf); // this creates a MUTABLE bitmap
      canvas[pageNumber] = new Canvas(bitmaps[pageNumber]);*/
      //canvas[pageNumber].drawPaint(graphBackGround);

      displayInformation(pageNumber);

      drawXAxis(pageNumber);

      drawYAxis(pageNumber);

      drawTocoXAxis(pageNumber);

      drawTocoYAxis(pageNumber);
    }
    //invalidate();
  }

  /// Draws the X-axis of the graph for the given page number.
  /// [pageNumber] is the index of the page to draw the X-axis on.
  void drawXAxis(int pageNumber) {
    int interval = 10;
    int ymin = 50;
    int safeZoneMax = 160;

    //SafeZone
    Rect safeZoneRect = Rect.fromLTRB(
        xOrigin!,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin! + xAxisLength,
        yOrigin - yDivLength * 8); //50
    canvas[pageNumber].drawRect(safeZoneRect, graphSafeZone!);

    int numberOffset = XDIV * (pageNumber);

    canvas[pageNumber].drawLine(
        new Offset(xOrigin! + xDivLength! / 2, paddingTop!),
        new Offset(xOrigin! + xDivLength! / 2, yOrigin),
        graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas[pageNumber].drawLine(
          new Offset(xOrigin! + (xDivLength! * i), paddingTop!),
          new Offset(xOrigin! + (xDivLength! * i), yOrigin),
          graphGridLines);

      //for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          new Offset(
              xOrigin! + (xDivLength! * i) + xDivLength! / 2, paddingTop!),
          new Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, yOrigin),
          graphGridSubLines);
      //}

      //if(i!=1)
      // old
      /*canvas[pageNumber].drawText(String.format("%2d", i + numberOffset),
                    xOrigin + (xDivLength * i) -
                            (graphAxisText.measureText("00") / 2),
                    yOrigin + axisFontSize * 3, graphAxisText);*/

    }
  }

  /// Draws the Y-axis of the graph for the given page number.
  /// [pageNumber] is the index of the page to draw the Y-axis on.
  void drawYAxis(int pageNumber) {
    //y-axis outlines
    canvas[pageNumber].drawLine(new Offset(xOrigin!, yOrigin),
        new Offset(xOrigin! + xAxisLength, yOrigin), graphOutlines);
    canvas[pageNumber].drawLine(
        new Offset(xOrigin! - pixelsPerOneCM!, paddingTop!),
        new Offset(xOrigin! + xAxisLength, paddingTop!),
        graphOutlines);

    int interval = 10;
    int ymin = 50;
    //int safeZoneMax = 160;

    //SafeZone
    /*Rect safeZoneRect = Rect.fromLTRB(xOrigin,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin + xAxisLength,
        yOrigin - yDivLength * 8);//50
    canvas[pageNumber].drawRect(safeZoneRect, graphSafeZone);*/

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yOrigin - (yDivLength * i)),
            new Offset(xOrigin! + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        /*canvas[pageNumber].drawText("" + (ymin + (interval * (i - 1))), pixelsPerOneMM,
                        yOrigin - (yDivLength * i) + axisFontSize / 2, graphAxisText);*/
        canvas[pageNumber].drawParagraph(
            getParagraph("${(ymin + (interval * (i - 1)))}"),
            new Offset(xOrigin! - pixelsPerOneCM!,
                yOrigin - (yDivLength * i + (pixelsPerOneMM! * 2))));

        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin! + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yOrigin - (yDivLength * i)),
            new Offset(xOrigin! + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin! + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Draws the X-axis of the TOCO graph for the given page number.
  /// [pageNumber] is the index of the page to draw the TOCO X-axis on.
  void drawTocoXAxis(int pageNumber) {
    int numberOffset = XDIV * (pageNumber);
    for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          new Offset(xOrigin! + ((xDivLength! / 2) * j), yTocoEnd),
          new Offset(xOrigin! + ((xDivLength! / 2) * j), yTocoOrigin),
          graphGridSubLines);
    }

    for (int i = 1; i <= xDiv; i++) {
      canvas[pageNumber].drawLine(
          new Offset(xOrigin! + (xDivLength! * i), yTocoEnd),
          new Offset(xOrigin! + (xDivLength! * i), yTocoOrigin),
          graphGridLines);

      //for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          new Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, yTocoEnd),
          new Offset(
              xOrigin! + (xDivLength! * i) + xDivLength! / 2, yTocoOrigin),
          graphGridSubLines);
      //}
      int offSet = ((numberOffset + i) / scale!).truncate();
      if ((numberOffset + i) % scale! == 0)
        canvas[pageNumber].drawParagraph(
            getParagraph((offSet).toString()),
            new Offset(xOrigin! + (xDivLength! * i) - (pixelsPerOneMM! * 7),
                yTocoOrigin + axisFontSize - (pixelsPerOneMM! * 4)));
    }
  }

  /// Draws the Y-axis of the TOCO graph for the given page number.
  /// [pageNumber] is the index of the page to draw the TOCO Y-axis on.
  void drawTocoYAxis(int pageNumber) {
    //y-axis outlines
    canvas[pageNumber].drawLine(new Offset(xOrigin!, yTocoOrigin),
        new Offset(xOrigin! + xAxisLength, yTocoOrigin), graphOutlines);
    canvas[pageNumber].drawLine(new Offset(xOrigin!, yTocoEnd),
        new Offset(xOrigin! + xAxisLength, yTocoEnd), graphOutlines);
    canvas[pageNumber].drawLine(
        new Offset(paddingLeft! - pixelsPerOneCM!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        new Offset(screenWidth - paddingRight!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        graphOutlines);

    canvas[pageNumber].drawLine(
        new Offset(paddingLeft! - pixelsPerOneCM!, paddingTop!),
        new Offset(paddingLeft! - pixelsPerOneCM!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        graphOutlines);

    int interval = 10;
    int ymin = 10;

    for (int i = 1; i <= yTocoDiv; i++) {
      if (i % 2 == 0) {
        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yTocoOrigin - (yDivLength * i)),
            new Offset(xOrigin! + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridLines);

        canvas[pageNumber].drawParagraph(
            getParagraph("${(ymin + (interval * (i - 1)))}"),
            new Offset(xOrigin! - pixelsPerOneCM!,
                yTocoOrigin - (yDivLength * i + (pixelsPerOneMM! * 2))));

        canvas[pageNumber].drawLine(
            new Offset(
                xOrigin!, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin! + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas[pageNumber].drawLine(
            new Offset(xOrigin!, yTocoOrigin - (yDivLength * i)),
            new Offset(xOrigin! + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas[pageNumber].drawLine(
            new Offset(
                xOrigin!, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            new Offset(xOrigin! + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Displays information on the graph for the given page number.
  /// [pageNumber] is the index of the page to display information on.
  void displayInformation(int pageNumber) {
    int rows = 3;

    String date = DateFormat('dd MMM yyyy').format(mData!.getCreatedOn()!);
    String time = DateFormat('hh:mm a').format(mData!.getCreatedOn()!);

    //String.format("%s  %s %s", now.substring(11, 16), now.substring(8, 10),now.substring(4, 10), now.substring(now.lastIndexOf(" ")+3));

    double rowLength = (screenWidth + (pixelsPerOneCM! * 2)) / rows;
    double rowHeight = pixelsPerOneCM! * 0.7;
    double rowPos = rowHeight * 0.5;

    //mData.setOrganizationName("hospital i Morey MD FICOG and so on");
    if (mData!.getOrganizationName() != null &&
        mData!.organizationName!.length >= 30) {
      String s1 = mData!.getOrganizationName()!.substring(0, 30);
      s1 = mData!.getOrganizationName()!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.organizationName!.replaceAll(s1, ""); //.replace(s1,"");
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo(s1 ?? ""), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2 ?? ""),
          new Offset(
            0,
            rowPos - pixelsPerOneMM!,
          ));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Hospital :"), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(mData!.organizationName ?? ""),
          new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }
    //mData.setDoctorName("Dr Bharati Morey MD FICOG and so on");
    if (mData!.doctorName != null && mData!.doctorName!.length >= 30) {
      String s1 = mData!.doctorName!.substring(0, 30);
      s1 = mData!.doctorName!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.doctorName ?? "";

      canvas[pageNumber]
          .drawParagraph(getParagraphInfo(s1 ?? ""), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2 ?? ""), new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Doctor :"), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(getParagraphInfo(mData!.doctorName ?? ""),
          new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    //mData.setpatientId("sds");
    if (mData!.patientId != null && mData!.patientId!.length >= 30) {
      String s1 = mData!.patientId!.substring(0, 30);
      s1 = mData!.patientId!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.patientId!.replaceAll(s1, "");

      canvas[pageNumber]
          .drawParagraph(getParagraphInfo(s1 ?? ""), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2 ?? ""), new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber].drawParagraph(
          getParagraphInfo("Patient Id :"), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(getParagraphInfo(mData!.patientId ?? ""),
          new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    //mData.setMotherName("Dr Bharati Morey MD FICOG and so on asdsa");
    if (mData!.motherName != null && mData!.motherName!.length >= 30) {
      String s1 = mData!.motherName!.substring(0, 30);
      s1 = mData!.motherName!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.motherName!.replaceAll(s1, "");

      canvas[pageNumber]
          .drawParagraph(getParagraphInfo(s1 ?? ""), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2 ?? ""), new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Mother :"), new Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(getParagraphInfo(mData!.motherName ?? ""),
          new Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            ("Duration :  ${(mData!.lengthOfTest! / 60).truncate()} min")),
        new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Time : $time"), new Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Date : $date"), new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("Gest. Week : ${mData!.gAge}"), new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Basal HR : ${auto ? interpretation!.getBasalHeartRateStr() : ' _______'}"),
        new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "FM : ${mData!.movementEntries!.length.toString() ?? "--"} man/ ${mData!.autoFetalMovement!.length.toString() ?? "--"} auto "),
        new Offset(0, rowPos));

    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Accelerations : ${auto ? interpretation!.getnAccelerationsStr() : ' _______'}"), //+mData.getWeight(),
        new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Decelerations : ${auto ? interpretation!.getnDecelerationsStr() : ' _______'}"),
        new Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "STV : ${auto ? '${interpretation!.getShortTermVariationBpmStr() ?? "--"} bpm / ${interpretation!.getShortTermVariationMilliStr() ?? "--"} milli' : ' _______'}"),
        new Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "LTV : ${auto ? '${interpretation!.getLongTermVariationStr() ?? "--"} bpm' : ' _______'}"),
        new Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Conclusion :"), new Offset(0, rowPos));
    rowPos += pixelsPerOneMM! * 3;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("(Reactive, Non-Reactive, Inconclusive)",
            fontsize: 20),
        new Offset(0, rowPos));

    rowPos = yTocoOrigin + rowHeight;
    rowPos -= rowHeight * 0.5;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo('X-Axis : ${timeScaleFactor * 10} SEC/DIV'),
        new Offset(0, rowPos));
    rowPos += rowHeight * 0.6;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("Y-Axis : 20 BPM/DIV"), new Offset(0, rowPos));
    rowPos += rowHeight * 1.5;

    if (mData!.interpretationType != null && comments)
      canvas[pageNumber].drawParagraph(
          getParagraphLong(
              "Doctor\'s comments : ${mData!.interpretationType} - ${mData!.interpretationExtraComments ?? ''}",
              2500),
          new Offset(0, rowPos));

    //if(auto) {
    String _disclaimer =
        "Disclaimer : NST auto interpretation does not provide medical advice it is intended for informational purposes only. It is not a substitute for professional medical advice, diagnosis or treatment.";
    canvas[pageNumber].drawParagraph(
        getParagraphLong(_disclaimer, 2500, fontsize: 18),
        new Offset(0, screenHeight - (pixelsPerOneMM! * 2)));
  }

  /// Draws a line on the graph for the given list of BPM values and pages.
  /// [bpmList] is the list of BPM values.
  /// [pages] is the number of pages to draw the line on.
  /// [style] is the paint style to use for the line.
  void drawLine(List<int>? bpmList, int pages, Paint? style) {
    if (bpmList == null) {
      return;
    }

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      double startX, startY, stopX = 0, stopY = 0;
      int startData, stopData = 0;

      for (int i = (pageNumber * pointsPerPage), j = 0;
          i < bpmList.length && j < pointsPerPage;
          i++, j++) {
        startData = stopData;
        stopData = bpmList[i];

        startX = stopX;
        startY = stopY;

        stopX = getScreenX(i, pageNumber);
        stopY = getYValueFromBPM(bpmList[i]); // getScreenY(stopData);

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

        canvas[pageNumber].drawLine(
            new Offset(startX, startY), new Offset(stopX, stopY), style!);
      }

      canvas[pageNumber].drawParagraph(
          getParagraphLong("page ${pageNumber + 1} of $pages", 200,
              align: TextAlign.right),
          new Offset(screenWidth - paddingRight! - pixelsPerOneCM! * 2,
              screenHeight - pixelsPerOneMM! * 5));
    }
  }

  /// Converts x-position to screen coordinates.
  /// [i] is data point index.
  /// [startIndex] is starting index for current page.
  /// Returns x-coordinate on canvas.
  double getScreenX(int i, int startIndex) {
    double increment = (pixelsPerOneMM! / timeScaleFactor);
    double k = xOrigin! + increment * 4;
    k += increment * (i - (startIndex * pointsPerPage));
    return k;
  }

  /// Draws the TOCO line on the graph for the given list of TOCO entries and pages.
  /// [tocoEntries] is the list of TOCO entries.
  /// [pages] is the number of pages to draw the TOCO line on.
  void drawTocoLine(List<int>? tocoEntries, int pages) {
    if (mData!.tocoEntries == null) {
      return;
    }

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      double startX, startY, stopX = 0, stopY = 0;
      int startData, stopData = 0;

      for (int i = (pageNumber * pointsPerPage), j = 0;
          i < tocoEntries!.length && j < pointsPerPage;
          i++, j++) {
        startData = stopData;
        stopData = tocoEntries[i];

        startX = stopX;
        startY = stopY;

        stopX = getScreenX(i, pageNumber);
        stopY = getYValueFromToco(tocoEntries[i]); // getScreenY(stopData);

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

        canvas[pageNumber].drawLine(
            new Offset(startX, startY), new Offset(stopX, stopY), graphBpmLine!);
      }
    }
  }

  /// Draws the movements on the graph for the given list of movement entries and pages.
  /// [movementList] is the list of movement entries.
  /// [pages] is the number of pages to draw the movements on.
  void drawMovements(List<int>? movementList, int pages) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (movementList == null || movementList.length == 0) return;

      double increment = (pixelsPerOneMM! / timeScaleFactor);
      for (int i = 0; i < movementList.length; i++) {
        int movement = movementList[i] - (pageNumber * pointsPerPage);
        if (movement > 0 && movement < pointsPerPage) {
          canvas[pageNumber].drawLine(
              new Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2),
              new Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 4)),
              graphMovement);
          canvas[pageNumber].drawLine(
              new Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2),
              new Offset(xOrigin! + (increment * (movement)) + pixelsPerOneMM!,
                  yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 2)),
              graphMovement);
        }
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas[pageNumber].drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  void drawAutoMovements(List<int>? movementList, int pages) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (movementList == null || movementList.length == 0) return;

      double increment = (pixelsPerOneMM! / timeScaleFactor);
      for (int i = 0; i < movementList.length; i++) {
        int movement = movementList[i] - (pageNumber * pointsPerPage);
        if (movement > 0 && movement < pointsPerPage) {
          /*canvas[pageNumber].drawLine(
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2),
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 4)),
              graphMovement);
          canvas[pageNumber].drawLine(
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2),
              new Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM,
                  yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 2)),
              graphMovement);*/

          canvas[pageNumber].drawLine(
              new Offset(xOrigin! + (increment * (movement)), yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
              new Offset(xOrigin! + (increment * (movement)) , yOrigin - pixelsPerOneMM! *3),
              graphOutlines);
          canvas[pageNumber].drawLine(
              new Offset(xOrigin! + (increment * (movement)), yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
              new Offset(xOrigin! + (increment * (movement))+pixelsPerOneMM!+pixelsPerOneMM! , yOrigin - pixelsPerOneMM!*7),
              graphOutlines);
          canvas[pageNumber].drawLine(
              new Offset(xOrigin! + (increment * (movement)), yOrigin - pixelsPerOneCM! + pixelsPerOneMM! * 7),
              new Offset(xOrigin! + (increment * (movement))+pixelsPerOneMM! +pixelsPerOneMM! , yOrigin - pixelsPerOneMM!*5),
              graphOutlines);
        }
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas[pageNumber].drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws the auto movements on the graph for the given list of auto movement entries and pages.
  /// [movementList] is the list of auto movement entries.
  /// [pages] is the number of pages to draw the auto movements on.
  void drawInterpretationAreas(
      List<MarkerIndices>? list, int pages, Paint? style) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (list == null || list.length == 0) return;

      double? startX, stopX = 0;

      for (int i = 0; i < list.length; i++) {
        startX = getScreenX((list[i].getFrom()! - 3), pageNumber);
        stopX = getScreenX(list[i].getTo()! + 3, pageNumber);

        if (startX < xOrigin!) startX = xOrigin;
        if (stopX < xOrigin!) stopX = xOrigin;
        if (startX == stopX) continue;
        //Marker
        Rect zoneRect =
            Rect.fromLTRB(startX!, paddingTop!, stopX!, yTocoOrigin); //50
        canvas[pageNumber].drawRect(zoneRect, style!);
      }
    }
  }

  int scaleOrigin = 40;

  /// Returns the Y-coordinate on the screen for the given TOCO value.
  /// [bpm] is the TOCO value.
  /// Returns the Y-coordinate on the screen.
  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double y_value = yOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue",bpm+" "+adjustedBPM+" "+y_value);
    return y_value;
  }

  /// Returns the Y-coordinate on the screen for the given TOCO value.
  /// \[bpm\] is the TOCO value.
  /// Returns the Y-coordinate on the screen.
  double getYValueFromToco(int bpm) {
    double adjustedBPM = bpm.toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yTocoOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Returns a \[ui.Paragraph\] object for the given text.
  /// \[text\] is the text to create the paragraph for.
  /// Returns a \[ui.Paragraph\] object.
  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 30.0, textAlign: TextAlign.right))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 80));
    return paragraph;
  }

  /// Returns a \[ui.Paragraph\] object for the given text with the specified font size.
  /// \[text\] is the text to create the paragraph for.
  /// \[fontsize\] is the font size to use for the paragraph.
  /// Returns a \[ui.Paragraph\] object.
  ui.Paragraph getParagraphInfo(String text, {double fontsize = 30}) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: fontsize, textAlign: TextAlign.left))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: paddingLeft! * 9));
    return paragraph;
  }

  /// Returns a \[ui.Paragraph\] object for the given long text with the specified width, font size, and alignment.
  /// \[text\] is the long text to create the paragraph for.
  /// \[width\] is the width of the paragraph.
  /// \[fontsize\] is the font size to use for the paragraph.
  /// \[align\] is the alignment to use for the paragraph.
  /// Returns a \[ui.Paragraph\] object.
  ui.Paragraph getParagraphLong(String text, double width,
      {double fontsize = 30, TextAlign align = TextAlign.left}) {
    if (text.length == 1) text = "0${text}";
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: fontsize, textAlign: align))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: width));
    return paragraph;
  }
}
