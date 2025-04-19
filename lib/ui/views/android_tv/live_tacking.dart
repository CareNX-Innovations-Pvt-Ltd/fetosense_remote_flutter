import 'dart:async';

import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import '../settings_view.dart';
import 'live_tracking_card.dart';
import 'live_tracking_card_horizontal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// [LiveTrackingView] is a stateful widget that displays the live tracking view for the tests.
/// It shows the list of live tests and allows navigation to settings and logout functionality.
class LiveTrackingView extends StatefulWidget {
  final Doctor? doctor;
  final Organization? organization;
  final BaseAuth? auth;
  final VoidCallback? logoutCallback;
  final VoidCallback? profileupdate1Callback;
  // final VoidCallback? profileupdate2Callback;

  const LiveTrackingView(
      {super.key,
      this.doctor,
      this.organization,
      this.auth,
      this.logoutCallback,
      this.profileupdate1Callback,
      // this.profileupdate2Callback
      });

  @override
  _LiveTrackingViewState createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  late AnimationController _animationController;
  late List<Test> tests;

  int limit = 0;

  _LiveTrackingViewState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(widget.doctor.type);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        limit = widget.organization!.noOfDevices > 10
            ? 9
            : widget.organization!.noOfDevices;
      });
    });
    return limit == 0
        ? Center(
            child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(themeColor),
          ))
        : SafeArea(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.logoutCallback!();
                        },
                        child: Text(
                          "Central Monitoring",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: themeColor),
                        ),
                      ),
                      IconButton(
                        iconSize: 22,
                        icon: Icon(
                          Icons.settings,
                          color: themeColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsView(
                                doctor: widget.doctor,
                                organization: widget.organization,
                                logoutCallback: widget.logoutCallback,
                                auth: widget.auth,
                                profileUpdate1Callback:
                                    widget.profileupdate1Callback,
                                // profileUpdate2Callback:
                                //     widget.profileupdate2Callback,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: Image.asset('images/ic_logo_good.png'),
                ),
                widget.doctor != null
                    ? Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                          child: StreamBuilder(
                            stream: widget.doctor!.type == "doctor"
                                ? Provider.of<TestCRUDModel>(context)
                                    .fetchAllTestsAsStreamForTV(
                                        widget.doctor!.organizationId, limit)
                                : Provider.of<TestCRUDModel>(context)
                                    .fetchAllTestsAsStreamOrgForTV(
                                        widget.doctor!.documentId, limit),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                tests = snapshot.data!;

                                return tests.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No Live test yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey,
                                            fontSize: 20,
                                          ),
                                        ),
                                      )
                                    : tests.length == 1
                                        ? LiveTrackingCardHori(
                                            testDetails: tests[0],
                                            doctor: widget.doctor,
                                            organization: widget.organization,
                                          )
                                        : tests.length == 2
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: LiveTrackingCardHori(
                                                      testDetails: tests[0],
                                                      doctor: widget.doctor,
                                                      organization:
                                                          widget.organization,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 1,
                                                  ),
                                                  Expanded(
                                                    child: LiveTrackingCardHori(
                                                      testDetails: tests[1],
                                                      doctor: widget.doctor,
                                                      organization:
                                                          widget.organization,
                                                    ),
                                                  )
                                                ],
                                              )
                                            : tests.length == 3
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            LiveTrackingCardHori(
                                                          testDetails: tests[0],
                                                          doctor: widget.doctor,
                                                          organization: widget
                                                              .organization,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            LiveTrackingCardHori(
                                                          testDetails: tests[1],
                                                          doctor: widget.doctor,
                                                          organization: widget
                                                              .organization,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            LiveTrackingCardHori(
                                                          testDetails: tests[2],
                                                          doctor: widget.doctor,
                                                          organization: widget
                                                              .organization,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : tests.length == 4
                                                    ? GridView.builder(
                                                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                            childAspectRatio: 2,
                                                            crossAxisSpacing: 1,
                                                            mainAxisSpacing: 1),
                                                        itemCount: tests.length,
                                                        itemBuilder: (BuildContext ctx,
                                                            index) {
                                                          return LiveTrackingCard(
                                                            testDetails:
                                                                tests[index],
                                                            doctor:
                                                                widget.doctor,
                                                            organization: widget
                                                                .organization,
                                                          );
                                                        })
                                                    : tests.length == 5
                                                        ? GridView.builder(
                                                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                                                maxCrossAxisExtent:
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        3,
                                                                childAspectRatio:
                                                                    1.4,
                                                                crossAxisSpacing:
                                                                    10,
                                                                mainAxisSpacing:
                                                                    10),
                                                            itemCount:
                                                                tests.length,
                                                            itemBuilder:
                                                                (BuildContext ctx,
                                                                    index) {
                                                              return LiveTrackingCard(
                                                                testDetails:
                                                                    tests[
                                                                        index],
                                                                doctor: widget
                                                                    .doctor,
                                                                organization: widget
                                                                    .organization,
                                                              );
                                                            })
                                                        : tests.length == 6
                                                            ? GridView.builder(
                                                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                                                    maxCrossAxisExtent:
                                                                        MediaQuery.of(context).size.width / 3,
                                                                    childAspectRatio: 1.4,
                                                                    crossAxisSpacing: 10,
                                                                    mainAxisSpacing: 10),
                                                                itemCount: tests.length,
                                                                itemBuilder: (BuildContext ctx, index) {
                                                                  return LiveTrackingCard(
                                                                    testDetails:
                                                                        tests[
                                                                            index],
                                                                    doctor: widget
                                                                        .doctor,
                                                                    organization:
                                                                        widget
                                                                            .organization,
                                                                  );
                                                                })
                                                            : GridView.builder(
                                                                gridDelegate:
                                                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                                                  maxCrossAxisExtent:
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          3,
                                                                  childAspectRatio:
                                                                      2,
                                                                  crossAxisSpacing:
                                                                      1,
                                                                  mainAxisSpacing:
                                                                      1,
                                                                ),
                                                                itemCount: tests
                                                                    .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            ctx,
                                                                        index) {
                                                                  return LiveTrackingCard(
                                                                    testDetails:
                                                                        tests[
                                                                            index],
                                                                    doctor: widget
                                                                        .doctor,
                                                                    organization:
                                                                        widget
                                                                            .organization,
                                                                  );
                                                                },
                                                              );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Update your profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      )
              ],
            ),
          );
  }
}
