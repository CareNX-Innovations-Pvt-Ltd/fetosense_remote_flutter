import 'package:fetosense_remote_flutter/core/model/user_model.dart';

/// A model class representing a doctor, extending the [UserModel] class.
class Doctor extends UserModel {
  int? noOfMother = 0;
  int? noOfTests = 0;

  /// Default constructor for the [Doctor] class.
  Doctor();

  /// Constructs a [Doctor] instance from a map.
  ///
  /// [snapshot] is a map containing the doctor data.
  /// [id] is the unique identifier of the doctor.
  Doctor.fromMap(super.snapshot, super.id)
      : noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap();

/*
  /// Converts the [Doctor] instance to a JSON map.
  ///
  /// Returns a map containing the doctor data.
  toJson() {
    return {
      "price": price,
      "name": name,
      "img": img,
    };
  }
  */
}
