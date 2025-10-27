import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:flutter/material.dart';

/// A StatelessWidget that displays the notification view for a doctor.
///
/// This widget shows a list of notifications associated with the doctor.
class NotificationView extends StatelessWidget {
  final Doctor? doctor;

  const NotificationView({super.key, required this.doctor});

  static String getTitle() => 'fetosense';

  static String getSubtitle(Doctor? doctor) =>
      doctor != null ? 'Notifications for Dr. ${doctor.name}' : 'Notifications';

  static String getImageAsset() => 'images/ic_logo_good.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.grey),
                ),
              ),
              child: ListTile(
                leading: IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.arrow_back,
                      size: 30, color: Colors.teal),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  getTitle(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                subtitle: Text(
                  getSubtitle(doctor),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.black87),
                ),
                trailing: Image.asset(getImageAsset()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
