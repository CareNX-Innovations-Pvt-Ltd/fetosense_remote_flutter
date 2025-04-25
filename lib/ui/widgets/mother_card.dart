import 'package:fetosense_remote_flutter/ui/views/mothers_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A widget that displays a card with mother details.
class MotherCard extends StatelessWidget {

  /// The details of the mother.
  final dynamic motherDetails;

  const MotherCard({super.key, required this.motherDetails});


  /// Calculates the gestational age in weeks.
  /// Returns the gestational age in weeks.
  int getGestAge() {
    if(motherDetails['edd'] != null){
      double age = (280 - (
          (DateTime.parse(motherDetails['edd']).millisecondsSinceEpoch -DateTime.now().millisecondsSinceEpoch)
           /(1000*60*60*24)))/
          7;
      return age.floor();
    }else{
      return 0;
    }

  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(3.0),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                getGestAge().toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 26.sp,
                ),
              ),
              Text(
                "weeks",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ))),
      title: Text(
        motherDetails['fullName'],
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 34.sp,
            color: Colors.black87),
      ),
      subtitle: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
          ),
          child: motherDetails['edd'] != null ? Text(
            ' EDD - ${DateFormat('dd MMM yyyy').format(DateTime.parse(motherDetails['edd']))}',
            style: TextStyle(color: Colors.grey),
          ): motherDetails['lmp'] != null ? Text(
            ' LMP - ${DateFormat('dd MMM yyyy').format(DateTime.parse(motherDetails['lmp']))}',
            style: TextStyle(color: Colors.grey),
          ): Text("")),
      trailing: motherDetails['type'] == "BabyBeat" ? Image.asset("assets/bbc_icon.png", width: 20,) : Image.asset("images/ic_logo_good.png", width: 25,),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MotherDetails(mother: motherDetails)));
      },
    );

    /*GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MotherDetails(mother: motherDetails)));
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: Column(
            children: <Widget>[
              */ /*Hero(
                  tag: motherDetails.documentId,
                  child: Image.asset(
                  'assets/ic_feton_logo.png',
                    height: MediaQuery
                        .of(context)
                        .size
                        .height *
                        0.35,
                  ),
                ),*/ /*
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(motherDetails.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                                fontSize : FontUtil().setSp(38),
                          ),
                    ),
                    Text(
                      '${getGestAge()} weeks',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );*/
  }
}
