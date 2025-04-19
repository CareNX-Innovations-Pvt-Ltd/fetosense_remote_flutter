import 'package:fetosense_remote_flutter/core/model/user_model.dart';

/// A model class representing an organization, extending the [UserModel] class.
class Organization extends UserModel {
  int noOfMother = 0;
  int noOfTests = 0;
  int noOfDevices = 0;
  String deviceCode = "";

  /// Default constructor for the [Organization] class.
  Organization();

  /// Constructs an [Organization] instance from a map.
  ///
  /// [snapshot] is a map containing the organization data.
  /// [id] is the unique identifier of the organization.
  Organization.fromMap(Map snapshot, String id)
      : noOfMother = snapshot['noOfMother'] ?? 0,
        noOfTests = snapshot['noOfTests'] ?? 0,
        noOfDevices = snapshot['noOfTests'] ?? 0,
        deviceCode = snapshot["deviceCode"] ?? '',
        super.fromMap(snapshot, id);

/*
  /// Converts the [Organization] instance to a JSON map.
  ///
  /// Returns a map containing the organization data.
  toJson() {
    return {
      "price": price,
      "name": name,
      "img": img,
    };
  }
  */
}
