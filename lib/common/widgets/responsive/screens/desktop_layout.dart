import 'package:doc_sync/common/widgets/layout/headers/header.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final sidebarController = SidebarController.instance;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Obx(() {
            final maxSidebarWidth = sidebarController.maxSidebarWidth.value;

            // Wrap the animation controller with a CurvedAnimation for smoother easing
            final curvedAnimation = CurvedAnimation(
              parent: sidebarController.animationController,
              curve: Curves.easeInOut,
            );

            return ClipRRect(
              child: AnimatedBuilder(
                animation: curvedAnimation, // Use the curved animation
                builder: (context, child) {
                  final animationValue =
                      curvedAnimation
                          .value; // Use the value from the curved animation

                  // Width interpolates from 0 to maxSidebarWidth
                  final sidebarWidth = animationValue * maxSidebarWidth;
                  // Offset interpolates from -maxSidebarWidth to 0
                  final offset = (animationValue - 1) * maxSidebarWidth;

                  return Transform.translate(
                    offset: Offset(offset, 0),
                    // Use ClipRect to avoid the child overflowing during animation
                    child: ClipRect(
                      child: SizedBox(width: sidebarWidth, child: child),
                    ),
                  );
                },
                child: AppSidebar(),
              ),
            );
          }),

          // Main Content
          Expanded(child: Column(children: [AppHeader(), body ?? SizedBox()])),
        ],
      ),
    );
  }
}
