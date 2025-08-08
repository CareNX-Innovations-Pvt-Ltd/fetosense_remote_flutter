import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppwriteService', () {
    test('should initialize client with correct endpoint and project', () {
      // Act
      final service = AppwriteService();
      final client = service.instance;

      // Assert
      expect(client.endPoint, AppConstants.appwriteEndpoint);
      expect(client.config['project'], AppConstants.appwriteProjectId);
    });

    test('should return same client instance via getter', () {
      // Arrange
      final service = AppwriteService();

      // Act
      final instance1 = service.instance;
      final instance2 = service.instance;

      // Assert
      expect(instance1, same(instance2));
    });
  });
}
