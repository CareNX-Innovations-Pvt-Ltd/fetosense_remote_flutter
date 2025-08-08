import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/ui/views/mothers_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MotherCard extends StatelessWidget {
  final Mother mother;

  const MotherCard({super.key, required this.mother});

  int getGestAge(DateTime edd) {
    final now = DateTime.now();
    final remainingDays = edd.difference(now).inDays;
    final gestAge = (280 - remainingDays) ~/ 7;
    return gestAge.clamp(0, 42); // safe range
  }

  @override
  Widget build(BuildContext context) {
    final edd = mother.edd;
    final lmp = mother.lmp ;

    final gestAge = edd != null ? getGestAge(edd) : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gestAge?.toString() ?? "-",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
                Text(
                  "weeks",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        mother.name ?? 'Unknown',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          edd != null
              ? 'EDD - ${DateFormat('dd MMM yyyy').format(edd)}'
              : lmp != null
              ? 'LMP - ${DateFormat('dd MMM yyyy').format(lmp)}'
              : '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
          ),
        ),
      ),
      trailing: Image.asset(
        mother.type == "BabyBeat" ? "assets/bbc_icon.png" : "images/ic_logo_good.png",
        width: 25,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MotherDetails(mother: mother),
          ),
        );
      },
    );
  }
}
