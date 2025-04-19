import 'package:fetosense_remote_flutter/core/model/user_model.dart';

/// A model class representing a doctor, extending the [UserModel] class.
class Doctor extends UserModel {
  @override
  int? noOfMother = 0;
  @override
  int? noOfTests = 0;

  /// Default constructor for the [Doctor] class.
  Doctor();

  /// Constructs a [Doctor] instance from a map.
  ///
  /// [snapshot] is a map containing the doctor data.
  /// [id] is the unique identifier of the doctor.
  Doctor.fromMap(super.snapshot)
      : noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap();

  Doctor.fromJson(Map<String, dynamic> json) {
    Doctor()
      ..noOfMother = json['noOfMother']
      ..noOfTests = json['noOfTests'];
  }
}
