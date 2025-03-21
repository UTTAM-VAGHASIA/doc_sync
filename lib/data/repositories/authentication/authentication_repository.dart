import 'package:doc_sync/routes/routes.dart';
import 'package:get/get.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  @override
  void onReady() {
    //
    screenRedirect();
  }

  void screenRedirect() async {
    final bool userIsLoggedIn = await isLoggedIn();

    if (userIsLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> isLoggedIn() async {
    Future.delayed(Duration(milliseconds: 300));
    return true;
  }
}
