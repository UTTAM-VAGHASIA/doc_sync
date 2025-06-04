import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:get/get.dart';

class ClientListBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ClientListController>()) {
      Get.put(ClientListController());
    }
  }
}
