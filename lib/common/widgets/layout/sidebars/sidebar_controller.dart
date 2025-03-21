import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:get/get.dart';

class SidebarController extends GetxController {
  final activeItem = AppRoutes.dashboard.obs;
  final hoverItem = ''.obs;

  void changeActiveItem(String route) => activeItem.value = route;

  void changeHoverItem(String route) =>
      !isActive(route) ? hoverItem.value = route : null;

  bool isActive(String route) => activeItem.value == route;
  bool isHovering(String route) => hoverItem.value == route;

  void menuOnTap(String route) {
    if (!isActive(route)) {
      changeActiveItem(route);

      if (AppDeviceUtils.isMobileScreen(Get.context!)) Get.back();

      Get.toNamed(route);
    }
  }
}
