import 'package:doc_sync/utils/local_storage/storage_utility.dart';

class ApiConstants {
  static final ApiConstants _instance = ApiConstants._internal();

  factory ApiConstants() => _instance;

  ApiConstants._internal();

  String organization = "";

  String get baseUrl =>
      'https://pragmanxt.com/docsync_$organization/services/admin/v1/index.php';

  static const Duration timeoutDuration = Duration(seconds: 15);
  
  // Method to change organization and return updated baseUrl
  void changeOrganization(String newOrganization) {
    organization = newOrganization;
    StorageUtility.instance().writeData('organization', newOrganization);
    print('Organization changed to: $organization');
    print('New base URL: $baseUrl');
  }
}