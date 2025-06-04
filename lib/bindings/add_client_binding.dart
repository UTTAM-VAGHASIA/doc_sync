import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:get/get.dart';

class AddClientBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize dashboard controller only if it doesn't exist yet
    if (!Get.isRegistered<AddClientController>()) {
      Get.put(AddClientController());
    }
  }
} 