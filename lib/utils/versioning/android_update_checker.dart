import 'dart:convert';

import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckUpdate {
  static const String apiUrl =
      "https://yourserver.com/version-check"; // API URL
  static const String versionInfoUrl =
      "https://drive.google.com/uc?export=download&id=18a43EmGQ93AFCqpqzP1jOhtSQMr1J_Wt"; // Google Drive JSON file ID

  static Future<Map<String, dynamic>?> getDriveFileVersion() async {
    try {
      final response = await http.get(Uri.parse(versionInfoUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetching version info from Google Drive: $e");
    }
    return null;
  }

  static Future<void> checkForUpdate() async {
    String updateUrl = "";
    String latestVersion = "";
    bool forceUpdate = false;

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        latestVersion = data["latest_version"];
        updateUrl = data["update_url"] ?? "";
        forceUpdate = data["force_update"] ?? false;
      }
    } catch (e) {
      print("API not available, checking Google Drive version.");
      final driveData = await getDriveFileVersion();
      if (driveData != null) {
        latestVersion = driveData["latest_version"] ?? "";
        updateUrl = driveData["update_url"] ?? "";
        forceUpdate = driveData["force_update"] ?? false;
      }
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    print("Current version: $currentVersion");
    print("Latest version: $latestVersion");

    if (latestVersion.isNotEmpty && currentVersion != latestVersion) {
      showUpdateDialog(updateUrl, forceUpdate);
    }
  }

  static void showUpdateDialog(String updateUrl, bool forceUpdate) {
    Get.defaultDialog(
      title: "",
      barrierDismissible: !forceUpdate,
      backgroundColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      radius: 20,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.system_update, size: 60, color: AppColors.primary),
          SizedBox(height: 10),
          Text(
            "Update Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "A new version of the app is available.\nPlease update to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!forceUpdate)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text("Later"),
                  ),
                ),
              if (!forceUpdate) SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse(updateUrl)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Update Now"),
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((_) {
      if (forceUpdate) {
        SystemNavigator.pop(); // Close app if update is mandatory
      }
    });
  }
}
