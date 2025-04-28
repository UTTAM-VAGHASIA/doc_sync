import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:get/get.dart';

class NewTaskBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize dashboard controller only if it doesn't exist yet
    if (!Get.isRegistered<NewTaskController>()) {
      Get.put(NewTaskController());
    }
  }
} 