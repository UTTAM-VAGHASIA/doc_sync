import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../popups/loaders.dart';

/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find<NetworkManager>();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final RxList<ConnectivityResult> connectionStatus =
      <ConnectivityResult>[].obs;

  /// Initialize and start listening for connectivity changes.
  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Get the initial connection status.
  Future<void> _initializeConnectivity() async {
    try {
      final initialStatus = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(initialStatus);
    } on PlatformException {
      connectionStatus.clear();
    }
  }

  /// Handle changes in connectivity.
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    connectionStatus.value = result;
    if (result.isEmpty || result.contains(ConnectivityResult.none)) {
      AppLoaders.customToast(message: 'No Internet Connection');
    }
  }

  /// Check if there is any available network connection.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((res) => res != ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  /// Cancel the connectivity subscription when the controller is disposed.
  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
