import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view_baby_beat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// [AllTestCardBabyBeat] is a StatelessWidget that displays a card with test details for Baby Beat.
class AllTestCardBabyBeat extends StatelessWidget {
  /// Details of the test to be displayed
  final Test testDetails;

  /// Interpretation of the test data
  Interpretations2? interpretation;

  /// Duration of the test in minutes
  String? time;

  /// Number of movements in the test
  String? movements;

  AllTestCardBabyBeat({super.key, required this.testDetails}) {
    //interpretation = Interpretation.fromList(testDetails.gAge, testDetails.bpmEntries);

    if(testDetails.autoInterpretations == null && testDetails.autoInterpretations!['basalHeartRate'] == null){
      if (testDetails.lengthOfTest! > 180 && testDetails.lengthOfTest! < 3600){

        interpretation =
            Interpretations2.withData(testDetails.bpmEntries!, testDetails.gAge!);
      }
      else{

        interpretation = Interpretations2();
      }
    }


    int movements = testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length;
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
    return ListTile(
      leading: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(3.0),

          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ' $time',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 26.sp,
                    ),
                  ),
                  Text(
                    "min",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 22.sp,
                    ),
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
          child: (testDetails.autoInterpretations != null && testDetails.autoInterpretations!['basalHeartRate'] != null) ? Text(
            ' ${testDetails.autoInterpretations == null ? '--' : (testDetails.autoInterpretations!['basalHeartRate'] ?? '--')} Basal HR | ${testDetails
                .movementEntries != null &&
                (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'} Movements',
            style: TextStyle(color: Colors.grey),
          ) : Text(
            ' ${interpretation == null ? '--' : interpretation!.getBasalHeartRateStr()} Basal HR | ${testDetails
                .movementEntries != null &&
                (testDetails.movementEntries!.length + testDetails.autoFetalMovement!.length) > 0 ? movements : '--'} Movements',
            style: TextStyle(color: Colors.grey),
          )),
      trailing: testDetails.isLive()! ? Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: SizedBox(
              width: 40,
              height: 40,
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
              ))) : Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Center(child: Text(
                  DateFormat('dd\nMMM').format(testDetails.createdOn!),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),),),
              ))),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    DetailsViewBabyBeat(
                      test: testDetails
                    )));
      },
    );
  }
}
