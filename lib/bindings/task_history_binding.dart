import 'package:doc_sync/features/operations/controllers/task_history_controller.dart';
import 'package:get/get.dart';

class TaskHistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TaskHistoryController>()) {
      Get.put(TaskHistoryController());
    }
  }
}






