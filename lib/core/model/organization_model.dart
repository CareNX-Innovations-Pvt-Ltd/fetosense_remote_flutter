import 'package:fetosense_remote_flutter/core/model/user_model.dart';

/// A model class representing an organization, extending the [UserModel] class.
class Organization extends UserModel {
  int noOfDevices = 0;

  /// Default constructor for the [Organization] class.
  Organization();

  /// Constructs an [Organization] instance from a map.
  ///
  /// [snapshot] is a map containing the organization data.
  /// [id] is the unique identifier of the organization.
  Organization.fromMap(super.snapshot)
        :noOfDevices = snapshot['noOfTests'] ?? 0,
        super.fromMap();

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
