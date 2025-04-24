import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/ui/widgets/mother_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A StatefulWidget that displays a list of active mothers associated with a doctor and organization.
class MotherListView extends StatefulWidget {
  final Doctor? doctor;
  final Organization? organization;

  //HomeView(@required this.doctor);

  /// [doctor] is the doctor model.
  /// [organization] is the organization model.
  const MotherListView({super.key, this.doctor, this.organization});

  @override
  MotherListViewState createState() => MotherListViewState();
}

class MotherListViewState extends State<MotherListView> {
  late List<Mother> mothers;

  bool isReplay = false;

  int? count;

  @override
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
                subtitle: const Text(
                  "Active mothers",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                title: const Text(
                  "fetosense",
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                ),
                trailing: Image.asset('images/ic_logo_good.png'),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: widget.doctor?.organizationId?.isNotEmpty == true
                    ? StreamBuilder<List<Mother>>(
                        stream: Provider.of<CRUDModel>(context)
                            .fetchActiveMothersAsStream(
                                widget.doctor!.organizationId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final mothers = snapshot.data!;
                            return ListView.builder(
                              itemCount: mothers.length,
                              itemBuilder: (context, index) =>
                                  MotherCard(motherDetails: mothers[index]),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading mothers: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            );
                          }
                        },
                      )
                    : const Center(
                        child: Text(
                          'Please update your fetosense organization details',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
