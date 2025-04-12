import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDialogController extends GetxController {
  // --- State Variables ---
  final isDownloading = false.obs;
  final downloadProgress = Rxn<double>(); // Observable nullable double
  final downloadError = Rxn<String>(); // Observable nullable string
  final downloadedFilePath = Rxn<String>(); // Observable nullable string

  // --- Configuration passed from CheckUpdate ---
  late String assetApiUrl;
  late String latestVersion;
  late String githubPat;
  late bool forceUpdate; // Keep track if the update is mandatory

  // --- Initialization ---
  void init({
    required String apiUrl,
    required String version,
    required String pat,
    required bool forced,
  }) {
    assetApiUrl = apiUrl;
    latestVersion = version;
    githubPat = pat;
    forceUpdate = forced; // Store forceUpdate status

    // Reset state in case dialog is reopened
    isDownloading.value = false;
    downloadProgress.value = null;
    downloadError.value = null;
    downloadedFilePath.value = null;
  }

  // --- Actions ---
  Future<void> startDownload() async {
    // Use the static _startDownload logic, passing update methods
    await _startDownloadStatic(
      assetApiUrl: assetApiUrl,
      latestVersion: latestVersion,
      githubPat: githubPat,
      onProgress: (progress) {
        downloadProgress.value = progress;
      },
      onError: (error) {
        downloadError.value = error;
      },
      onComplete: (path) {
        downloadedFilePath.value = path;
      },
      onDownloadingStateChange: (downloading) {
        isDownloading.value = downloading;
        if (downloading) {
          // Reset errors/progress when starting a new download/retry
          downloadError.value = null;
          downloadProgress.value = null;
          downloadedFilePath.value = null;
        }
      },
    );
  }

  Future<void> installApk() async {
    if (downloadedFilePath.value != null) {
      await _installApkStatic(downloadedFilePath.value!, Get.context);
    } else {
      print(
        "UpdateDialogController: Install failed - downloaded file path is null.",
      );
      Get.snackbar(
        'Installation Error',
        'Could not find the downloaded file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- Static Download Logic (Adapted from case_sync) ---
  // Kept static here for clarity, could be instance methods too.
  static Future<void> _startDownloadStatic({
    required String assetApiUrl,
    required String latestVersion,
    required String githubPat,
    required Function(double?) onProgress,
    required Function(String?) onError, // Nullable to clear error
    required Function(String) onComplete,
    required Function(bool) onDownloadingStateChange,
  }) async {
    onDownloadingStateChange(true);
    onError(null); // Clear previous error
    onProgress(null); // Indeterminate initially

    File? downloadedFile;
    String targetFilePath = '';

    try {
      final directory = await getApplicationCacheDirectory();
      String apkFileName = "app-update-v$latestVersion.apk";

      try {
        final uri = Uri.parse(assetApiUrl);
        if (uri.pathSegments.isNotEmpty &&
            uri.pathSegments.last.toLowerCase().endsWith('.apk')) {
          apkFileName = uri.pathSegments.last.replaceAll(
            RegExp(r'[\\/:*?"<>|]'),
            '_',
          );
        }
      } catch (e) {
        print(
          "CheckUpdate: Warning - Could not parse filename from asset URL ($assetApiUrl): $e. Using default: $apkFileName",
        );
      }

      targetFilePath = '${directory.path}/$apkFileName';
      downloadedFile = File(targetFilePath);

      print("CheckUpdate: Target download path: $targetFilePath");
    } catch (e) {
      print(
        "CheckUpdate: Error getting cache directory or creating file object: $e",
      );
      onError("Failed to prepare download location.");
      onDownloadingStateChange(false);
      return;
    }

    const int maxRetries = 2;
    const Duration retryDelay = Duration(seconds: 5);

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      http.Client? client;
      IOSink? sink;

      try {
        if (attempt > 0) {
          if (await downloadedFile.exists()) {
            print(
              "CheckUpdate: Deleting potentially partial file before retry: $targetFilePath",
            );
            try {
              await downloadedFile.delete();
            } catch (e) {
              print(
                "CheckUpdate: Warning - Failed to delete partial file before retry: $e",
              );
            }
          }
          print(
            "CheckUpdate: Download attempt ${attempt + 1} failed. Retrying in $retryDelay...",
          );
          onError(
            "Download failed. Retrying (${attempt + 1}/${maxRetries + 1})...",
          );
          onProgress(null);
          await Future.delayed(retryDelay);
          onError(null); // Clear retry message
        } else {
          onError(null);
          onProgress(null);
        }

        print(
          "CheckUpdate: Starting download attempt ${attempt + 1}/${maxRetries + 1}...",
        );

        client = http.Client();
        final request = http.Request('GET', Uri.parse(assetApiUrl));
        request.headers['Accept'] = 'application/octet-stream';
        if (githubPat.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $githubPat';
        }

        final response = await client
            .send(request)
            .timeout(
              const Duration(seconds: 30),
              onTimeout:
                  () =>
                      throw TimeoutException(
                        'Connection timed out while initiating download.',
                      ),
            );

        if (response.statusCode == 200) {
          final totalBytes = response.contentLength ?? -1;
          int receivedBytes = 0;
          sink = downloadedFile.openWrite();
          final completer = Completer<void>();
          late StreamSubscription<List<int>> subscription;

          const Duration streamTimeoutDuration = Duration(minutes: 3);
          Timer? inactivityTimer;

          void resetInactivityTimer() {
            inactivityTimer?.cancel();
            inactivityTimer = Timer(streamTimeoutDuration, () {
              print(
                "CheckUpdate: Download stream timed out due to inactivity.",
              );
              subscription.cancel();
              if (!completer.isCompleted) {
                completer.completeError(
                  TimeoutException(
                    'Download timed out due to inactivity (no data received for ${streamTimeoutDuration.inSeconds} seconds).',
                  ),
                );
              }
            });
          }

          subscription = response.stream.listen(
            (chunk) {
              if (completer.isCompleted) return;
              try {
                resetInactivityTimer();
                sink?.add(chunk);
                receivedBytes += chunk.length;
                if (totalBytes > 0) {
                  final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
                  onProgress(progress);
                } else {
                  onProgress(null);
                }
              } catch (e) {
                if (!completer.isCompleted) completer.completeError(e);
              }
            },
            onDone: () {
              inactivityTimer?.cancel();
              if (!completer.isCompleted) completer.complete();
            },
            onError: (e) {
              inactivityTimer?.cancel();
              if (!completer.isCompleted) completer.completeError(e);
            },
            cancelOnError: true,
          );

          await completer.future;

          await sink.flush();
          await sink.close();
          sink = null;

          print(
            "CheckUpdate: Download successful: $targetFilePath ($receivedBytes bytes)",
          );
          onError(null);
          onComplete(targetFilePath);
          onDownloadingStateChange(false);
          client.close();
          return; // Exit retry loop successfully
        } else {
          final body = await response.stream.bytesToString().catchError(
            (_) => "<Failed to read response body>",
          );
          client.close();
          throw HttpException(
            'Download attempt ${attempt + 1} failed with Status ${response.statusCode}. '
            '${response.reasonPhrase ?? ""}. Body: ${body.substring(0, body.length > 500 ? 500 : body.length)}',
            uri: Uri.parse(assetApiUrl),
          );
        }
      } catch (e) {
        print("CheckUpdate: Download exception (Attempt ${attempt + 1}): $e");
        await sink?.close().catchError((_) {});
        sink = null;
        client?.close();

        if (attempt == maxRetries) {
          String errorMsg =
              "Download failed after ${maxRetries + 1} attempts.\n";
          if (e is TimeoutException) {
            errorMsg += "Reason: ${e.message ?? 'Timed out'}. Check network.";
          } else if (e is SocketException) {
            errorMsg +=
                "Reason: Network error (${e.osError?.message ?? e.message}). Check connection.";
          } else if (e is HttpException) {
            String httpError = e.message;
            if (httpError.contains('<html>')) {
              httpError = httpError.substring(0, httpError.indexOf('<html>'));
            }
            if (httpError.contains('{')) {
              httpError = httpError.substring(0, httpError.indexOf('{'));
            }
            errorMsg += "Reason: Server error (${httpError.trim()}).";
          } else {
            errorMsg +=
                "Reason: Unexpected error (${e.runtimeType}). See logs.";
            print("CheckUpdate: Full error details: ${e.toString()}");
          }

          onError(errorMsg);
          onDownloadingStateChange(false);

          try {
            if (await downloadedFile.exists()) {
              await downloadedFile.delete();
              print(
                "CheckUpdate: Cleaned up failed download file: $targetFilePath",
              );
            }
          } catch (deleteError) {
            print(
              "CheckUpdate: Warning - Failed to delete file after final download error: $deleteError",
            );
          }
          return; // Exit function after final failure
        }
        // Loop continues for retry
      } finally {
        await sink?.close().catchError((_) {});
        client?.close();
      }
    }
  }

  // --- Static Install Logic (Adapted from case_sync) ---
  static Future<void> _installApkStatic(
    String filePath,
    BuildContext? context,
  ) async {
    print("CheckUpdate: Attempting to open APK for installation: $filePath");

    final file = File(filePath);
    if (!await file.exists()) {
      print("CheckUpdate: Error - APK file not found at path: $filePath");
      Get.snackbar(
        'Installation Error',
        'Downloaded file not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final result = await OpenFile.open(
      filePath,
      type: "application/vnd.android.package-archive",
    );

    String errorMessage = '';
    switch (result.type) {
      case ResultType.done:
        print(
          "CheckUpdate: System installation prompt opened successfully for: $filePath",
        );
        // Optional: Exit app after triggering install if mandatory
        // final controller = Get.find<UpdateDialogController>();
        // if (controller.forceUpdate) SystemNavigator.pop();
        return; // Success
      case ResultType.noAppToOpen:
        errorMessage =
            'Could not start installation: No app found to open APK files.';
        break;
      case ResultType.permissionDenied:
        errorMessage =
            'Installation permission denied. Please allow installation from this app in settings.';
        break;
      case ResultType.error:
      default:
        errorMessage = 'Error opening installer: ${result.message}';
        break;
    }

    print(
      "CheckUpdate: Error opening installer: ${result.type} - ${result.message}",
    );
    Get.snackbar(
      'Installation Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5), // Longer duration for errors
    );
  }
}
