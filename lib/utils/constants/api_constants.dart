import 'package:doc_sync/utils/local_storage/storage_utility.dart';

class ApiConstants {
  static final ApiConstants _instance = ApiConstants._internal();
  static bool _initialized = false;

  factory ApiConstants() => _instance;

  ApiConstants._internal();

  String _organization = "";

  String get organization => _organization;
  
  static Future<ApiConstants> init() async {
    if (!_initialized) {
      await _instance._initOrganization();
      _initialized = true;
    }
    return _instance;
  }

  Future<void> _initOrganization() async {
    _organization = await StorageUtility.instance().readData('organization') ?? "";
    print('Organization: $_organization');
    print("##########################################");
  }

  String get baseUrl =>
      'https://pragmanxt.com/docsync_$_organization/services/admin/v1/index.php';

  static const Duration timeoutDuration = Duration(seconds: 15);
  
  // Method to change organization and return updated baseUrl
  Future<void> changeOrganization(String newOrganization) async {
    _organization = newOrganization;
    await StorageUtility.instance().writeData('organization', newOrganization);
    print('Organization changed to: $_organization');
    print('New base URL: $baseUrl');
  }
}