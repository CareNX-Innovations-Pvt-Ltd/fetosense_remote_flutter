import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locater.dart';

class InitialProfileUpdate extends StatefulWidget {
  final Doctor doctor;

  const InitialProfileUpdate({
    super.key,
    required this.doctor,
  });

  @override
  InitialProfileUpdateState createState() => InitialProfileUpdateState();
}

class InitialProfileUpdateState extends State<InitialProfileUpdate> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final databases = Databases(locator<AppwriteService>().client);

  @override
  void initState() {
    super.initState();
    nameController.text = widget.doctor.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLogo(),
              const SizedBox(height: 30),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        radius: 140,
        backgroundColor: Colors.transparent,
        child: Image.asset('images/ic_banner.png'),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Enter Name",
        filled: true,
        fillColor: Colors.teal.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) =>
      (value == null || value.trim().isEmpty) ? "Please enter a name" : null,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 40,
      child: MaterialButton(
        color: Colors.teal,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: _saveProfile,
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();

    try {
      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: widget.doctor.documentId!,
        data: {
          "name": name,
          "email": widget.doctor.email,
          "type": "doctor",
        },
      );
      widget.doctor.name = name;
      if (mounted) {
        context.goNamed(
          AppRoutes.initProfileUpdate2,
          extra: widget.doctor,
        );
      }
    } catch (e) {
      debugPrint("Appwrite error: $e");
      showSnackbar("Something went wrong while saving.");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
