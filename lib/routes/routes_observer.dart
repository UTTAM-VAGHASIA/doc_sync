import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteObservers extends GetObserver {
  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final sidebarController = Get.put(SidebarController());

    if (previousRoute != null) {
      for (var routeName in AppRoutes.sidebarMenuItems) {
        if (previousRoute.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }
    }
  }
}
