import 'package:doc_sync/features/masters/controllers/accountant_list_controller.dart';
import 'package:get/get.dart';

class AccountantListBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AccountantListController>()) {
      Get.put(AccountantListController());
    }
  }
}
