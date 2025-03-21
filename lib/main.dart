import 'package:doc_sync/app.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/versioning/android_update_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  // Ensure that all widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX Local Storage
  await GetStorage.init();

  // Ensure Network Manager is Initialized
  Get.put(NetworkManager());

  // Remove # sign from the url
  setPathUrlStrategy();

  // Check for new version for Android Apps
  if (await NetworkManager.instance.isConnected()) {
    if (AppDeviceUtils.isAndroid()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CheckUpdate.checkForUpdate();
      });
    }
  }

  // Main App Starts Here
  runApp(const App());
}
