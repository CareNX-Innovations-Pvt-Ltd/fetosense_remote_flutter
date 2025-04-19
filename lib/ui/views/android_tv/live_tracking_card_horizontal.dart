import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:fetosense_remote_flutter/ui/widgets/graphPainter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:preferences/preferences.dart';

/// [LiveTrackingCardHori] is a stateful widget that displays the live tracking card for a test in a horizontal layout.
/// It shows the test details, including the graph, FHR, movements, accelerations, and decelerations.
class LiveTrackingCardHori extends StatefulWidget {
  final Test? testDetails;

  final Doctor? doctor;
  final Organization? organization;

  const LiveTrackingCardHori(
      {super.key, this.testDetails, this.doctor, this.organization});

  @override
  LiveTrackingCardHoriState createState() => LiveTrackingCardHoriState();
}

class LiveTrackingCardHoriState extends State<LiveTrackingCardHori> {
  Test? testDetails;
  Interpretations2? interpretation;
  int gridPreMin = PrefService.getInt('gridPreMin') ?? 1;
  double mTouchStart = 0;
  int mOffset = 0;
  String? time;
  String? date;
  String? month;
  String? movements;
  String? motherName;
  StreamSubscription<RealtimeMessage>? listener;

  @override
  void initState() {
    testDetails = widget.testDetails;
    gridPreMin = PrefService.getInt('gridPreMin') ?? 1;
    motherName = testDetails!.motherName;
    var parts = motherName!.split(' ');
    motherName = parts[0].trim();
    if (testDetails!.lengthOfTest! > 180 && testDetails!.lengthOfTest! < 3600) {
      interpretation = Interpretations2.withData(
          testDetails!.bpmEntries!, testDetails!.gAge!);
    } else {
      interpretation = Interpretations2();
    }

    int movements = testDetails!.movementEntries!.length +
        testDetails!.autoFetalMovement!.length;
    this.movements = movements < 10 ? "0$movements" : '$movements';

    date = DateFormat('dd').format(testDetails!.createdOn!).toString();
    month = DateFormat('MMM').format(testDetails!.createdOn!).toString();

    int time = (testDetails!.lengthOfTest! / 60).truncate();
    if (time < 10) {
      this.time = "0$time";
    } else {
      this.time = "$time";
    }

    super.initState();

    if (testDetails!.isLive()!) {
      int timDiff = DateTime.now().millisecondsSinceEpoch -
          testDetails!.createdOn!.millisecondsSinceEpoch;
      timDiff = (timDiff / 1000).truncate();
      if (timDiff > (testDetails!.lengthOfTest! + 60)) _updateLiveFlag();
      _addListener();
    }
  }

  @override
  void didUpdateWidget(LiveTrackingCardHori oldWidget) {
    if (testDetails != widget.testDetails) {
      setState(() {
        testDetails = widget.testDetails;
        gridPreMin = PrefService.getInt('gridPreMin') ?? 1;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    gridPreMin = PrefService.getInt('gridPreMin') ?? 1;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: lightsecondaryColor, width: 3)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 2),
                        decoration: const BoxDecoration(
                            //     border: Border(
                            //   right: BorderSide(
                            //     color: themeColor,
                            //     width: 2.0,
                            //   ),
                            // ),
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Text(
                                "${testDetails!.motherName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: themeColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      testDetails!.isLive()!
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100.0)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                const Text(
                                  'Live Now',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5.0),
                                  margin: const EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          ' $time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: greenColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          " Min",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: greenColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragStart: (DragStartDetails start) =>
                        _onDragStart(context, start),
                    onHorizontalDragUpdate: (DragUpdateDetails update) =>
                        _onDragUpdate(context, update),
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: GraphPainter(
                            testDetails, mOffset, gridPreMin, interpretation),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        testDetails!.bpmEntries!.length > 1
                            ? "${testDetails!.bpmEntries![testDetails!.bpmEntries!.length - 1]}"
                            : "00",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        "FHR",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 6,
                        ),
                      ),
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "$movements",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        "MOVEMENTS",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 6,
                        ),
                      ),
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        interpretation!.getnAccelerationsStr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        "ACCELERATION",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 6,
                        ),
                      ),
                    ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        interpretation!.getnDecelerationsStr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        "DECELERATION",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 6,
                        ),
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the start of a horizontal drag gesture.
  ///
  /// [context] is the build context.
  /// [start] contains the details of the drag start.
  _onDragStart(BuildContext context, DragStartDetails start) {
    debugPrint(start.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //debugPrint(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  /// Handles the update of a horizontal drag gesture.
  ///
  /// [context] is the build context.
  /// [update] contains the details of the drag update.
  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //debugPrint(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      mOffset = trap(mOffset + (newChange / (gridPreMin * 5)).truncate());
    });
    debugPrint(mOffset.toString());
  }

  /// Ensures the given position is within valid bounds.
  ///
  /// [pos] is the position to validate.
  ///
  /// Returns the adjusted position.
  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > testDetails!.bpmEntries!.length) {
      pos = testDetails!.bpmEntries!.length - 10;
    }

    return pos;
  }

  /// Adds a listener to the test document in the database.
  ///
  /// The listener updates the test details and interpretation when the document is updated.
  void _addListener() {
    final realtime = Realtime(locator<AppwriteService>().client);

    final subscription = realtime.subscribe(
        ['databases..collections.tests.documents.${testDetails!.id}']);

    listener = subscription.stream.listen((event) {
      if (event.events
          .contains('databases.*.collections.*.documents.*.update')) {
        final payload = event.payload;

        setState(() {
          testDetails = Test.fromMap(payload, payload['\$id']);
          interpretation = Interpretations2.withData(
              testDetails!.bpmEntries!, interpretation!.gestAge);

          int movementCount = (testDetails!.movementEntries?.length ?? 0) +
              (testDetails!.autoFetalMovement?.length ?? 0);

          movements = movementCount < 10 ? "0$movementCount" : "$movementCount";

          int time = (testDetails!.lengthOfTest! / 60).truncate();
          this.time = time < 10 ? "0$time" : "$time";

          debugPrint('$time');
          debugPrint(" time updated");
        });
      }
    });
  }

  /// Updates the live flag of the test document in Firestore to false.
  Future<void> _updateLiveFlag() async {
    Databases databases = Databases(locator<AppwriteService>().client);
    try {
      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: testDetails!.id!,
        data: {
          "live": false,
        },
      );
    } catch (e) {
      debugPrint("Failed to update live flag: $e");
    }
  }
}
