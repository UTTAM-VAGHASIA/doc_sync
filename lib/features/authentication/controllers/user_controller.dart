import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/utils/constants/enums.dart' show StorageType;
import 'package:doc_sync/utils/local_storage/app_secure_storage.dart';
import 'package:doc_sync/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

class UserController extends GetxController {
  static UserController get instance => Get.find();

  RxBool isLoading = false.obs;
  Rx<User> user = User.fromJson({}).obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    user.value = await getUserDetails();
  }

  @override
  void onReady() {
    super.onReady();
    refreshUserDetails();
  }

  Future<void> refreshUserDetails() async {
    try {
      isLoading.value = true;
      user.value = await getUserDetails();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserDetails(User user) async {
    try {
      isLoading.value = true;
      final userData = jsonEncode(user.toJsonWithoutPassword());

      await StorageUtility.instance().writeData(
        "user",
        userData,
        type: StorageType.local,
      );
      await StorageUtility.instance().writeData(
        user.id.toString(),
        user.password.toString(),
        type: StorageType.secure,
      );

      // Update the current user object
      this.user.value = user;
    } finally {
      isLoading.value = false;
    }
  }

  Future<User> getUserDetails() async {
    isLoading.value = true;
    String? token = await StorageUtility.instance().readData(
      "user",
      type: StorageType.local,
    );

    isLoading.value = false;
    if (token == null || token == '') {
      return User.fromJson({});
    } else {
      return User.fromJson(jsonDecode(token));
    }
  }

  Future<User> getLoginCredentials() async {
    try {
      // First try reading the user data from local storage
      String? userData = await StorageUtility.instance().readData(
        "user",
        type: StorageType.local,
      );
      
      if (userData == null || userData == '' || userData == '{}') {
        return User.fromJson({});
      }
      
      // Parse the user data
      User userWithoutPassword = User.fromJson(jsonDecode(userData));
      if (userWithoutPassword.id == null) {
        return User.fromJson({});
      }
      
      String id = userWithoutPassword.id!;
      
      // Try to read password from secure storage
      String? password;
      try {
        password = await StorageUtility.instance().readData(
          id,
          type: StorageType.secure,
        );
      } catch (e) {
        developer.log('Error reading password from secure storage: $e', name: 'UserController');
      }
      
      // Check if we have encryption issues
      if (password == null && AppSecureStorage.hasEncryptionError) {
        developer.log('Encryption error detected, clearing secure storage', name: 'UserController');
        
        // Clear all secure storage to reset encryption state
        await StorageUtility.instance().clearAll(clearLocal: false, clearSecure: true);
        
        // Return user without password, forcing a new login
        return User.fromJson({
          "email": userWithoutPassword.email,
          "password": null, // Force re-login
        });
      }
      
      // Return user with email and password (if available)
      return User.fromJson({
        "email": userWithoutPassword.email,
        "password": password,
      });
    } catch (e) {
      developer.log('Error in getLoginCredentials: $e', name: 'UserController');
      return User.fromJson({}); // Return empty user on any error
    }
  }

  Future<void> clearUser() async {
    try {
      isLoading.value = true;

      // Clear user data from storage
      await StorageUtility.instance().removeData(
        "user",
        type: StorageType.local,
      );

      // Reset the user object
      user.value = User.fromJson({});

      // Delete the dashboard controller if it exists
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>();
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print("Error clearing user data: $e");
    }
  }
}
