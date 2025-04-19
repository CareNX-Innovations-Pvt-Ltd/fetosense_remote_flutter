import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locater.dart';

/// A StatefulWidget that handles the initial profile update for a doctor.
class InitialProfileUpdate extends StatefulWidget {
  /// [doctor] is the doctor model.
  final Doctor? doctor;
  const InitialProfileUpdate({super.key,  this.doctor});

  @override
  InitialProfileUpdateState createState() => InitialProfileUpdateState();
}

class InitialProfileUpdateState extends State<InitialProfileUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _name;
  String? _email;
  bool isEmailThere = false;
  final databases = Databases(locator<AppwriteService>().client);
  BaseAuth auth = locator<BaseAuth>();

  @override
  void initState() {
    super.initState();
    debugPrint("DOCTOR: ${widget.doctor?.email}");
    auth.getCurrentUser().then((user) {
      debugPrint("USERS: $user");
      if (widget.doctor?.email?.isNotEmpty == true) {
        setState(() {
          isEmailThere = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Stack(
          children: <Widget>[
            _showForm(),
          ],
        ),
      ),
    );
  }

  /// Displays the form for updating the profile.
  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            const SizedBox(
              height: 30,
            ),
            showNameInput(),
            const SizedBox(
              height: 16,
            ),
            showEmailInput(),
            const SizedBox(
              height: 16,
            ),
            showPrimaryButton(),
          ],
        ),
      ),
    );
  }

  /// Displays the logo.
  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 140.0,
          child: Image.asset('images/ic_banner.png'),
        ),
      ),
    );
  }

  /// Displays the name input field.
  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: TextFormField(
        autofocus: false,
        maxLines: 1,
        onSaved: (input) => setState(() {
          _name = input;
        }),
        onChanged: (input) {
          setState(() {
            _name = input;
          });
        },

        decoration: InputDecoration(
            counterStyle: const TextStyle(
              height: double.minPositive,
            ),
            counterText: "",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: const TextStyle(color: Colors.teal),
            labelText: "Name",
            hintText: "Enter Name",
            fillColor: Colors.teal.withOpacity(0.2),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            errorText: null,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal),
            )),
        // style: Utils().smallBlack18M(),
      ),
    );
  }

  /// Validates if the given string is a valid email.
  bool isEmail(String? string) {
    // Null or empty string is invalid
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  /// Displays the email input field.
  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Visibility(
        visible: !isEmailThere,
        child: TextFormField(
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          maxLines: 1,
          onSaved: (input) => setState(() {
            _email = input;
          }),

          onChanged: (input) {
            setState(() {
              _email = input;
            });
          },

          decoration: InputDecoration(
              counterStyle: const TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: const TextStyle(color: Colors.teal),
              hintText: "Enter Email",
              fillColor: Colors.teal.withOpacity(0.2),
              filled: true,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 0,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              errorText: null,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.teal),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.teal),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.teal),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.teal),
              )),
          // style: Utils().smallBlack18M(),
        ),
      ),
    );
  }

  /// Displays the primary button for saving the profile.
  Widget showPrimaryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 45.0, 30.0, 10.0),
      child: SizedBox(
        height: 40.0,
        child: MaterialButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.teal,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 17.0, color: Colors.white),
            ),
            onPressed: () async {
              Map<String, dynamic> data = {};

              if (_name != null) {
                data["name"] = _name!.trim();
              } else {
                data["name"] = _name;
              }
              data["email"] = _email ?? widget.doctor!.email!.trim();

              if (data["name"] == null ||
                  data["name"].toString().isEmpty ||
                  data["email"].toString().isEmpty) {
                showSnackbar("Please fill all detailsss !");
              } else {
                if (!isEmail(data["email"])) {
                  showSnackbar("Enter Valid Email !");
                  return;
                }
                widget.doctor!.email = data["email"];
                try {
                  await databases.updateDocument(
                    databaseId: AppConstants.appwriteDatabaseId,
                    collectionId: AppConstants.userCollectionId,
                    documentId: widget.doctor!.documentId!,
                    data: data,
                  );
                  context.pushReplacement(AppRoutes.initProfileUpdate2);
                } catch (e) {
                  debugPrint("Appwrite error: $e");
                  showSnackbar("Something went wrong while saving.");
                }
              }
            }),
      ),
    );
  }

  /// Displays a snackbar with the given message.
  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
        .showSnackBar(snackBar);
  }
}
