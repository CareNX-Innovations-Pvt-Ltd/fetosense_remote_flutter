import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/core/utils/utilities.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// [AllTestCard] is a StatelessWidget that displays a card with test details.
class AllTestCard extends StatelessWidget {
  /// Details of the test to be displayed
  final Test testDetails;

  /// Interpretation of the test data
  Interpretations2? interpretation;

  /// Duration of the test in minutes
  String? time;

  /// Number of movements in the test
  String? movements;

  AllTestCard({super.key, required this.testDetails}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);
    // if (testDetails.lengthOfTest > 180 && testDetails.lengthOfTest < 3600)
    //   interpretation =
    //       Interpretations2.withData(testDetails.bpmEntries, testDetails.gAge);
    // else
    //   interpretation = Interpretations2();
    //
    // int movements = testDetails.movementEntries!.length +
    //     testDetails.autoFetalMovement!.length;
    // this.movements = movements < 10 ? "0$movements" : '$movements';
    if (testDetails.lengthOfTest! > 180 && testDetails.lengthOfTest! < 3600) {
      interpretation =
          Interpretations2.withData(testDetails.bpmEntries ?? [], testDetails.gAge?? 8);
    } else {
      interpretation = Interpretations2();
    }
    if ((testDetails.bpmEntries?.length ?? 0) > 180 &&
        (testDetails.bpmEntries?.length ?? 0) < 3600) {
      interpretation =
          Interpretations2.withData(testDetails.bpmEntries ?? [], testDetails.gAge ?? 8);
    } else {
      interpretation = Interpretations2();
    }
    int movements =
        testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length;
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
    Utilities().setScreenUtil(
      context,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 40.w,
          backgroundColor: Colors.teal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      text: '$time',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 20.sp,
                          height: 1),
                      children: [
                        TextSpan(
                          text: "\nmin",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          "${testDetails.motherName} ",
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 32.sp,
              color: Colors.black87),
        ),
        subtitle: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            ' ${testDetails.autoInterpretations == null ? '--' : (testDetails.autoInterpretations!['basalHeartRate'] ?? '--')} Basal HR | ${testDetails.movementEntries != null && (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'} Movements',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        trailing: testDetails.isLive()!
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                width: 54.w,
                height: 84.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Center(
                    child: Text(
                      "Live\nnow",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                width: 54.w,
                height: 84.h,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('dd\nMMM').format(testDetails.createdOn!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
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
        },
      ),
    );
  }
}
