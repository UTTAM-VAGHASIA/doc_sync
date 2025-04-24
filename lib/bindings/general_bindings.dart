import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/controllers/splash_controller.dart';
import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // -- Core
    Get.lazyPut(() => NetworkManager(), fenix: true);
    Get.lazyPut(() => RetryQueueManager(), fenix: true);
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => SplashController(), fenix: true);
    Get.lazyPut(() => SidebarController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}
