import 'package:doc_sync/features/masters/controllers/sub_task_master_list_controller.dart';
import 'package:get/get.dart';

class SubTaskMasterBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SubTaskMasterListController>()) {
      Get.put(SubTaskMasterListController());
    }
  }
}
