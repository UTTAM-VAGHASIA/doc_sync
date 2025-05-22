import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:get/get.dart';

class AdminVerificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminVerificationController>()) {
      Get.put(AdminVerificationController());
    }
  }
}






