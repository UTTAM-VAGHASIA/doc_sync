import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
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
  RxBool isOperationsExpanded = false.obs;
  RxBool isMastersExpanded = false.obs;
  RxBool isUserLogsExpanded = false.obs;
  RxBool isReportsExpanded = false.obs;

  // Define durations for staggering top-level items
  Duration initialDelay = Duration(milliseconds: 50);
  Duration itemFadeDuration = Duration(milliseconds: 300);
  Duration staggerDelay = Duration(milliseconds: 60);
  Duration drawerOpenDuration = Duration(milliseconds: 400);

  // Background color
  Color drawerBackgroundColor = AppColors.primary;

  @override
  void onInit() {
    drawerOpenController = AnimationController(
      vsync: this,
      duration: drawerOpenDuration,
      animationBehavior: AnimationBehavior.preserve
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
    if (AppDeviceUtils.isMobileScreen(Get.context!) || AppDeviceUtils.isTabletScreen(Get.context!)) Get.back();

    // Set active item before navigation
    changeActiveItem(route);

    // Use a consistent navigation approach for all routes
    if (route == AppRoutes.dashboard) {
      Get.offAllNamed(route);
    } else {
      // Use toNamed instead of offNamed to avoid state reset issues
      Get.toNamed(route, preventDuplicates: true);
    }
    
    // Ensure route is properly set after navigation
    Future.delayed(Duration(milliseconds: 100), () {
      changeActiveItem(route);
    });
  }
}
