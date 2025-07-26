import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('should match test route keys', () {
      expect(AppConstants.instantTest, 'instant-test');
      expect(AppConstants.registeredMother, 'registered');
      expect(AppConstants.testRoute, 'test-route');
      expect(AppConstants.homeRoute, 'home-route');
      expect(AppConstants.motherDetailsRoute, 'mother-detail-route');
    });

    test('should match appwrite configuration values', () {
      expect(AppConstants.appwriteDatabaseId, '684c19ee00122a8eec2a');
      expect(AppConstants.userCollectionId, '684c19fa00162a9cbc57');
      expect(AppConstants.deviceCollectionId, '684c1a0200383bd0527c');
      expect(AppConstants.testsCollectionId, '684c1a13001f5e7a17c5');
      expect(AppConstants.configCollectionId, '6850060d00380d389603');
      expect(AppConstants.appwriteEndpoint, 'http://20.6.93.31/v1');
      expect(AppConstants.appwriteProjectId, '684c18890002a74fff23');
    });

    test('should match app settings keys - test section', () {
      expect(AppConstants.defaultTestDurationKey, 'defaultTestDurationKey');
      expect(AppConstants.fhrAlertsKey, 'fhrAlertsKey');
      expect(AppConstants.movementMarkerKey, 'movementMarkerKey');
      expect(AppConstants.patientIdKey, 'patientIdKey');
      expect(AppConstants.fisherScoreKey, 'fisherScoreKey');
      expect(AppConstants.twinReadingKey, 'twinReadingKey');
    });

    test('should match app settings keys - sharing section', () {
      expect(AppConstants.emailKey, 'emailKey');
      expect(AppConstants.shareAudioKey, 'shareAudioKey');
      expect(AppConstants.shareReportKey, 'shareReportKey');
    });

    test('should match app settings keys - printing section', () {
      expect(AppConstants.defaultPrintScaleKey, 'scale');
      expect(AppConstants.doctorCommentKey, 'comments');
      expect(AppConstants.autoInterpretationsKey, 'interpretations');
      expect(AppConstants.highlightPatternsKey, 'highlight');
      expect(AppConstants.displayLogoKey, 'displayLogoKey');
    });
  });
}
