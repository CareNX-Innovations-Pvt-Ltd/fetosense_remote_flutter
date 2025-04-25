import 'dart:convert';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:fetosense_remote_flutter/ui/widgets/scan_widget.dart';
import 'package:fetosense_remote_flutter/ui/widgets/update_org_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:appwrite/appwrite.dart';
import 'package:preferences/preferences.dart';

/// A widget that displays the details of a doctor.
class DoctorDetails extends StatefulWidget {
  /// A widget that displays the details of a doctor.
  final Doctor? doctor;

  /// The organization associated with the doctor.
  final Organization? org;

  /// The BabyBeat organization associated with the doctor.
  final Organization? orgBabyBeat;

  const DoctorDetails(
      {super.key,
      required this.doctor,
      this.org,
      this.orgBabyBeat,
      });

  @override
  State<StatefulWidget> createState() => DoctorDetailsState();
}

class DoctorDetailsState extends State<DoctorDetails> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _email;
  String? _name;
  String? _mobile;
  bool isEdit = false;
  bool isEditOrg = false;
  bool isEditOrgBB = false;
  Organization? organization;

  Organization? organizationBabyBeat;

  final FocusNode _nameFocus = FocusNode();

  String? code;

  Map<String, dynamic>? passKeys = {};

  final TextEditingController _passkeyController = TextEditingController();

  final TextEditingController _passkeyBabyBeatController =
      TextEditingController();

  final databases = Databases(locator<AppwriteService>().client);
  final users = Account(locator<AppwriteService>().client);

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getPaasKeys();
  }

  /// Fetches the pass keys from the Firestore database.
  /// Returns a [Future] that resolves to the pass keys.
  Future<void> getPaasKeys() async {
    try {
      final document = await databases.getDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.configCollectionId,
          documentId: 'PassKeys',
          queries: []);

      if (mounted) {
        setState(() {
          passKeys = Map<String, dynamic>.from(document.data);
        });
      }
    } on AppwriteException catch (e) {
      debugPrint("Error fetching PassKeys: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SizedBox(
          child: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: Colors.grey)),
                ),
                child: ListTile(
                  leading: IconButton(
                    iconSize: 35,
                    icon: const Icon(Icons.arrow_back,
                        size: 30, color: Colors.teal),
                    onPressed: () => Navigator.pop(context),
                  ),
                  subtitle: const Text(
                    "Profile",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
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
              Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      width: MediaQuery.of(context).size.width,
                      //color: Color.fromARGB(255, 238, 238, 238),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 0.5, color: Colors.teal)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text("Personal Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontSize: 18)),
                            !isEdit
                                ? MaterialButton(
                                    elevation: 2,
                                    highlightElevation: 2,
                                    shape: const OutlineInputBorder(),
                                    onPressed: () {
                                      setState(() {
                                        isEdit = true;
                                      });
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      FocusScope.of(context)
                                          .requestFocus(_nameFocus);
                                    },
                                    child: const Text('Edit'))
                                : MaterialButton(
                                    elevation: 2,
                                    highlightElevation: 2,
                                    shape: const OutlineInputBorder(),
                                    onPressed: () {
                                      if (validateAndSave()) {
                                        updateDoctorDetails();
                                        setState(() {
                                          isEdit = false;
                                        });
                                      }
                                    },
                                    child: const Text('Update'),
                                  )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            initialValue: widget.doctor!.name,
                            decoration: const InputDecoration(
                              hintText: 'Name',
                              icon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Name can\'t be empty' : null,
                            onSaved: (value) => _name = value!.trim(),
                            enabled: isEdit,
                            focusNode: _nameFocus,
                            textCapitalization: TextCapitalization.words,
                          ),
                          // TextFormField(
                          //   maxLines: 1,
                          //   keyboardType: TextInputType.number,
                          //   autofocus: false,
                          //   maxLength: 10,
                          //   initialValue: widget.doctor!.mobileNo.toString(),
                          //   decoration: const InputDecoration(
                          //     hintText: 'Mobile No',
                          //     icon: Icon(
                          //       Icons.phone,
                          //       color: Colors.grey,
                          //     ),
                          //   ),
                          //   validator: (value) => value!.isNotEmpty
                          //       ? value.length != 10
                          //           ? 'Invalid Mobile number'
                          //           : null
                          //       : null,
                          //   onSaved: (value) => _mobile = value!.trim(),
                          //   enabled:
                          //       isEdit ? !widget.isMobileVerified! : isEdit,
                          //   inputFormatters: <TextInputFormatter>[
                          //     FilteringTextInputFormatter.digitsOnly
                          //   ],
                          // ),
                          TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: false,
                            initialValue: widget.doctor!.email,
                            decoration: const InputDecoration(
                                hintText: 'Email',
                                icon: Icon(
                                  Icons.mail,
                                  color: Colors.grey,
                                )),
                            enabled: isEdit,
                            validator: (value) =>
                                value!.isEmpty ? 'Email can\'t be empty' : null,
                            onSaved: (value) => _email = value!.trim(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                width: MediaQuery.of(context).size.width,
                //color: Color.fromARGB(255, 238, 238, 238),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: Colors.teal,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("Fetosense Organization",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              fontSize: 18)),
                      !isEditOrg
                          ? MaterialButton(
                              elevation: 2,
                              highlightElevation: 2,
                              shape: const OutlineInputBorder(),
                              onPressed: () async {
                                setState(() {
                                  isEditOrg = true;
                                  // scanQR();
                                });
                                var result = await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => ScanWidget()));

                                // print("Result : " + result.toString());

                                if (result != null && result != 'Unknown') {
                                  scanQR(result);
                                } else {
                                  setState(() {
                                    isEditOrg = false;
                                    // scanQR();
                                  });
                                }
                              },
                              child: const Text('Update'))
                          : IconButton(
                              iconSize: 35,
                              icon: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                              onPressed: () {},
                            )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 32, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 16, 0),
                            child: Icon(
                              Icons.account_balance,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Text(
                                  widget.doctor!.organizationName == null
                                      ? ""
                                      : widget.doctor!.organizationName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    code != null
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Row(
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(4, 0, 16, 0),
                                  child: Icon(
                                    Icons.code,
                                    color: Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                      child: Text(
                                        code ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Row(children: <Widget>[]),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                width: MediaQuery.of(context).size.width,
                //color: Color.fromARGB(255, 238, 238, 238),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: Colors.teal,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text("BabyBeat Organization",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              fontSize: 18)),
                      !isEditOrgBB
                          ? MaterialButton(
                              elevation: 2,
                              highlightElevation: 2,
                              shape: const OutlineInputBorder(),
                              onPressed: () async {
                                setState(() {
                                  isEditOrgBB = true;
                                });
                                var result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ScanWidget(),
                                  ),
                                );

                                if (result != null && result != 'Unknown') {
                                  scanQRBabyBeat(result);
                                } else {
                                  setState(() {
                                    isEditOrgBB = false;
                                  });
                                }
                              },
                              child: const Text('Add'))
                          : IconButton(
                              iconSize: 35,
                              icon: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                              onPressed: () {},
                            )
                    ],
                  ),
                ),
              ),
              widget.doctor?.babyBeatAssociation != null
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.doctor?.babyBeatAssociation!.length,
                      itemBuilder: (context, index) {
                        String? key = widget.doctor?.babyBeatAssociation!.keys
                            .elementAt(index);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 32, 5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: Row(
                                      children: <Widget>[
                                        const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 0, 16, 0),
                                          child: Icon(
                                            Icons.account_balance,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 8),
                                              child: Text(
                                                widget.doctor
                                                            ?.babyBeatAssociation ==
                                                        null
                                                    ? ""
                                                    : widget.doctor
                                                            ?.babyBeatAssociation![
                                                        key]['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showDeleteAlertDialog(
                                                context,
                                                widget.doctor
                                                        ?.babyBeatAssociation![
                                                    key]['documentId']);
                                          },
                                          child: const Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(8, 0, 3, 0),
                                            child: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ]),
                        );
                      })
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the delete confirmation dialog.
  /// [context] is the build context.
  /// [documentId] is the ID of the document to be deleted.
  void showDeleteAlertDialog(BuildContext context, String? documentId) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text("Confirm"),
      onPressed: () async {
        try {
          final docId = widget.doctor!.documentId!;
          final doctorDoc = await databases.getDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.userCollectionId,
            documentId: docId,
          );
          final doctorData = Map<String, dynamic>.from(doctorDoc.data);
          final associations = Map<String, dynamic>.from(doctorData['babyBeatAssociation'] ?? {});
          associations.remove(documentId);

          await databases.updateDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.userCollectionId,
            documentId: docId,
            data: {'babyBeatAssociation': associations},
          );

          final hospitalDoc = await databases.getDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.userCollectionId,
            documentId: documentId!,
          );
          final hospitalData = Map<String, dynamic>.from(hospitalDoc.data);
          final reverseAssoc = Map<String, dynamic>.from(hospitalData['babyBeatAssociation'] ?? {});
          reverseAssoc.remove(docId);

          await databases.updateDocument(
            databaseId: AppConstants.appwriteDatabaseId,
            collectionId: AppConstants.userCollectionId,
            documentId: documentId,
            data: {'babyBeatAssociation': reverseAssoc},
          );

          // Clear selectedOrg if needed
          if (documentId == PrefService.getString('selectedOrg')) {
            PrefService.setString('selectedOrg', null);
          }

          setState(() {
            widget.doctor?.babyBeatAssociation!.remove(documentId);
          });

          Navigator.pop(context);
        } catch (e) {
          debugPrint("Deletion error: $e");
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content: Text('Something went wrong!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 3000),
          ));
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text(
        "Confirmation",
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text("Are you sure you want to disassociate this hospital?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Future<void> deleteBabyBeatAssociation(String documentId) async {
    try {
      final doctorId = widget.doctor!.documentId!;
      final doc = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doctorId,
      );
      final updated = Map<String, dynamic>.from(doc.data);
      updated['babyBeatAssociation'].remove(documentId);

      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doctorId,
        data: {'babyBeatAssociation': updated['babyBeatAssociation']},
      );

      // Repeat reverse removal
      final orgDoc = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: documentId,
      );
      final orgData = Map<String, dynamic>.from(orgDoc.data);
      orgData['babyBeatAssociation']?.remove(doctorId);

      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: documentId,
        data: {'babyBeatAssociation': orgData['babyBeatAssociation']},
      );

      setState(() {
        widget.doctor?.babyBeatAssociation!.remove(documentId);
      });
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }


  /// Shows the organization update dialog.
  void showOrgDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateOrgDialog(callback: updateOrg);
      },
      barrierDismissible: false,
    );
  }

  /// Scans the QR code for the organization.
  /// [barcodeScanRes] is the scanned QR code result.
  Future<void> scanQR(String barcodeScanRes) async {
    setState(() {
      isEditOrg = false;
    });
    if (barcodeScanRes != "-1" && barcodeScanRes.isNotEmpty) {
      try {
        String result;
        result = barcodeScanRes;
        result = result.replaceAll("FETOSENSE:", "");
        result = result.replaceAll("fetosense:", "");

        String decoded = utf8.decode(base64.decode(result));

        debugPrint('decoded id is $decoded');
        updateOrg(decoded);
      } on FormatException {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
            .showSnackBar(const SnackBar(
          content: Text('Invalid QR CODE'),
        ));
      }
    }
  }

  /// Scans the QR code for the BabyBeat organization.
  /// [barcodeScanRes] is the scanned QR code result.
  Future<void> scanQRBabyBeat(String barcodeScanRes) async {
    setState(() => isEditOrgBB = false);

    if (barcodeScanRes != "-1" && barcodeScanRes.isNotEmpty) {
      try {
        Map<String, dynamic> mapHospital = jsonDecode(barcodeScanRes);

        if (mapHospital['type'] == "babybeat") {
          final doc = await databases.getDocument(
            databaseId: 'your_database_id',
            collectionId: 'users',
            documentId: mapHospital['hospitalId'],
          );

          final dbPartner = doc.data;
          if (dbPartner['documentId'] == mapHospital['hospitalId']) {
            _enterMPIDBottomSheetBabyBeat(
                mapHospital['hospitalId'], mapHospital['hospitalName']);
          } else {
            _showError('Something went wrong!');
          }
        } else {
          _showError('Invalid QR CODE');
        }
      } catch (_) {
        _showError('Invalid QR CODE');
      }
    }
  }


  /// Shows the bottom sheet to enter the pass key for BabyBeat.
  /// [hospitalid] is the ID of the hospital.
  /// [hospitalName] is the name of the hospital.
  void _enterMPIDBottomSheetBabyBeat(String? hospitalid, String? hospitalName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter state) {
            return Wrap(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: Divider(thickness: 2, color: greyRegular),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: const Text(
                          "Your Hospital name is :",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        hospitalName!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Please enter your passkey to continue",
                        textAlign: TextAlign.left,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(25, 20, 25, 30),
                          child: TextFormField(
                            controller: _passkeyBabyBeatController,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            maxLength: 20,
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterStyle: const TextStyle(height: double.minPositive),
                              counterText: "",
                              hintText: "Enter Pass Key",
                              fillColor: lightTealColor,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: greenColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: themeColor,
                          child: MaterialButton(
                            padding: const EdgeInsets.all(20),
                            color: greenColor,
                            elevation: 0,
                            onPressed: () async {
                              if (_passkeyBabyBeatController.text.trim() == passKeys!['bsv']) {
                                final doctorId = widget.doctor!.documentId!;
                                Map<String, dynamic> doctorAssociation = widget.doctor!.babyBeatAssociation ?? {};
                                Map<String, dynamic> hospitalAssociation = {};

                                doctorAssociation['hospitalid'] = {
                                  'documentId': hospitalid,
                                  'name': hospitalName,
                                  'type': "organization"
                                };

                                hospitalAssociation[doctorId] = {
                                  'documentId': doctorId,
                                  'name': widget.doctor!.name,
                                  'type': "doctor"
                                };

                                try {
                                  // Update doctor document
                                  await databases.updateDocument(
                                    databaseId: AppConstants.appwriteDatabaseId,
                                    collectionId: AppConstants.userCollectionId,
                                    documentId: doctorId,
                                    data: {
                                      "babyBeatAssociation": doctorAssociation,
                                    },
                                  );

                                  // Update hospital document
                                  final hospitalDoc = await databases.getDocument(
                                    databaseId: AppConstants.appwriteDatabaseId,
                                    collectionId: AppConstants.userCollectionId,
                                    documentId: hospitalid!,
                                  );

                                  Map<String, dynamic> hospitalData = Map<String, dynamic>.from(hospitalDoc.data);
                                  Map<String, dynamic> currentHospitalAssoc =
                                  Map<String, dynamic>.from(hospitalData['babyBeatAssociation'] ?? {});
                                  currentHospitalAssoc[doctorId] = hospitalAssociation[doctorId];

                                  await databases.updateDocument(
                                    databaseId: AppConstants.appwriteDatabaseId,
                                    collectionId: AppConstants.userCollectionId,
                                    documentId: hospitalid,
                                    data: {
                                      "babyBeatAssociation": currentHospitalAssoc,
                                    },
                                  );

                                  setState(() {
                                    widget.doctor!.babyBeatAssociation = doctorAssociation;
                                  });

                                  Navigator.pop(context);
                                } catch (e) {
                                  debugPrint("Appwrite Error: $e");
                                  Navigator.pop(context);
                                  _showError("Something went wrong!");
                                }
                              } else {
                                _showError("Invalid Pass Key!");
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }


  /// Updates the organization based on the scanned code.
  /// [code] is the scanned code.
  updateOrg(String code) async {
    //String cameraScanResult = code ;//await scanner.scanPhoto();
    if (code.isEmpty) {
      setState(() {
        isEditOrg = false;
      });
      return;
    }

    if (code.contains("CMFETO")) {
      //cameraScanResult = cameraScanResult.replaceAll("FETOSENSE:", "");
      //String result = utf8.decode(base64.decode(cameraScanResult));
      getDevice(code);
    } else {
      setState(() {
        isEditOrg = false;
      });
      Fluttertoast.showToast(
          msg: 'Invalid code', toastLength: Toast.LENGTH_LONG);
    }
  }

  /// Fetches the device details based on the key.
  /// [key] is the device key.
  Future<void> getDevice(String key) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('deviceCode', key)],
      );

      if (result.documents.isNotEmpty) {
        final deviceData = result.documents.first.data;
        _enterMPIDBottomSheet(deviceData['organizationId'], deviceData['hospitalName']);
        setState(() {
          code = deviceData['deviceCode'];
        });
      }
    } catch (e) {
      debugPrint("getDevice error: $e");
    }
  }


  /// Shows the bottom sheet to enter the pass key for the organization.
  /// [hospitalid] is the ID of the hospital.
  /// [hospitalName] is the name of the hospital.
  void _enterMPIDBottomSheet(String? hospitalid, String? hospitalName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter state) {
            return Wrap(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: Divider(
                          thickness: 2,
                          color: greyRegular,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: const Text(
                          "Your Hospital name is :",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        hospitalName ?? '',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width * 0.10),
                      const Text(
                        "Please enter your passkey to continue",
                        textAlign: TextAlign.left,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(25, 20, 25, 30),
                          child: TextFormField(
                            controller: _passkeyController,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            maxLength: 20,
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterStyle: const TextStyle(height: double.minPositive),
                              counterText: "",
                              hintText: "Enter Pass Key",
                              fillColor: lightTealColor,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: greenColor),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: greenColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: themeColor,
                          child: MaterialButton(
                            padding: const EdgeInsets.all(20),
                            color: greenColor,
                            elevation: 0,
                            onPressed: () async {
                              if (_passkeyController.text.trim() ==
                                  passKeys!['fetosense']) {
                                try {
                                  await databases.updateDocument(
                                    databaseId: AppConstants.appwriteDatabaseId,
                                    collectionId: AppConstants.userCollectionId,
                                    documentId: widget.doctor!.documentId!,
                                    data: {
                                      'organizationId': hospitalid,
                                      'name': hospitalName,
                                    },
                                  );

                                  setState(() {
                                    widget.doctor!.organizationName = hospitalName;
                                  });

                                  getOrganization(hospitalid!);
                                  Navigator.pop(context);
                                } catch (e) {
                                  debugPrint("Appwrite error: $e");
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                    _scaffoldKey.currentState!.context,
                                  ).showSnackBar(const SnackBar(
                                    content: Text('Something went wrong!'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(milliseconds: 3000),
                                  ));
                                }
                              } else {
                                ScaffoldMessenger.of(
                                  _scaffoldKey.currentState!.context,
                                ).showSnackBar(const SnackBar(
                                  content: Text('Invalid Pass Key!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(milliseconds: 3000),
                                ));
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  /// Fetches the organization details based on the ID.
  /// [id] is the organization ID.
  Future<void> getOrganization(String id) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: id,
      );

      final data = doc.data;
      setState(() {
        organization = Organization.fromMap(data);
        organization!.deviceCode = id;
        isEditOrg = false;
      });
      // setOrg!(organization!);
      setDeviceAssociations(id);
    } catch (e) {
      Fluttertoast.showToast(msg: 'No organization found');
      setState(() => isEditOrg = false);
    }
  }


  /// Sets the device associations for the doctor.
  /// [orgId] is the organization ID.
  Future<void> setDeviceAssociations(String? orgId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('type', 'device'),
          Query.equal('organizationId', orgId),
        ],
      );

      for (final doc in result.documents) {
        final docId = doc.$id;
        final data = Map<String, dynamic>.from(doc.data);

        final Map<String, dynamic> associationData = {
          "name": widget.doctor!.name,
          "type": "doctor",
          "id": widget.doctor!.documentId
        };

        final associations = Map<String, dynamic>.from(data['associations'] ?? {});
        associations[widget.doctor!.documentId!] = associationData;

        await databases.updateDocument(
          databaseId: 'your_database_id',
          collectionId: 'users',
          documentId: docId,
          data: {'associations': associations},
        );
      }
    } catch (e) {
      debugPrint("setDeviceAssociations error: $e");
    }
  }


  /// Updates the doctor details in the Firestore database.
  Future<void> updateDoctorDetails() async {
    final data = {
      "name": _name,
      "mobileNo": _mobile,
      "email": _email,
    };

    try {
      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: widget.doctor!.documentId!,
        data: data,
      );

      widget.doctor!.name = _name;
      setDeviceAssociations(widget.doctor!.organizationId);
    } catch (e) {
      debugPrint("Update doctor error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

}
