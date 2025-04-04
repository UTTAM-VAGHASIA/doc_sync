import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Controller for handling Login Page functionalities
class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final hidePassword = true.obs;
  final rememberMe = true.obs;
  final localStorage = GetStorage();

  final email = TextEditingController();
  final password = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  // Handles email and login sign-in process
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      AppFullScreenLoader.openLoadingDialog(
        'Logging you in...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if remember me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // login using Email & Password Authentication
      // Fetch User Details and assign it to User Controller
      Future.delayed(Duration(seconds: 4));
      Get.offAllNamed(AppRoutes.dashboard);

      // Remove Loader
      AppFullScreenLoader.stopLoading();
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> registerAdmin() async {
    // Start Loading
    AppFullScreenLoader.openLoadingDialog(
      'Registering Admin Account...',
      AppImages.docerAnimation,
    );

    // Check Internet Connectivity
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      AppFullScreenLoader.stopLoading();
      return;
    }

    // Register user using Email & Password Authentication
  }
}
