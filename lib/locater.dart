import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/appwrite_api.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/core/view_models/notification_crud_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:get_it/get_it.dart';
import 'core/services/testapi.dart';
import 'core/view_models/crud_view_model.dart';

/// Sets up the service locator with the necessary services and view models.

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton(AppwriteService());
  locator.registerSingleton<BaseAuth>(Auth());
  locator.registerSingleton(Databases(locator<AppwriteService>().client));
  locator.registerLazySingleton(() => AppwriteApi(
        database: locator<Databases>(),
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
      ));
  locator.registerLazySingleton(() => CRUDModel());
  locator.registerLazySingleton(
    () => TestApi(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.testsCollectionId,
      databaseInstance: locator<Databases>(),
    ),
  );
  locator.registerLazySingleton(
    () => TestCRUDModel(),
  );

  locator.registerLazySingleton(
    () => AppwriteNotificationApi(
      db: locator<Databases>(),
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.userCollectionId,
    ),
  );

  locator.registerLazySingleton(
    () => NotificationCRUDModel(),
  );
  locator.registerLazySingleton(() => PreferenceHelper());

}
