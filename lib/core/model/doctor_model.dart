import 'package:fetosense_remote_flutter/core/model/user_model.dart';

/// A model class representing a doctor, extending the [UserModel] class.
class Doctor extends UserModel {
  @override
  int? noOfMother;
  @override
  int? noOfTests;

  /// Default constructor with optional named parameters
  Doctor({
    String? name,
    String? email,
    String? documentId,
    this.noOfMother = 0,
    this.noOfTests = 0,
  }) : super.withData(
    name: name,
    email: email,
    documentId: documentId,
    noOfMother: noOfMother,
    noOfTests: noOfTests,
  );

  Doctor.fromMap(Map<String, dynamic> snapshot)
      : noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap(snapshot);

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      email: json['email'],
      documentId: json['documentId'],
      noOfMother: json['noOfMother'],
      noOfTests: json['noOfTests'],
    );
  }
}

