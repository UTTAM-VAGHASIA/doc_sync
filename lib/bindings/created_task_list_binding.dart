import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:get/get.dart';

class TaskListBindings extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TaskListController>()) {
      Get.put(TaskListController());
    }
  }
}
