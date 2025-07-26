import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appwrite/appwrite.dart';

void main() {
  group('AppwriteService', () {
    late AppwriteService service;

    setUp(() {
      service = AppwriteService();
    });

    test('should initialize Appwrite client with correct endpoint and project ID', () {
      final client = service.instance;

      expect(client.endPoint, AppConstants.appwriteEndpoint);
      expect(client.config['project'], AppConstants.appwriteProjectId);
    });

    test('should return a valid Client instance', () {
      expect(service.instance, isA<Client>());
    });
  });
}
