import 'package:fetosense_remote_flutter/ui/views/mother_test_list_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// This widget shows the mother's name, LMP (Last Menstrual Period), and gestational age.
/// It also includes a list of tests associated with the mother.
class MotherDetails extends StatelessWidget {
  /// [mother] is the mother model containing the details to be displayed.
  final dynamic mother;

  const MotherDetails({super.key, required this.mother});

  /// Calculates the gestational age of the mother.
  ///
  /// Returns the gestational age in weeks.
  int getGestAge() {
    if (mother['edd'] != null) {
      double age = (280 -
              ((DateTime.parse(mother['edd']).millisecondsSinceEpoch -
                      new DateTime.now().millisecondsSinceEpoch) /
                  (1000 * 60 * 60 * 24))) /
          7;
      return age.floor();
    } else {
      return 0;
    }
  }

  /// Returns the abbreviated month name for the given month number.
  ///
  /// [m] is the month number (1-12).
  /// Returns the abbreviated month name as a string.
  String getMonthName(int m) {
    switch (m) {
      case 1:
        return "JAN";
      case 2:
        return "FEB";
      case 3:
        return "MAR";
      case 4:
        return "APR";
      case 5:
        return "MAY";
      case 6:
        return "JUN";
      case 7:
        return "JUL";
      case 8:
        return "AUG";
      case 9:
        return "SEP";
      case 10:
        return "OCT";
      case 11:
        return "NOV";
      case 12:
        return "DEC";
      default:
        return "DEC";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.teal)),
              ),
              child: ListTile(
                leading: IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.teal),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "${mother['fullName']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20),
                ),
                subtitle: Text(
                  "LMP - ${DateFormat('dd MMM yyyy').format(DateTime.parse(mother['edd']))}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 14),
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
                          getGestAge().toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 36.sp,
                          ),
                        ),
                        Text(
                          "weeks",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ))),
              ),
            ),
            Expanded(child: new MotherTestListView(mother: mother))
          ],
        ),
      ),
    );
  }
}
