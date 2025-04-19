import 'dart:async';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/services/testapi.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/shared/customRadioBtn.dart';
import 'package:fetosense_remote_flutter/ui/views/settings_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/graphPainter.dart';
import 'package:fetosense_remote_flutter/ui/widgets/interpretationDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';

import 'package:preferences/preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'graph/fhr_pdf_view2.dart';
import 'graph/pdf_base_page.dart';

/// Enum representing the status of the print process.
enum PrintStatus {
  PRE_PROCESSING,
  GENERATING_FILE,
  GENERATING_PRINT,
  FILE_READY,
}

/// Enum representing the action to be taken (print or share).
enum Action { PRINT, SHARE }

/// Constant representing the directory name for storing files.
const directoryName = 'fetosense';

/// A stateful widget representing the details view of a test.
class DetailsView extends StatefulWidget {
  final Test test;

  const DetailsView({super.key, required this.test});

  @override
  DetailsViewState createState() => DetailsViewState();
}

/// The state class for [DetailsView].
class DetailsViewState extends State<DetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Test? test;
  Interpretations2? interpretations;
  Interpretations2? interpretations2;

  PrintStatus printStatus = PrintStatus.PRE_PROCESSING;
  int gridPreMin = 3;
  double mTouchStart = 0;
  int mOffset = 0;
  bool isLoadingShare = false;
  bool isLoadingPrint = false;

  late RealtimeSubscription? _realtimeSubscription;
  final _db = locator<Databases>();
  final _realtime = Realtime(locator<Client>());

  late pdf.Document pdfDoc;
  Action? action;

  String? radioValue;

  late Map<permission.Permission, PermissionStatus> permissions;

  List<pdf.Image>? images;
  List<String>? paths;

  final databaseReference = locator;

  String? movements;

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
    if ((test!.bpmEntries2?.length ?? 0) > 180 &&
        (test!.bpmEntries2?.length ?? 0) < 3600) {
      interpretations2 =
          Interpretations2.withData(test!.bpmEntries2!, test!.gAge!);
    } else {
      interpretations = Interpretations2();
    }
    radioValue = test!.interpretationType;
    int movements =
        test!.movementEntries!.length + test!.autoFetalMovement!.length;
    this.movements = movements < 10 ? "0$movements" : '$movements';
    print(test!.documentId! + " dcodocumentId");
    print(test!.id! + " dcoId");
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
    _realtimeSubscription?.close();
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
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
              ),
              child: ListTile(
                leading: IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.teal),
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
                trailing: CircleAvatar(
                    /*padding: const EdgeInsets.all(3.0),
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    ),*/
                    radius: 44.w,
                    backgroundColor: Colors.teal,
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                            text: '${(test!.lengthOfTest! / 60).truncate()}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 32.sp,
                                height: 1),
                            children: [
                              TextSpan(
                                text: "\nmin",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              )
                            ]),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
            ),
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
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: CustomPaint(
                            painter: GraphPainter(
                                test!, mOffset, gridPreMin, interpretations),
                          ))),
                ),
                if (kIsWeb)
                  Container(
                    width: 0.25.sw,
                    height: 0.8.sh,
                    padding: EdgeInsets.only(top: 8.h),
                    decoration: const BoxDecoration(
                      border: Border(
                          left: BorderSide(width: 2, color: Colors.black)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                            height: 0.30.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.teal)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        AutoSizeText.rich(
                                          const TextSpan(
                                              text: "BASAL HR",
                                              children: [
                                                TextSpan(
                                                  text: "\nACCELERATION",
                                                ),
                                                TextSpan(
                                                  text: "\nDECELERATION",
                                                ),
                                                TextSpan(
                                                  text: "\nSHORT TERM VARI  ",
                                                ),
                                                TextSpan(
                                                  text: "\nLONG TERM VARI ",
                                                ),
                                              ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white.withOpacity(0.6),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        AutoSizeText.rich(
                                          TextSpan(
                                              text:
                                                  ": ${(interpretations?.basalHeartRate ?? "--")}",
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations?.getnAccelerationsStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations?.getnDecelerationsStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations?.getShortTermVariationBpmStr() ?? "--")}/${(interpretations?.getShortTermVariationMilliStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations?.getLongTermVariationStr() ?? "--")}",
                                                ),
                                              ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "FHR 1",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              //color: Colors.white54,
                                              fontSize: 22.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                        Container(
                            height: 0.30.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.grey)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        AutoSizeText.rich(
                                          const TextSpan(
                                              text: "BASAL HR",
                                              children: [
                                                TextSpan(
                                                  text: "\nACCELERATION",
                                                ),
                                                TextSpan(
                                                  text: "\nDECELERATION",
                                                ),
                                                TextSpan(
                                                  text: "\nSHORT TERM VARI  ",
                                                ),
                                                TextSpan(
                                                  text: "\nLONG TERM VARI ",
                                                ),
                                              ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white.withOpacity(0.6),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        AutoSizeText.rich(
                                          TextSpan(
                                              text:
                                                  ": ${(interpretations2?.basalHeartRate ?? "--")}",
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations2?.getnAccelerationsStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations2?.getnDecelerationsStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations2?.getShortTermVariationBpmStr() ?? "--")}/${(interpretations2?.getShortTermVariationMilliStr() ?? "--")}",
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n: ${(interpretations2?.getLongTermVariationStr() ?? "--")}",
                                                ),
                                              ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "FHR 2",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              //color: Colors.tealAccent,
                                              fontSize: 22.sp,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                        Container(
                            height: 0.15.sh,
                            width: 0.24.sw,
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.5, color: Colors.grey)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                            const TextSpan(
                                              text: "DURATION",
                                            ),
                                            TextSpan(
                                                text: "\nMOVEMENTS",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            TextSpan(
                                                text: "\nSHORT TERM VARI  ",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.white
                                                        .withOpacity(0),
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white.withOpacity(0.6),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        AutoSizeText.rich(
                                          TextSpan(text: "", children: [
                                            TextSpan(
                                              text:
                                                  ": ${(widget.test.bpmEntries!.length ~/ 60)} m",
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n: ${(widget.test.movementEntries?.length)}/${(widget.test.autoFetalMovement?.length)}",
                                            ),
                                            const TextSpan(
                                              text: "\n ",
                                            ),
                                          ]),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              //color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                      ],
                    ),
                  ),
              ],
            )),
            if (!kIsWeb)
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
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getBasalHeartRateStr(),
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "BASAL HR",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
                                          ),
                                        )
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getnAccelerationsStr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "ACCELERATION",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getnDecelerationsStr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "DECELERATION",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '$movements',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "MOVEMENTS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getShortTermVariationBpmStr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "SHORT TERM VARI",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ]),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: Colors.grey)),
                                ),
                                child: SizedBox(
                                  height: 54.h,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          interpretations!
                                              .getLongTermVariationStr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22.sp,
                                              color: Colors.black87,
                                              height: 1,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "LONG TERM VARI",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black87,
                                            fontSize: 8.sp,
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
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    iconSize: 35,
                    icon:
                        Icon(gridPreMin == 1 ? Icons.zoom_in : Icons.zoom_out),
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
                                action = Action.SHARE;
                              });
                              _print();
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
                                action = Action.PRINT;
                              });
                              _print();
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
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _handleRadioClick(String value) {
    showInterpretationDialog(value);
  }

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

  void _handleZoomChange() {
    setState(() {
      gridPreMin = gridPreMin == 1 ? 3 : 1;
    });
  }

  _onDragStart(BuildContext context, DragStartDetails start) {
    debugPrint(start.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
    //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    //print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);
    double newChange = (mTouchStart - local.dx);
    setState(() {
      mOffset = trap(mOffset + (newChange / (gridPreMin * 5)).truncate());
    });
    debugPrint(mOffset.toString());
  }

  int trap(int pos) {
    if (pos < 0) {
      return 0;
    } else if (pos > test!.bpmEntries!.length) {
      pos = test!.bpmEntries!.length - 10;
    }

    return pos;
  }

  Future<void> printAndroid() async {
    var scale = PrefService.getInt('scale') ?? 1;
    var comments = PrefService.getBool('comments') ?? false;
    var interpretations = PrefService.getBool('interpretations') ?? false;
    var highlight = PrefService.getBool('highlight') ?? false;
    try {
      final String? result = await printChannel.invokeMethod(
          action == Action.PRINT ? 'printNstTest' : "shareNstTest", {
        "test": test!.toJson(),
        "scale": '$scale',
        "comments": comments,
        "interpretations": interpretations,
        "highlight": highlight
      });
      debugPrint("result : '$result'.");
      setState(() {
        isLoadingPrint = false;
        isLoadingShare = false;
      });
    } on PlatformException catch (e) {
      debugPrint("print : '${e.message}'.");
    }
  }

  Future<bool> requestPermission() async {
    permissions = await [permission.Permission.storage].request();
    if (permissions[permission.Permission.storage] ==
        PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  getPermissionStatus() async {
    PermissionStatus permissionStatus =
        await permission.Permission.storage.request();
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

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

        debugPrint("updated");
      });
    });
  }

  Future<void> _updateLiveFlag() async {
    Map<String, dynamic> data = {'live': false};
    await _db.updateDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: 'tests',
      documentId: test!.id!,
      data: data,
    );
  }

  Future<void> _print() async {
    switch (printStatus) {
      case PrintStatus.PRE_PROCESSING:
        pdfDoc = await _generatePdf(PdfPageFormat.a4.landscape, widget.test);

        if (action == Action.PRINT) {
          await Printing.layoutPdf(
              format: PdfPageFormat.a4.landscape,
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

          //Navigator.of(context).pop();
        }

        break;
      case PrintStatus.GENERATING_FILE:
        break;
      case PrintStatus.GENERATING_PRINT:
        // TODO: Handle this case.
        pdfDoc.addPage(pdf.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pdf.Context context) => <pdf.Widget>[pdf.Text("hello")]));
        setState(() {
          printStatus = PrintStatus.FILE_READY;
        });
        break;
      case PrintStatus.FILE_READY:
        // TODO: Handle this case.

        break;
    }
    setState(() {
      printStatus = PrintStatus.PRE_PROCESSING;
    });
  }

  Future<pdf.Document> _generatePdf(PdfPageFormat format, Test test) async {
    final pdf1 = pdf.Document();
    int index = 1;
    Interpretations2 interpretations = test.autoInterpretations != null
        ? Interpretations2.fromMap(test)
        : Interpretations2.withData(test.bpmEntries!, test.gAge ?? 32);
    Interpretations2? interpretations2 = (test.bpmEntries2 ?? []).isNotEmpty
        ? Interpretations2.withData(test.bpmEntries2!, test.gAge ?? 32)
        : null;
    FhrPdfView2 fhrPdfView = FhrPdfView2(test.lengthOfTest!);
    final paths = await fhrPdfView.getNSTGraph(test, interpretations);
    for (int i = 0; i < paths!.length; i++) {
      final mImage = paths[i];
      pdf1.addPage(
        pdf.Page(
          pageFormat: format,
          margin: pdf.EdgeInsets.zero,
          build: (context) {
            return PfdBasePage(
              data: test,
              interpretation: interpretations,
              interpretation2: interpretations2,
              index: index + i,
              total: paths.length,
              body: pdf.Image(pdf.MemoryImage(mImage.bytes)),
            );
          },
        ),
      );
    }
    return pdf1;
  }
}
