import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarController extends GetxController
    with GetTickerProviderStateMixin {
  static SidebarController get instance => Get.find();

  final activeItem = AppRoutes.dashboard.obs;
  final hoverItem = ''.obs;

  RxBool isDrawerOpen = true.obs;
  RxDouble maxSidebarWidth = 260.0.obs;

  late AnimationController animationController;
  late AnimationController drawerOpenController;

  // State to control expansion tiles - using RxBool for reactivity
  RxBool _isOperationsExpanded = false.obs;
  RxBool _isMastersExpanded = false.obs;
  RxBool _isUserLogsExpanded = false.obs;
  RxBool _isReportsExpanded = false.obs;

  // Getters and setters for expansion state
  bool get isOperationsExpanded => _isOperationsExpanded.value;
  set isOperationsExpanded(bool value) => _isOperationsExpanded.value = value;

  bool get isMastersExpanded => _isMastersExpanded.value;
  set isMastersExpanded(bool value) => _isMastersExpanded.value = value;

  bool get isUserLogsExpanded => _isUserLogsExpanded.value;
  set isUserLogsExpanded(bool value) => _isUserLogsExpanded.value = value;

  bool get isReportsExpanded => _isReportsExpanded.value;
  set isReportsExpanded(bool value) => _isReportsExpanded.value = value;

  // Define durations for staggering top-level items
  Duration initialDelay = Duration(milliseconds: 50);
  Duration itemFadeDuration = Duration(milliseconds: 300);
  Duration staggerDelay = Duration(milliseconds: 60);
  Duration drawerOpenDuration = Duration(milliseconds: 400);

  // Define theme colors based on the image
  Color drawerBackgroundColor = Color(0xFFF0F4F8); // Light grayish blue
  Color iconTextColor = Color(0xFF0D47A1); // Dark Blue (adjust as needed)
  Color selectedBackgroundColor = Color(
    0xFFE3F2FD,
  ); // Light Blue for selection/hover (used for sub-items now)
  Color arrowColor = Color(0xFF64B5F6); // Lighter blue for arrows

  @override
  void onInit() {
    drawerOpenController = AnimationController(
      vsync: this,
      duration: drawerOpenDuration,
    );
    animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    if (isDrawerOpen.value) {
      drawerOpenController.forward();
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
