import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart'
    as n;
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/notification_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:fetosense_remote_flutter/ui/widgets/in_app_web_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/notificationCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A StatefulWidget that displays a list of notifications for a doctor.
class NotificationListView extends StatefulWidget {
  /// [doctor] is the doctor model containing the details to be displayed.
  final Doctor? doctor;

  const NotificationListView({super.key, required this.doctor});

  @override
  NotificationListViewState createState() => NotificationListViewState();
}

class NotificationListViewState extends State<NotificationListView> {
  late List<n.Notification> notifications;
  final NotificationCRUDModel _updateNotification = NotificationCRUDModel();

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // child: StreamBuilder<List<n.Notification>>(
      //   stream: Provider.of<NotificationCRUDModel>(context)
      //       .fetchTestsAsStream(widget.doctor!.documentId!),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       final notifications = snapshot.data!;
      //
      //       return notifications.isEmpty
      //           ? const Center(
      //         child: Text(
      //           'No notifications yet',
      //           style: TextStyle(
      //             fontWeight: FontWeight.w800,
      //             color: Colors.grey,
      //             fontSize: 20,
      //           ),
      //         ),
      //       )
      //           : ListView.builder(
      //         itemCount: notifications.length,
      //         shrinkWrap: true,
      //         itemBuilder: (context, index) {
      //           final notification = notifications[index];
      //
      //           return InkWell(
      //             onTap: () {
      //               debugPrint('notification click ${notification.module}');
      //
      //               if (!notification.read) {
      //                 notification.read = true;
      //                 _updateNotification.updateReadNotification(
      //                   notification.read,
      //                   notification.documentId,
      //                 );
      //               }
      //
      //               _navigateUserOnNotificationClick(
      //                 notification.module,
      //                 notification,
      //               );
      //             },
      //             child: NotificationCard(notification: notification),
      //           );
      //         },
      //       );
      //     } else if (snapshot.hasError) {
      //       return Center(
      //         child: Text(
      //           'Error loading notifications: ${snapshot.error}',
      //           style: const TextStyle(color: Colors.red),
      //         ),
      //       );
      //     } else {
      //       return const Center(
      //         child: CircularProgressIndicator(
      //           valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      //         ),
      //       );
      //     }
      //   },
      // ),
    );
  }


  /// Navigates the user based on the notification payload.
  ///
  /// [payload] is the type of notification.
  /// [message] is the notification message.
  _navigateUserOnNotificationClick(
      String? payload, n.Notification message) async {
    if (payload == 'text') {
      if (message.message != null && message.message != "") {
        _modalBottomSheetMenuImageNotification(
            message.title, message.message, false, message.imageUrl);
      }
    } else if (payload == 'link') {
      if (message.link != null && message.link != "") {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => InAppWebView(message.title, message.link),
          ),
        );
        // }
      }
    } else if (payload == 'image') {
      if (message.imageUrl != null && message.imageUrl != "") {
        _modalBottomSheetMenuImageNotification(
            message.title, message.message, true, message.imageUrl);
      }
    }
  }

  /// Displays a modal bottom sheet with the notification details.
  ///
  /// [title] is the title of the notification.
  /// [body] is the body of the notification.
  /// [hasImage] indicates if the notification has an image.
  /// [imageUrl] is the URL of the image.
  void _modalBottomSheetMenuImageNotification(
      String? title, String? body, bool hasImage, String? imageUrl) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
          builder: (context, StateSetter state) {
            return Wrap(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Divider(
                            thickness: 2,
                            color: borderLightColor,
                          )),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 40),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 28,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Flexible(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      title!,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, right: 4, bottom: 15),
                              child: Text(
                                body!,
                                // style: Utils().metropolisRegular24(),
                              ),
                            ),
                            hasImage && imageUrl != null && imageUrl.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20, bottom: 10),
                                    child: FadeInImage(
                                      image: NetworkImage(imageUrl),
                                      placeholder: const AssetImage(
                                          "assets/week_placeholder.png"),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: greenColor,
                          child: MaterialButton(
                            padding: const EdgeInsets.all(15),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: greenColor,
                            elevation: 0,
                            child: const Text(
                              'DONE!',
                              // style: Utils().upperWhite20SM(),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
