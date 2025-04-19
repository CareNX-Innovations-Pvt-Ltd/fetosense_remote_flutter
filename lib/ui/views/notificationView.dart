import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/notification_crud_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// A StatelessWidget that displays the notification view for a doctor.
///
/// This widget shows a list of notifications associated with the doctor.
class NotificationView extends StatelessWidget {
  /// [doctor] is the doctor model containing the details to be displayed.
  final Doctor? doctor;

  const NotificationView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationCRUDModel>(context);
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
                subtitle: const Text(
                  "Notifications",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.black87),
                ),
                title: const Text(
                  "fetosense",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                trailing: Image.asset('images/ic_logo_good.png'),
              ),
            ),
            // Expanded(child: new NotificationListView(doctor: doctor))
          ],
        ),
      ),
    );
  }
}
