import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/ui/shared/textWithIcon.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A widget that displays a card with test details.
class TestCard extends StatelessWidget {
  /// The details of the test.
  final Test testDetails;

  /// The interpretation of the test data.
  late Interpretations2 interpretation;

  /// The formatted time of the test.
  String? time;

  /// The number of movements during the test.
  String? movements;

  TestCard({super.key, required this.testDetails}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);
    if (testDetails.lengthOfTest! > 180 && testDetails.lengthOfTest! < 3600) {
      interpretation =
          Interpretations2.withData(testDetails.bpmEntries!, testDetails.gAge!);
    } else {
      interpretation = Interpretations2();
    }

    int movements = testDetails.movementEntries!.length +
        testDetails.autoFetalMovement!.length;
    this.movements = movements < 10 ? "0$movements" : '$movements';

    int time = (testDetails.lengthOfTest! / 60).truncate();
    if (time < 10) {
      this.time = "0$time";
    } else {
      this.time = "$time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            height: 40,
                            //margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                TextWithIcon(
                                    icon: Icons.favorite,
                                    text:
                                        interpretation.getBasalHeartRateStr()),
                                Text(
                                  "Basal HR",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w300,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 40,
                            //margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                TextWithIcon(
                                  icon: Icons.arrow_upward,
                                  text:
                                      ' ${testDetails.movementEntries != null && (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'}',
                                ),
                                Text(
                                  "Movements",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    interpretation.getnAccelerationsStr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "ACCELERATION",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black87,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    interpretation.getnDecelerationsStr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "DECELERATION",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black87,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    interpretation.getShortTermVariationBpmStr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "SHORT TERM VARI",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black87,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    interpretation.getLongTermVariationStr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "LONG TERM VARI",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black87,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    testDetails.isLive()!
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Live\nnow",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('dd\nMMM').format(testDetails.createdOn!),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(3.0),
                      margin: EdgeInsets.only(top: 10, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '$time',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 30.sp,
                              ),
                            ),
                            Text(
                              "min",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsView(
                test: testDetails,
              ),
            ),
          );
        });
  }
}
