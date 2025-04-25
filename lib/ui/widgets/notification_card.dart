import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart' as n;
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that displays a notification card.
class NotificationCard extends StatelessWidget {
  /// The notification details.
  final n.Notification notification;

  /// The formatted date of the notification.
  late String date;
  NotificationCard({super.key, required this.notification}) {
    DateTime now = notification.createdOn!;
    date = DateFormat('dd MMM yyyy - kk:mm a').format(now);
    now; //('${now.substring(4, 10)} ${now.substring(now.lastIndexOf(" "))} ${now.substring(11, 16)}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: notification.read ?  Colors.transparent : lightTealColor,
          border: Border(bottom: BorderSide(color: Colors.grey))),
      child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
             child: CircleAvatar(
                backgroundColor: bgColor,

                child: (notification.imageUrl != null && notification.imageUrl != "") ?  Image.network(notification.imageUrl!) : Image.asset("images/ic_banner.png") ,
              ),
      ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text(truncateNotification(notification.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: Colors.black)

                        //'${testDetails.averageFHR} Basal HR ',
                        ),
                    Text(truncateNotification(notification.message),
                        style: TextStyle(fontSize: 12, color: Colors.grey,),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,

                      //'${testDetails.averageFHR} Basal HR ',
                    ),
                    SizedBox(height: 3,),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Text(date,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 9,
                                color: Colors.grey))),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  /// Truncates the notification message.
  /// [message] is the notification message.
  /// Returns the truncated message.
  truncateNotification(message) {
    var pos = message.lastIndexOf('by');
    String? result = (pos != -1) ? message.substring(0, pos) : message;
    return result;
  }

  /*ListTile makeListTile(Test test) => ListTile(
    contentPadding:
    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    leading: Container(
      padding: EdgeInsets.only(right: 12.0),
      decoration: new BoxDecoration(
          border: new Border(
              right: new BorderSide(width: 1.0, color: Colors.white24))),
      child: Icon(Icons.favorite, color: Colors.black),
    ),
    title: Text(
      test.motherName,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),


    subtitle: Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(test.level,
                  style: TextStyle(color: Colors.white))),
        )
      ],
    ),
    trailing:
    Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
    onTap: () {

      //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
    },
  );*/
}
