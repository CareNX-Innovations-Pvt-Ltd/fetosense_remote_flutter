import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

// -------------------- MOCK CLASSES -------------------- //

class MockDatabases extends Mock implements Databases {}

class MockAppwriteService extends Mock implements AppwriteService {}

class MockFlutterBarcodeScanner extends Mock implements FlutterBarcodeScanner {}

class MockGoRouter extends Mock implements GoRouter {}

class MockBuildContext extends Mock implements BuildContext {}

class MockDocument extends Mock implements Document {}

class MockDocumentList extends Mock implements DocumentList {}

// -------------------- FAKE MODELS -------------------- //

class FakeDoctor extends Fake implements Doctor {}

class FakeOrganization extends Fake implements Organization {}

class FakeDocument extends Fake implements Document {
  @override
  final Map<String, dynamic> data;

  FakeDocument(this.data);
}

// -------------------- HELPER STUB FUNCTIONS -------------------- //

void registerFallbacks() {
  registerFallbackValue(FakeDoctor());
  registerFallbackValue(FakeOrganization());
  registerFallbackValue(FakeDocument({'deviceCode': 'FAKE_CODE'}));
}
