import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/ui/views/mother_test_list_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MotherDetails extends StatelessWidget {
  /// [mother] is the mother model containing the details to be displayed.
  final Mother mother;

  const MotherDetails({super.key, required this.mother});

  /// Calculates the gestational age of the mother in weeks.
  int getGestAge() {
    if (mother.edd != null) {
      final eddDate = mother.edd;
      if (eddDate != null) {
        final now = DateTime.now();
        final remainingDays = eddDate.difference(now).inDays;
        final gestAge = (280 - remainingDays) ~/ 7;
        return gestAge.clamp(0, 42); // safe range
      }
    }
    return 0;
  }

  /// Returns the abbreviated month name for the given month number.
  String getMonthName(int m) {
    const monthNames = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    return (m >= 1 && m <= 12) ? monthNames[m - 1] : "DEC";
  }

  @override
  Widget build(BuildContext context) {
    final edd = mother.edd;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.teal),
                ),
              ),
              child: ListTile(
                leading: IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.arrow_back, size: 30, color: Colors.teal),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  mother.name ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
                subtitle: Text(
                  edd != null
                      ? "EDD - ${DateFormat('dd MMM yyyy').format(edd)}"
                      : "EDD not available",
                  style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(3.0),
                  width: 55.sp,
                  height: 55.sp,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            getGestAge().toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 20.sp,
                            ),
                          ),
                          Text(
                            "weeks",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: MotherTestListView(mother: mother)),
          ],
        ),
      ),
    );
  }
}
