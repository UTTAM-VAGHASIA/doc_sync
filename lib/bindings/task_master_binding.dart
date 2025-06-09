import 'package:doc_sync/features/masters/controllers/task_master_list_controller.dart';
import 'package:get/get.dart';

class TaskMasterBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TaskMasterListController>()) {
      Get.put(TaskMasterListController());
    }
  }
}
