import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/versioning/update_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Handles checking for application updates via GitHub Releases,
/// downloading the update package (APK), and prompting the user for installation.
/// Uses GetX for dialog state management.
class CheckUpdate {
  // --- Configuration ---
  // TODO: Replace with your actual GitHub username/org and repository name
  static const String githubOwner = "UT268"; // <<< REPLACE
  static const String githubRepo = "doc_sync"; // <<< REPLACE

  /// The key used with --dart-define to pass the GitHub Personal Access Token (Optional for private repos).
  /// Example build command:
  /// flutter build apk --release --dart-define=GITHUB_PAT=YOUR_TOKEN_HERE
  static const String _githubPatKey = 'GITHUB_PAT';

  /// The GitHub API endpoint for fetching the latest release information.
  static String get _githubApiUrl =>
      "https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest";

  // --- Security Warning ---
  // Storing PAT via --dart-define is convenient but NOT secure for production apps
  // with sensitive PATs. It can be extracted from the app package.
  // Consider a backend proxy for higher security.
  // --- End Warning ---

  /// Checks for updates via GitHub Releases. Should be called early in app startup.
  ///
  /// Returns `true` to indicate the app can proceed with normal startup,
  /// or `false` if a mandatory update requires the app to halt (or exit).
  static Future<bool> checkForUpdate() async {
    // Placeholder values
    String? assetApiUrl;
    String latestVersionTag = ""; // Store the full tag initially
    String latestVersionClean = ""; // Store the cleaned version
    bool forceUpdate = false;
    String releaseNotesBody = "No release notes available.";

    // Retrieve GitHub PAT (if provided via --dart-define)
    const String githubPat = String.fromEnvironment(
      _githubPatKey,
      defaultValue: '',
    );

    // --- PAT Logging ---
    if (githubPat.isEmpty && !_isPublicRepo()) {
      print(
        "CheckUpdate: WARNING - GitHub PAT not found via --dart-define '$_githubPatKey'. Update check for private repo might fail.",
      );
    } else if (githubPat.isNotEmpty) {
      print(
        "CheckUpdate: GitHub PAT found (using for API requests). NOTE: See security warning about --dart-define.",
      );
    } else {
      print("CheckUpdate: GitHub PAT not found, assuming public repository.");
    }

    print("CheckUpdate: Checking for updates at $_githubApiUrl");

    // --- Fetch Latest Release Info ---
    try {
      final response = await http
          .get(
            Uri.parse(_githubApiUrl),
            headers: {
              "Accept": "application/vnd.github.v3+json",
              if (githubPat.isNotEmpty)
                "Authorization":
                    "Bearer $githubPat", // Only include if PAT exists
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        latestVersionTag = data['tag_name'] ?? '';

        if (latestVersionTag.isEmpty) {
          print(
            "CheckUpdate: Error - 'tag_name' missing in GitHub API response.",
          );
          return true; // Proceed if no tag found
        }
        print("CheckUpdate: Latest release tag found: $latestVersionTag");

        releaseNotesBody = data['body'] ?? 'No release notes available.';

        // Clean version and check for force update flag
        latestVersionClean =
            (latestVersionTag.startsWith('v')
                    ? latestVersionTag.substring(1)
                    : latestVersionTag)
                .split('-')[0];
        forceUpdate = latestVersionTag.toLowerCase().endsWith('-force');

        // Find APK asset URL
        final List<dynamic> assets = data['assets'] ?? [];
        for (var asset in assets) {
          final String? assetName = asset['name'];
          if (assetName != null && assetName.toLowerCase().endsWith('.apk')) {
            assetApiUrl = asset['url']; // API URL for authenticated download
            print(
              "CheckUpdate: Found APK asset: $assetName, API URL: $assetApiUrl",
            );
            break;
          }
        }

        if (assetApiUrl == null) {
          print(
            "CheckUpdate: Error - No '.apk' asset found in the latest release ('$latestVersionTag').",
          );
          return true; // Proceed if no APK found
        }
        print(
          "CheckUpdate: Derived Version: $latestVersionClean, Force Update: $forceUpdate",
        );
      } else {
        // Handle API errors
        print(
          "CheckUpdate: Error fetching update info. Status: ${response.statusCode}, Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}",
        ); // Limit body log
        if (response.statusCode == 401) {
          print(
            "CheckUpdate: Hint: GitHub API returned 401 Unauthorized. Check PAT validity/scope.",
          );
        } else if (response.statusCode == 403) {
          print(
            "CheckUpdate: Hint: GitHub API returned 403 Forbidden. Check PAT permissions or rate limits.",
          );
        } else if (response.statusCode == 404) {
          print(
            "CheckUpdate: Hint: GitHub API returned 404 Not Found. Check owner/repo name.",
          );
        }
        return true; // Fail open on API errors
      }
    } catch (e) {
      print("CheckUpdate: Exception during update check: $e");
      if (e is TimeoutException) {
        print("CheckUpdate: Hint: Network timeout fetching release info.");
      } else if (e is SocketException) {
        print("CheckUpdate: Hint: Network connection error.");
      } else if (e is FormatException) {
        print("CheckUpdate: Hint: Failed to parse JSON response.");
      }
      return true; // Fail open on exceptions
    }

    // --- Compare Versions ---
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    print("CheckUpdate: Current app version: $currentVersion");

    if (latestVersionClean.isNotEmpty &&
        _isNewerVersion(latestVersionClean, currentVersion)) {
      print(
        "CheckUpdate: Update available (Current: $currentVersion -> Latest: $latestVersionClean). Showing update dialog.",
      );

      // Show the update dialog using GetX
      await showUpdateDialog(
        assetApiUrl, // Known non-null here
        forceUpdate,
        latestVersionClean,
        releaseNotesBody,
        githubPat, // Pass PAT for download authentication
      );

      // --- Handle Mandatory Update After Dialog ---
      // If the dialog was dismissed (e.g., 'Later' pressed) and the update was mandatory,
      // we might need to exit. The dialog's GetX controller or PopScope could potentially
      // handle this too, but this is a safeguard.
      if (forceUpdate) {
        // Check if the app is still running (i.e., wasn't exited by the dialog/install process)
        // This check might be tricky depending on exact lifecycle.
        // If the user *could* have dismissed a mandatory dialog without updating, exit now.
        print(
          "CheckUpdate: Mandatory update flow finished. Assuming user might have bypassed; exiting if needed.",
        );
        // We might need a flag from the dialog controller to know if install was initiated.
        // For simplicity now, if it was mandatory and we're here, assume exit is needed.
        SystemNavigator.pop(); // Exit the application forcefully
        return false; // Block startup (though pop should prevent this)
      } else {
        print(
          "CheckUpdate: Optional update dialog dismissed or handled. Proceeding with app startup.",
        );
        return true; // Allow startup for optional updates
      }
    } else {
      print(
        "CheckUpdate: App is up to date or no valid newer version identified.",
      );
      return true; // Proceed with normal startup
    }
  }

  /// Simple version comparison. Returns true if `latestVersion` > `currentVersion`.
  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    try {
      List<String> latestParts = latestVersion.split('.');
      List<String> currentParts = currentVersion.split('.');
      int len = latestParts.length > currentParts.length
          ? latestParts.length
          : currentParts.length;
      for (int i = 0; i < len; i++) {
        String latestPart = (i < latestParts.length) ? latestParts[i] : "0";
        String currentPart = (i < currentParts.length) ? currentParts[i] : "0";
        // Compare as strings to maintain lexicographical ordering
        int comparison = latestPart.compareTo(currentPart);
        if (comparison > 0) return true;
        if (comparison < 0) return false;
      }
      return false; // Versions are identical
    } catch (e) {
      print(
        "CheckUpdate: Error comparing versions '$latestVersion' and '$currentVersion': $e",
      );
      return false; // Treat parse errors as not newer
    }
  }

  /// Heuristic check if the repo might be public (for warning message only).
  static bool _isPublicRepo() {
    // Assume private by default if PAT usage might be intended.
    // Example: if (githubOwner == 'flutter') return true;
    return false;
  }

  // =========================================================================
  // ================== UI: showUpdateDialog (Doc Sync Style) ================
  // =========================================================================

  /// Displays the update dialog using Get.defaultDialog and manages state with UpdateDialogController.
  static Future<void> showUpdateDialog(
    String assetApiUrl,
    bool forceUpdate,
    String latestVersion,
    String releaseNotesBody,
    String githubPat, // PAT needed for download
  ) async {
    // Initialize and register the controller for this dialog instance
    final controller = Get.put(UpdateDialogController());
    controller.init(
      apiUrl: assetApiUrl,
      version: latestVersion,
      pat: githubPat,
      forced: forceUpdate, // Pass forceUpdate to controller
    );

    await Get.defaultDialog(
      title: "", // Keep title empty as per original doc_sync UI
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      backgroundColor: AppColors.white, // Use Doc Sync colors
      barrierDismissible:
          !forceUpdate &&
          !controller
              .isDownloading
              .value, // Prevent dismiss if forced or downloading
      radius: 20,
      // Use PopScope for finer control over dismissal, especially for forceUpdate
      content: PopScope(
        canPop: !forceUpdate && !controller.isDownloading.value,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && forceUpdate && !controller.isDownloading.value) {
            // If pop was prevented because forceUpdate=true and not downloading
            print(
              "CheckUpdate: Mandatory update dialog back press detected. Exiting app.",
            );
            SystemNavigator.pop();
          }
          // Clean up controller when dialog is naturally dismissed or popped
          if (didPop) {
            print("CheckUpdate: Dialog dismissed. Cleaning up controller.");
            Get.delete<UpdateDialogController>();
          }
        },
        child: Obx(
          () => Column(
            // Wrap content in Obx to react to controller changes
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Standard Header ---
              Icon(Icons.system_update, size: 60, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                "Update Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Version $latestVersion",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 15),

              // --- Release Notes Section (Scrollable Markdown) ---
              if (releaseNotesBody.isNotEmpty) ...[
                Text(
                  "What's New:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Get.height * 0.20, // Limit height
                  ),
                  child: Scrollbar(
                    // Add scrollbar
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Material(
                        // Needed for Markdown theming/selection
                        color: Colors.transparent,
                        child: MarkdownBody(
                          data: releaseNotesBody,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(Get.context!),
                          ).copyWith(
                            p: Theme.of(
                              Get.context!,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.75),
                            ),
                            // Customize other styles if needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const Text(
                  "A new version is ready to be installed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
              ],

              // --- Dynamic Status/Progress/Install Section ---
              _buildStatusSection(), // Use helper based on controller state
              const SizedBox(height: 20),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Later" Button
                  if (!forceUpdate &&
                      controller.downloadedFilePath.value == null &&
                      controller.downloadError.value == null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            controller.isDownloading.value
                                ? null
                                : () {
                                  Get.back(); // Dismiss dialog
                                  // Controller is cleaned up by PopScope/onClose
                                },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[700], // Text color
                          backgroundColor: Colors.grey[300], // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Later"),
                      ),
                    ),
                  if (!forceUpdate &&
                      controller.downloadedFilePath.value == null &&
                      controller.downloadError.value == null)
                    const SizedBox(width: 10),

                  // "Update Now" / "Retry" / "Downloading" / (Hidden when complete) Button
                  if (controller.downloadedFilePath.value ==
                      null) // Hide this button once download completes
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            controller.isDownloading.value
                                ? null // Disable when downloading
                                : () =>
                                    controller
                                        .startDownload(), // Start or retry download
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.white, // Text color
                          backgroundColor:
                              controller.isDownloading.value
                                  ? Colors.grey
                                  : AppColors
                                      .primary, // Primary color, greyed out if downloading
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.7,
                          ),
                          disabledBackgroundColor: Colors.grey.withValues(
                            alpha: 0.7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        // Dynamic text based on state
                        child: Text(
                          controller.isDownloading.value
                              ? "Downloading..."
                              : controller.downloadError.value !=
                                  null // If there's an error
                              ? "Retry Download"
                              : "Update Now",
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        // This allows GetX to handle cleanup via onClose, but PopScope is more explicit
        final canPop = !forceUpdate && !controller.isDownloading.value;
        if (!canPop && forceUpdate && !controller.isDownloading.value) {
          print(
            "CheckUpdate: Mandatory update dialog onWillPop detected. Exiting app.",
          );
          SystemNavigator.pop();
          return false; // Prevent pop since we are exiting
        }
        if (canPop) {
          print("CheckUpdate: Dialog will pop. Cleaning up controller.");
          Get.delete<UpdateDialogController>(); // Manual cleanup on allowed pop
        }
        return canPop;
      },
      // onClose: () { // Alternative cleanup location managed by GetX
      //    print("CheckUpdate: Dialog closed. Cleaning up controller.");
      //    Get.delete<UpdateDialogController>(); // Ensure controller cleanup
      // }
    );

    // Ensure controller is deleted if the dialog somehow closes without popping naturally
    // (e.g., error during build). This is a safeguard.
    // Using `Get.find` assumes it might still exist.
    if (Get.isRegistered<UpdateDialogController>()) {
      Get.delete<UpdateDialogController>();
      print("CheckUpdate: Post-dialog safeguard cleanup.");
    }
  }

  // =========================================================================
  // ============ UI HELPER: _buildStatusSection (Doc Sync Style) ===========
  // =========================================================================

  /// Builds the dynamic section within the dialog based on the controller's state.
  static Widget _buildStatusSection() {
    final controller =
        Get.find<UpdateDialogController>(); // Get the controller instance

    // Use Obx directly on the parts that change
    return Obx(() {
      if (controller.isDownloading.value) {
        // --- Downloading State ---
        return Column(
          key: const ValueKey('downloading'),
          children: [
            Text(
              controller.downloadError.value == null ||
                      !controller.downloadError.value!.startsWith(
                        "Download failed. Retrying",
                      )
                  ? "Downloading update..."
                  : controller.downloadError.value!, // Show retry message
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  controller
                      .downloadProgress
                      .value, // Handles null (indeterminate)
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 6),
            if (controller.downloadProgress.value != null)
              Text(
                "${(controller.downloadProgress.value! * 100).toStringAsFixed(0)}%",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            const SizedBox(height: 8),
          ],
        );
      } else if (controller.downloadedFilePath.value != null) {
        // --- Download Complete State ---
        return Center(
          key: const ValueKey('complete'),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                "Download complete!",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // "Install Now" button appears here
              ElevatedButton.icon(
                icon: Icon(
                  Icons.install_mobile,
                  size: 18,
                  color: AppColors.white,
                ),
                label: const Text("Install Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.secondary, // Or another suitable color
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () => controller.installApk(), // Trigger install
              ),
            ],
          ),
        );
      } else if (controller.downloadError.value != null) {
        // --- Error State ---
        return Container(
          key: const ValueKey('error'),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(
              alpha: 0.1,
            ), // Use error color slightly transparent
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Download Failed",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.downloadError.value!,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        // --- Idle State ---
        return const SizedBox.shrink(key: ValueKey('idle'));
      }
    });
  }
} // End of CheckUpdate class
