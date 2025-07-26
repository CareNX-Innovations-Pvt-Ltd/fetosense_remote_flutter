import 'package:connectivity_plus/connectivity_plus.dart';

/// A class that provides methods to check internet connectivity.
class InternetCheck {
  /// Checks the current internet connectivity status.
  ///
  /// Returns a [Future] that completes with `true` if the device is connected to the internet via mobile or WiFi, `false` otherwise.
  Future<bool> check() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // If using List<ConnectivityResult>
    if (connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi)) {
      return true;
    }

    return false;
  }

  /// Checks the internet connectivity and executes the provided [func] with the result.
  dynamic checkInternet(Function(bool) func) {
    check().then((internet) {
      func(internet);
    });
  }
}
