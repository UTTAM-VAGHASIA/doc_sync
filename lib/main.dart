import 'package:device_preview/device_preview.dart';
import 'package:doc_sync/app.dart';
import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:doc_sync/utils/local_storage/app_local_storage.dart';
import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';

Future<void> main() async {
  // Ensure that all widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage - Now using SharedPreferences implementation
  await AppLocalStorage.getInstance('userData');
  await AppLocalStorage.getInstance('loginData');
  
  // Initialize ApiConstants
  await ApiConstants.init();

  // Remove # sign from the url
  setPathUrlStrategy();

  // Main App Starts Here
  runApp(
    DevicePreview(
      enabled:
          !kReleaseMode &&
          !(GetPlatform.isAndroid || GetPlatform.isIOS),
      builder: (context) => App(),
    ),
  );
}
