import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/local_storage/storage_utility.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// Controller for handling Login Page functionalities
class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final userController = UserController.instance;
  late DashboardController dashboardController;

  final hidePassword = true.obs;
  final rememberMe = true.obs;

  final email = TextEditingController();
  final password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  Future<void> onInit() async {
    isLoggedIn.value = false;
    email.text =
        (await StorageUtility.instance().readData(
          "REMEMBER_ME_EMAIL",
          bucket: "loginData",
        )) ??
        '';
    password.text =
        (await StorageUtility.instance().readData(
          "REMEMBER_ME_PASSWORD",
          type: StorageType.secure,
        )) ??
        '';
    super.onInit();
  }

  // Handles email and login sign-in process
  Future<void> emailAndPasswordSignIn() async {
    try {
      isLoading.value = true;

      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(emailAndPasswordSignIn);
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        isLoading.value = false;
        return;
      }

      // Save Data if remember me is selected
      if (rememberMe.value) {
        StorageUtility.instance().writeData(
          "REMEMBER_ME_EMAIL",
          email.text.trim(),
          bucket: "loginData",
        );
        StorageUtility.instance().writeData(
          "REMEMBER_ME_PASSWORD",
          password.text.trim(),
          type: StorageType.secure,
        );
      } else {
        StorageUtility.instance().removeData(
          "REMEMBER_ME_EMAIL",
          bucket: "loginData",
        );
        StorageUtility.instance().removeData(
          "REMEMBER_ME_PASSWORD",
          type: StorageType.secure,
        );
      }

      final requestData = {
        'data': jsonEncode({
          "user_id": email.text.trim(),
          "password": password.text.trim(),
        }),
      };

      final data = await AppHttpHelper().sendMultipartRequest(
        "login",
        method: "POST",
        fields: requestData,
      );

      if (data['success']) {
        User user = User.fromJson(data['data'][0]);
        userController.saveUserDetails(user);

        isLoggedIn.value = true;
        
        // Initialize dashboard controller without fetching data
        dashboardController = Get.put(DashboardController());
        // The data will be fetched when the dashboard screen is loaded
      } else {
        // print("Login Unsuccessful because...");
        // print(data['message']);
        AppLoaders.errorSnackBar(
          title: "Login Error",
          message: data['message'],
        );
      }

      // Remove Loader
      isLoading.value = false;
      AppFullScreenLoader.stopLoading();
    } catch (e) {
      isLoading.value = false;
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }

    if (isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }
}
