import 'package:doc_sync/features/masters/controllers/group_list_controller.dart';
import 'package:get/get.dart';

class GroupListBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GroupListController>()) {
      Get.put(GroupListController());
    }
  }
}
