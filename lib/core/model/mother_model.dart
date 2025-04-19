import 'user_model.dart';

/// A model class representing a mother, extending the [UserModel] class.
class Mother extends UserModel {
  int? age;
  int? weight;
  DateTime? lmp;
  DateTime? edd;
  int? noOfTests = 0;
  String? deviceId;
  String? deviceName;

  /// Default constructor for the [Mother] class.
  Mother();

  /// Gets the age of the mother.
  ///
  /// Returns the age as an [int].
  int? getAge() {
    return age;
  }

  /// Sets the age of the mother.
  ///
  /// [age] is the new age to be set.
  void setAge(int age) {
    this.age = age;
  }

  /// Gets the weight of the mother.
  ///
  /// Returns the weight as an [int].
  int? getWeight() {
    return weight;
  }

  /// Sets the weight of the mother.
  ///
  /// [weight] is the new weight to be set.
  void setWeight(int weight) {
    this.weight = weight;
  }

  /// Gets the last menstrual period date.
  ///
  /// Returns the date as a [DateTime].
  DateTime? getLmp() {
    return lmp;
  }

  /// Sets the last menstrual period date.
  ///
  /// [lmp] is the new date to be set.
  void setLmp(DateTime lmp) {
    this.lmp = lmp;
  }

  /// Gets the estimated due date.
  ///
  /// Returns the date as a [DateTime].
  DateTime? getEdd() {
    return edd;
  }

  /// Sets the estimated due date.
  ///
  /// [edd] is the new date to be set.
  void setEdd(DateTime edd) {
    this.edd = edd;
  }

  /// Gets the number of tests conducted.
  ///
  /// Returns the number of tests as an [int].
  int? getNoOfTests() {
    return noOfTests;
  }

  /// Sets the number of tests conducted.
  ///
  /// [noOfTests] is the new number of tests to be set.
  void setNoOfTests(int noOfTests) {
    this.noOfTests = noOfTests;
  }

  /// Gets the device ID associated with the mother.
  ///
  /// Returns the device ID as a [String].
  String? getDeviceId() {
    return deviceId;
  }

  /// Sets the device ID associated with the mother.
  ///
  /// [deviceID] is the new device ID to be set.
  void setDeviceId(String deviceID) {
    deviceId = deviceID;
  }

  /// Gets the device name associated with the mother.
  ///
  /// Returns the device name as a [String].
  String? getDeviceName() {
    return deviceName;
  }

  /// Sets the device name associated with the mother.
  ///
  /// [deviceName] is the new device name to be set.
  void setDeviceName(String deviceName) {
    this.deviceName = deviceName;
  }

  /// Constructs a [Mother] instance from a map.
  ///
  /// [snapshot] is a map containing the mother data.
  /// [id] is the unique identifier of the mother.
  Mother.fromMap(Map<String, dynamic> super.snapshot, super.id)
      : age = snapshot['age'],
        weight = snapshot['weight'],
        lmp = snapshot['lmp']?.toDate() ?? DateTime.now(),
        edd = snapshot['edd']?.toDate() ?? DateTime.now(),
        noOfTests = snapshot['noOfTests'],
        deviceId = snapshot['deviceId'],
        deviceName = snapshot['deviceName'],
        super.fromMap();
}