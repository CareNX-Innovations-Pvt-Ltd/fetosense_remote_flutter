import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
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

  AllTestCard({required this.testDetails}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);
    // if (testDetails.lengthOfTest > 180 && testDetails.lengthOfTest < 3600)
    //   interpretation =
    //       Interpretations2.withData(testDetails.bpmEntries, testDetails.gAge);
    // else
    //   interpretation = Interpretations2();

    int _movements = testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length;
    movements = _movements < 10 ? "0$_movements" : '$_movements';

    int _time = (testDetails.lengthOfTest! / 60).truncate();
    if (_time < 10)
      time = "0$_time";
    else
      time = "$_time";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 36.w,
          /*width: 78.h,
          height: 78.h,
          padding:  EdgeInsets.all(3.w),

          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius:  BorderRadius.all(Radius.circular(120.w)),
          ),*/
          backgroundColor: Colors.teal,

          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text.rich(
                    TextSpan(text:
                    '$time',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 26.sp,
                      height: 1
                    ),
                      children: [
                        TextSpan(text: "\nmin",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            fontSize: 12.sp,
                          ))
                      ]
                   ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ))),
      title: Text(
        "${testDetails.motherName} ",
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 34.sp,
            color: Colors.black87
        ),
      ),
      subtitle: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: Text(
            ' ${testDetails.autoInterpretations == null ? '--' : (testDetails.autoInterpretations!['basalHeartRate'] == null ? '--' : testDetails.autoInterpretations!['basalHeartRate'])} Basal HR | ${testDetails
                .movementEntries != null &&
                (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'} Movements',
            style: TextStyle(color: Colors.grey),
          )),
      trailing: testDetails.isLive()! ? Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          width: 54.w,
          height: 84.h,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(child: Text(
              "Live\nnow", textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),),),
          )) : Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),

          width: 54.w,
          height: 84.h,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(child: Text(
              "${DateFormat('dd\nMMM').format(testDetails.createdOn!)}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),),),
          )),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    DetailsView(
                      test: this.testDetails,
                    )));
      },
    );
  }
}
