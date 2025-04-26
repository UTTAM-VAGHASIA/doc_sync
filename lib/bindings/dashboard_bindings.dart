import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:get/get.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize dashboard controller only if it doesn't exist yet
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
  }
} 