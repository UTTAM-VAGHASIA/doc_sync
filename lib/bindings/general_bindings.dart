import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // -- Core
    Get.lazyPut(() => NetworkManager(), fenix: true);
    // Get.lazyPut(() => UserController(), fenix: true);
    //
  }
}
