import 'package:doc_sync/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  // Ensure that all widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX Local Storage
  await GetStorage.init();

  // Remove # sign from the url
  setPathUrlStrategy();

  // Main App Starts Here
  runApp(const App());
}
