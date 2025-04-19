import 'dart:async';
import 'dart:io' as io;
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/shared/customRadioBtn.dart';
import 'package:fetosense_remote_flutter/ui/views/settings_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/fhrPdfview.dart';
import 'package:fetosense_remote_flutter/ui/widgets/graphPainter.dart';
import 'package:fetosense_remote_flutter/ui/widgets/interpretationDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:preferences/preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enum representing the status of the print process.
enum PrintStatus {
  preProcessing,
  generateFile,
  generatingPrint,
  fileReady,
}

/// Enum representing the action to be taken (print or share).
enum Action { print, share }

/// Constant for the directory name.
const directoryName = 'fetosense';

/// A stateful widget that displays the details of a BabyBeat test.
class DetailsViewBabyBeat extends StatefulWidget {
  /// The test to be displayed.
 final Test test;

  const DetailsViewBabyBeat({super.key, required this.test});

  @override
  DetailsViewBabyBeatState createState() => DetailsViewBabyBeatState();
}

class DetailsViewBabyBeatState extends State<DetailsViewBabyBeat>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Test? test;
  Interpretations2? interpretations;

  PrintStatus printStatus = PrintStatus.preProcessing;
  int gridPreMin = 3;
  double mTouchStart = 0;
  int mOffset = 0;
  bool isLoadingShare = false;
  bool isLoadingPrint = false;

  var pdfFile;
  late pdf.Document pdfDoc;
  Action? action;

  String? radioValue;

  late Map<permission.Permission, PermissionStatus> permissions;

  List<pdf.Image>? images;
  List<String>? paths;

  String? movements;

  late RealtimeSubscription? _realtimeSubscription;
  final _db = locator<Databases>();
  // final _testApi = locator<AppwriteTestApi>();
  final _realtime = Realtime(locator<Client>());

  static const printChannel = MethodChannel('com.carenx.fetosense/print');

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
    /*interpretation =
        Interpretation.fromList(widget.test.gAge, widget.test.bpmEntries);*/
    test = widget.test;
    if (test!.lengthOfTest! > 180 && test!.lengthOfTest! < 3600) {
      interpretations =
          Interpretations2.withData(test!.bpmEntries!, test!.gAge!);
    } else {
      interpretations = Interpretations2();
    }
    radioValue = test!.interpretationType;
    int movements =
        test!.movementEntries!.length + test!.autoFetalMovement!.length;
    this.movements = movements < 10 ? "0$movements" : '$movements';
    // print(test.documentId + " dco");
    if (test!.isLive()!) {
      int timDiff = DateTime.now().millisecondsSinceEpoch -
          test!.createdOn!.millisecondsSinceEpoch;
      timDiff = (timDiff / 1000).truncate();
      if (timDiff > (test!.lengthOfTest! + 60)) _updateLiveFlag();
      _addListener();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Text(
          '${widget.test.motherName}\n${DateFormat('dd MMM yyyy - hh:mm a').format(widget.test.createdOn)}',
          maxLines: 2,
          softWrap: true,
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[

        ],
      ),*/

      body: SafeArea(
          child: Column(children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: ListTile(
            leading: IconButton(
              iconSize: 35,
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.teal),
              onPressed: () => Navigator.pop(context),
            ),
            subtitle: Text(
              DateFormat('dd MMM yy - hh:mm a').format(test!.createdOn!),
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.black87),
            ),
            title: Text(
              "${test!.motherName}",
              style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: Colors.black87),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(3.0),
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${(test!.lengthOfTest! / 60).truncate()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 36.sp,
                      ),
                    ),
                    Text(
                      " min",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: !test!.isLive()!
                  ? CustomRadioBtn(
                      buttonColor: Theme.of(context).canvasColor,
                      buttonLables: const [
                        "Normal",
                        "Abnormal",
                        "Atypical",
                      ],
                      buttonValues: const [
                        "Normal",
                        "Abnormal",
                        "Atypical",
                      ],
                      enableAll: test!.interpretationType == null ||
                          test!.interpretationType!.trim().isEmpty,
                      defaultValue: radioValue,
                      radioButtonValue: (value) => _handleRadioClick(value),
                      selectedColor: Colors.blue,
                    )
                  : Container(
                      color: Colors.tealAccent,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          FadeTransition(
                            opacity: _animationController,
                            child: const Icon(
                              Icons.circle,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          const Text(
                            "Live test. Updates every 30 seconds.",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      //     Text(
                      //   "Live test. Updates every 30 sec. ",
                      //   style: TextStyle(
                      //       color: Colors.red,
                      //       fontSize: 18,
                      //       fontWeight: FontWeight.w500),
                      // ),
                    ),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragStart: (DragStartDetails start) =>
                    _onDragStart(context, start),
                onHorizontalDragUpdate: (DragUpdateDetails update) =>
                    _onDragUpdate(context, update),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: CustomPaint(
                    painter: GraphPainter(
                        test, mOffset, gridPreMin, interpretations),
                  ),
                ),
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getBasalHeartRateStr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "BASAL HR",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getnAccelerationsStr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "ACCELERATION",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getnDecelerationsStr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "DECELERATION",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '$movements',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "MOVEMENTS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getShortTermVariationBpmStr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "SHORT TERM VARI",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 40,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getLongTermVariationStr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "LONG TERM VARI",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                          ],
                        )),
                    /*Container(
                                color: Color.fromARGB(255, 238, 238, 238),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          TextWithIcon(
                                              icon: Icons.favorite,
                                              text:
                                                  '${widget.interpretations.getBasalHeartRateStr()}'),
                                          Text("Basal Heart Rate",
                                                style: TextStyle(
                                                    fontSize: FontUtil().setSp(18),
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w300),)
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          TextWithIcon(
                                              icon: Icons.arrow_upward,
                                              text:
                                                  ' ${widget.test.movementEntries != null ? widget.test.movementEntries.length : 0}'),
                                           Text("Fetal Movements",
                                                  style: TextStyle(
                                                  fontSize: FontUtil().setSp(18),
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w300),)
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          TextWithIcon(
                                              icon: Icons.access_time,
                                              text:
                                                  ' ${(widget.test.lengthOfTest / 60).truncate()} min'),
                                          Text("Test Duration",
                                            style: TextStyle(
                                              fontSize: FontUtil().setSp(18),
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w300),)
                                        ],
                                      )
                                    ],
                                  ),
                                ),*/
                  ],
                ))
          ],
        )),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  iconSize: 35,
                  icon: Icon(gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
                  onPressed: _handleZoomChange,
                ),
                !isLoadingShare
                    ? IconButton(
                        iconSize: 35,
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          if (!isLoadingPrint) {
                            setState(() {
                              isLoadingShare = true;
                              action = Action.share;
                            });
                            _handlePrint();
                          }
                        },
                      )
                    : IconButton(
                        iconSize: 35,
                        icon: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                        onPressed: () {},
                      ),
                !isLoadingPrint
                    ? IconButton(
                        iconSize: 35,
                        icon: const Icon(Icons.print),
                        onPressed: () {
                          if (!isLoadingShare) {
                            setState(() {
                              isLoadingPrint = true;
                              action = Action.print;
                            });
                            _handlePrint();
                          }
                        },
                      )
                    : IconButton(
                        iconSize: 35,
                        icon: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                        onPressed: () {},
                      ),
                IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SettingsView()));
                  },
                ),
              ],
            )),
      ])),
    );
  }

  /// Shows the interpretation dialog.
  /// [value] is the selected interpretation value.
  void showInterpretationDialog(String value) {
    showDialog(
      context: context,
      builder: (context) {
        return InterpretationDialog(
            test: test,
            value: test!.interpretationType ?? value,
            callback: updateCallback);
      },
      barrierDismissible: false,
    );
  }

  /// Handles the radio button click event.
  /// [value] is the selected radio button value.
  void _handleRadioClick(String value) {
    showInterpretationDialog(value);
    /*if (radioValue == value)
      return;
    else {
      setState(() {
        radioValue = value;
      });
    }*/
  }

  /// Updates the callback with the new interpretation value and comments.
  /// [value] is the interpretation value.
  /// [comments] are the additional comments.
  /// [update] indicates whether to update the interpretation.
  void updateCallback(String value, String comments, bool update) {
    if (update) {
      Map<String, dynamic> data = {
        "interpretationType": value,
        "interpretationExtraComments": comments,
      };

      _db.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: 'tests',
        documentId: widget.test.id!,
        data: data,
      );

      setState(() {
        test!.interpretationType = value;
        test!.interpretationExtraComments = comments;
        radioValue = value;
      });
    } else {
      setState(() {
        radioValue = null;
      });
    }
  }

  /// Handles the zoom change event.
  void _handleZoomChange() {
    setState(() {
      gridPreMin = gridPreMin == 1 ? 3 : 1;
    });
  }

  /// Handles the drag start event.
  /// [context] is the build context.
  /// [start] contains the details of the drag start event.
  _onDragStart(BuildContext context, DragStartDetails start) {
    print(start.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  /// Handles the drag update event.
  /// [context] is the build context.
  /// [update] contains the details of the drag update event.
  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      mOffset = trap(mOffset + (newChange / (gridPreMin * 5)).truncate());
    });
    print(mOffset.toString());
  }

  /// Traps the position within the valid range.
  /// [pos] is the position to be trapped.
  /// Returns the trapped position.
  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > test!.bpmEntries!.length) {
      pos = test!.bpmEntries!.length - 10;
    }
    return pos;
  }

  /// Handles the print event.
  Future<void> _handlePrint() async {
    if (io.Platform.isAndroid) {
      setState(() {
        isLoadingShare = false;
        isLoadingPrint = false;
      });
      printAndroid();
    } else {
      _iOSPrint();
    }
  }

  /// Handles the print action for iOS.
  Future<void> _iOSPrint() async {
    switch (printStatus) {
      case PrintStatus.preProcessing:
        pdfDoc = pdf.Document();

        FhrPdfView fhrPdfView = FhrPdfView(test!.lengthOfTest!);
        paths = await fhrPdfView.getNSTGraph(test, interpretations);
        for (var path in paths!) {
          final image = pdf.MemoryImage(io.File(path).readAsBytesSync());
          pdfDoc.addPage(
            pdf.Page(
              orientation: pdf.PageOrientation.landscape,
              pageFormat: PdfPageFormat.a4,
              build: (pdf.Context context) {
                return pdf.Image(image);
              },
            ),
          ); // Page
        }
        if (action == Action.print) {
          await Printing.layoutPdf(
              format: PdfPageFormat.a4,
              onLayout: (PdfPageFormat format) async => pdfDoc.save());
          setState(() {
            isLoadingPrint = false;
          });
        } else {
          await Printing.sharePdf(
              bytes: await pdfDoc.save(), filename: 'NSTtest.pdf');
          setState(() {
            isLoadingShare = false;
          });
        }
        break;
      case PrintStatus.generateFile:
        break;
      case PrintStatus.generatingPrint:
        // TODO: Handle this case.
        pdfDoc.addPage(pdf.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pdf.Context context) => <pdf.Widget>[pdf.Text("hello")]));
        setState(() {
          printStatus = PrintStatus.fileReady;
        });
        break;
      case PrintStatus.fileReady:
        // TODO: Handle this case.

        break;
    }
    setState(() {
      printStatus = PrintStatus.preProcessing;
    });
  }

  /// Handles the print action for Android.
  Future<void> printAndroid() async {
    var scale = PrefService.getInt('scale') ?? 1;
    var comments = PrefService.getBool('comments') ?? false;
    var interpretations = PrefService.getBool('interpretations') ?? false;
    var highlight = PrefService.getBool('highlight') ?? false;

    if (test!.organizationId == null && test!.associations != null) {
      test!.organizationId = test!.associations!['babybeat_org']['documentId'];
      test!.organizationName = test!.associations!['babybeat_org']['name'];

      test!.doctorId = test!.associations!['babybeat_doctor']['documentId'];
      test!.doctorName = test!.associations!['babybeat_doctor']['name'];
    }

    try {
      final String? result = await printChannel.invokeMethod(
          action == Action.print ? 'printNstTest' : "shareNstTest", {
        "test": test!.toJson(),
        "scale": '$scale',
        "comments": comments,
        "interpretations": interpretations,
        "highlight": highlight
      });
      print("result : '$result'.");
      setState(() {
        isLoadingPrint = false;
        isLoadingShare = false;
      });
    } on PlatformException catch (e) {
      print("print : '${e.message}'.");
    }
  }

  /// Requests storage permission.
  /// Returns a boolean indicating whether the permission was granted.
  Future<bool> requestPermission() async {
    permissions = await [permission.Permission.storage].request();
    if (permissions[permission.Permission.storage] ==
        PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  /// Gets the storage permission status.
  /// Returns a boolean indicating whether the permission is granted.
  getPermissionStatus() async {
    PermissionStatus permissionStatus =
        await permission.Permission.storage.request();
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  /// Adds a listener for live updates.
  void _addListener() {
    final subscription = _realtime.subscribe([
      'databases.${AppConstants.appwriteDatabaseId}.collections.tests.documents.${test!.id}'
    ]);

    _realtimeSubscription = subscription;
    _realtimeSubscription!.stream.listen((event) {
      final data = event.payload;
      setState(() {
        test = Test.fromMap(data, data['\$id']);
        interpretations = Interpretations2.withData(
            test!.bpmEntries!, interpretations!.gestAge);
        movements = (test!.movementEntries!.length +
                    test!.autoFetalMovement!.length) <
                10
            ? "0\${(test!.movementEntries!.length + test!.autoFetalMovement!.length)}"
            : '\${(test!.movementEntries!.length + test!.autoFetalMovement!.length)}';

        print("updated");
      });
    });
  }

  /// Updates the live flag in the database.
  Future<void> _updateLiveFlag() async {
    Map<String, dynamic> data = {'live': false};
    await _db.updateDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: 'tests',
      documentId: test!.id!,
      data: data,
    );
  }
}
