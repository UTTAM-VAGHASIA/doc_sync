import 'dart:math' as math;

import 'package:doc_sync/common/widgets/images/app_rounded_image.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AppSidebar extends StatelessWidget {
  AppSidebar({super.key});

  final drawerOpenController = SidebarController.instance;

  @override
  Widget build(BuildContext context) {
    // Track top level index for animation staggering
    int topLevelIndex = 0;

    return Drawer(
      backgroundColor: drawerOpenController.drawerBackgroundColor,
      elevation: 2,
      shape: BeveledRectangleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
        child: Column(
          children: [
            Expanded(child: SizedBox()),
            // Header with Logo
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                child: AppRoundedImage(
                  width: 150,
                  height: 150,
                  image: AppImages.lightAppLogo,
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                  fit: BoxFit.contain,
                  imageType: ImageType.asset,
                  padding: 0,
                ),
              ),
            ),

            // Scrollable Content Area
            Expanded(
              flex: 9,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                children: [
                  // 1. Dashboard
                  buildAnimatedTopLevelItem(
                    index: topLevelIndex++,
                    child: ListTile(
                      leading: Icon(
                        Iconsax.monitor3,
                        color: drawerOpenController.iconTextColor,
                      ),
                      title: Text(
                        'Dashboard',
                        style: TextStyle(
                          color: drawerOpenController.iconTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap:
                          () => drawerOpenController.menuOnTap(
                            AppRoutes.dashboard,
                          ),
                      selected: drawerOpenController.isActive(
                        AppRoutes.dashboard,
                      ),
                      selectedTileColor:
                          drawerOpenController.selectedBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hoverColor: drawerOpenController.selectedBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 2. Operations (Expandable)
                  buildAnimatedTopLevelItem(
                    index: topLevelIndex++,
                    child: Obx(
                      () => ExpansionTile(
                        leading: Icon(
                          Iconsax.task,
                          color: drawerOpenController.iconTextColor,
                        ),
                        title: Text(
                          'Operations',
                          style: TextStyle(
                            color: drawerOpenController.iconTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          drawerOpenController.isOperationsExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: drawerOpenController.arrowColor,
                        ),
                        backgroundColor:
                            drawerOpenController.drawerBackgroundColor,
                        collapsedBackgroundColor:
                            drawerOpenController.drawerBackgroundColor,
                        collapsedIconColor: drawerOpenController.arrowColor,
                        iconColor: drawerOpenController.arrowColor,
                        initiallyExpanded:
                            drawerOpenController.isOperationsExpanded,
                        onExpansionChanged: (bool expanding) {
                          drawerOpenController.isOperationsExpanded = expanding;
                        },
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 0,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: <Widget>[
                          buildSubMenuItem(
                            icon: Iconsax.add_circle,
                            title: 'Add New Task',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.addNewTask,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.addNewTask,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Iconsax.task_square,
                            title: 'Created Tasks',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.tasks,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.tasks,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Iconsax.verify,
                            title: 'Admin Verification',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.tasks,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.tasks,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.history_outlined,
                            title: 'Task History',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.tasks,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.tasks,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 3. Admin (Expandable)
                  buildAnimatedTopLevelItem(
                    index: topLevelIndex++,
                    child: Obx(
                      () => ExpansionTile(
                        leading: Icon(
                          Icons.settings_suggest_outlined,
                          color: drawerOpenController.iconTextColor,
                        ),
                        title: Text(
                          'Masters',
                          style: TextStyle(
                            color: drawerOpenController.iconTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          drawerOpenController.isMastersExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: drawerOpenController.arrowColor,
                        ),
                        backgroundColor:
                            drawerOpenController.drawerBackgroundColor,
                        collapsedBackgroundColor:
                            drawerOpenController.drawerBackgroundColor,
                        collapsedIconColor: drawerOpenController.arrowColor,
                        iconColor: drawerOpenController.arrowColor,
                        initiallyExpanded:
                            drawerOpenController.isMastersExpanded,
                        onExpansionChanged: (bool expanding) {
                          drawerOpenController.isMastersExpanded = expanding;
                        },
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 0,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: <Widget>[
                          buildSubMenuItem(
                            icon: Icons.person_outline,
                            title: 'Client',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.adminVerfication,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.adminVerfication,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.group_outlined,
                            title: 'Group',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.taskHistory,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.taskHistory,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.task_alt_outlined,
                            title: 'Task Master',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.taskHistory,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.taskHistory,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.dynamic_feed_outlined,
                            title: 'Sub Task',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.taskHistory,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.taskHistory,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Accountant',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.taskHistory,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.taskHistory,
                            ),
                          ),
                          buildSubMenuItem(
                            icon: Icons.calendar_today_outlined,
                            title: 'Financial year',
                            onTap:
                                () => drawerOpenController.menuOnTap(
                                  AppRoutes.taskHistory,
                                ),
                            isSelected: drawerOpenController.isActive(
                              AppRoutes.taskHistory,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAnimatedTopLevelItem({
    required int index,
    required Widget child,
  }) {
    final double totalDurationMs =
        drawerOpenController.drawerOpenController.duration!.inMilliseconds
            .toDouble();
    final double itemStartMs =
        (drawerOpenController.initialDelay +
                drawerOpenController.staggerDelay * index)
            .inMilliseconds
            .toDouble();
    final double itemDurationMs =
        drawerOpenController.itemFadeDuration.inMilliseconds.toDouble();

    final double start = math.min(itemStartMs / totalDurationMs, 1.0);
    final double end = math.min(
      (itemStartMs + itemDurationMs) / totalDurationMs,
      1.0,
    );
    final validStart = math.min(start, end);

    final Animation<double> itemFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: drawerOpenController.drawerOpenController,
        curve: Interval(validStart, end, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> itemSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: drawerOpenController.drawerOpenController,
        curve: Interval(validStart, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: itemFadeAnimation,
      child: SlideTransition(position: itemSlideAnimation, child: child),
    );
  }

  // --- Helper for Sub-Items (simple ListTile) ---
  Widget buildSubMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: drawerOpenController.iconTextColor.withValues(alpha: 0.8),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: drawerOpenController.iconTextColor.withValues(alpha: 0.9),
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
        ),
      ),
      dense: true,
      onTap: onTap,
      selected: isSelected,
      // Use selected color for sub-item selection feedback if needed
      selectedTileColor: drawerOpenController.selectedBackgroundColor
          .withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.only(left: 45.0, right: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      hoverColor: drawerOpenController.selectedBackgroundColor.withValues(
        alpha: 0.3,
      ),
      // Add hover effect
    );
  }
}
