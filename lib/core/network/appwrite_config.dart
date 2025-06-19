import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';

class AppwriteService {
  final Client client;

  AppwriteService()
      : client = Client()
          ..setEndpoint(AppConstants.appwriteEndpoint)
          ..setProject(AppConstants.appwriteProjectId);

  Client get instance => client;
}
