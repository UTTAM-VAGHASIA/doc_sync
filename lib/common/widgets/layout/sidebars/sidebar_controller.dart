import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static SidebarController get instance => Get.find();

  final activeItem = AppRoutes.dashboard.obs;
  final hoverItem = ''.obs;

  RxBool isDrawerOpen = true.obs;
  RxDouble maxSidebarWidth = 260.0.obs;

  late AnimationController animationController;

  @override
  void onInit() {
    animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    if (isDrawerOpen.value) {
      animationController.forward();
    }
    super.onInit();
  }


  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
    if (isDrawerOpen.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

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
