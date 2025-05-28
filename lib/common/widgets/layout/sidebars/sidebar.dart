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
    return Drawer(
      backgroundColor: AppColors.primary.withValues(alpha: 0.98),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.98),
              AppColors.primary.withValues(alpha: 0.92),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Fixed section (non-scrollable)
            // Logo with more top margin and centered, larger size
            Padding(
              padding: const EdgeInsets.only(top: 64, bottom: 24),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.10),
                      padding: const EdgeInsets.all(24),
                      child: AppRoundedImage(
                        width: 100,
                        height: 120,
                        image: AppImages.whiteAppLogo,
                        backgroundColor: Colors.transparent,
                        fit: BoxFit.contain,
                        imageType: ImageType.asset,
                        padding: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              color: AppColors.white.withValues(alpha: 0.18),
              thickness: 1,
              height: 1,
              indent: 32,
              endIndent: 32,
            ),
            const SizedBox(height: 18),
            // Dashboard as a glassy card, like a collapsed section, no arrow/expansion
            Obx(
              () {
                // Use activeItem directly for better reactivity
                final isDashboardActive = drawerOpenController.activeItem.value == AppRoutes.dashboard;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDashboardActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDashboardActive ? AppColors.white : Colors.white.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                      boxShadow: isDashboardActive ? null : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => drawerOpenController.menuOnTap(AppRoutes.dashboard),
                          borderRadius: BorderRadius.circular(24),
                          hoverColor: AppColors.white.withValues(alpha: 0.10),
                          splashColor: AppColors.white.withValues(alpha: 0.16),
                          highlightColor: AppColors.white.withValues(alpha: 0.08),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.monitor,
                                  color: AppColors.secondary,
                                  size: 26,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Dashboard',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isDashboardActive ? AppColors.secondary : Colors.white.withValues(alpha: 0.92),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ) ??
                                        TextStyle(
                                          color: isDashboardActive ? AppColors.secondary : Colors.white.withValues(alpha: 0.92),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                  ),
                                ),
                                // Spacer where the arrow would be in other sections (empty)
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            
            // Scrollable section (Operations, Masters, and future sections)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Operations Section
                          Obx(
                            () => _buildSectionCard(
                              context: context,
                              headerIcon: Iconsax.task,
                              headerTitle: 'Operations',
                              isExpanded: drawerOpenController.isOperationsExpanded.value,
                              onExpansionChanged:
                                  (exp) =>
                                      drawerOpenController.isOperationsExpanded.value = exp,
                              iconColor: AppColors.secondary,
                              children: [
                                buildSubMenuItem(
                                  context: context,
                                  icon: Iconsax.add_circle,
                                  title: 'Add New Task',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.addNewTask,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.addNewTask,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Iconsax.task_square,
                                  title: 'Tasks List',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(AppRoutes.tasks),
                                  isSelected: drawerOpenController.isActive(AppRoutes.tasks),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Iconsax.verify,
                                  title: 'Admin Verification',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.adminVerfication,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.adminVerfication,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.history_outlined,
                                  title: 'Task History',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.taskHistory,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.taskHistory,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.update_outlined,
                                  title: 'Future Tasks',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.futureTasks,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.futureTasks,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                              ],
                              showArrow: true,
                              isActive: false,
                            ),
                          ),
                          // Subtle shadow at bottom of Operations card for separation
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          // Masters Section
                          Obx(
                            () => _buildSectionCard(
                              context: context,
                              headerIcon: Icons.settings_suggest_outlined,
                              headerTitle: 'Masters',
                              isExpanded: drawerOpenController.isMastersExpanded.value,
                              onExpansionChanged:
                                  (exp) => drawerOpenController.isMastersExpanded.value = exp,
                              iconColor: AppColors.secondary,
                              children: [
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.person_outline,
                                  title: 'Client',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(AppRoutes.client),
                                  isSelected: drawerOpenController.isActive(AppRoutes.client),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.group_outlined,
                                  title: 'Group',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(AppRoutes.group),
                                  isSelected: drawerOpenController.isActive(AppRoutes.group),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.task_alt_outlined,
                                  title: 'Task Master',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.taskMaster,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.taskMaster,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.dynamic_feed_outlined,
                                  title: 'Sub Task',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(AppRoutes.subTask),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.subTask,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: 'Accountant',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.accountant,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.accountant,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                                buildSubMenuItem(
                                  context: context,
                                  icon: Icons.calendar_today_outlined,
                                  title: 'Financial year',
                                  onTap:
                                      () => drawerOpenController.menuOnTap(
                                        AppRoutes.financialYear,
                                      ),
                                  isSelected: drawerOpenController.isActive(
                                    AppRoutes.financialYear,
                                  ),
                                  iconColor: AppColors.tertiary,
                                ),
                              ],
                              showArrow: true,
                              isActive: false,
                            ),
                          ),
                          const SizedBox(height: 12), // Increased bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData headerIcon,
    required String headerTitle,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required Color iconColor,
    required List<Widget> children,
    bool showArrow = true,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final cardColor =
        isActive
            ? Colors.white.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.13);
    final borderColor = Colors.white.withValues(alpha: 0.22);
    final boxShadowColor = Colors.black.withValues(
      alpha: isActive ? 0.08 : 0.06,
    );

    // Create a unified widget structure for both Dashboard and expandable sections
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity, // Force full width for all cards
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Use Stack to ensure layout is identical for all cards
        child:
            showArrow
                ? ExpansionTile(
                    leading: Icon(headerIcon, color: iconColor, size: 26),
                    title: Text(
                      headerTitle,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ) ??
                          TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    trailing: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: onExpansionChanged,
                    childrenPadding: const EdgeInsets.only(
                      bottom: 8,
                      left: 8,
                      right: 8,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    maintainState: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: children,
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(24),
                      hoverColor: AppColors.white.withValues(alpha: 0.10),
                      splashColor: AppColors.white.withValues(alpha: 0.16),
                      highlightColor: AppColors.white.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Icon(headerIcon, color: iconColor, size: 26),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                headerTitle,
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ) ??
                                    TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget buildSubMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
    required Color iconColor,
  }) {
    // For better performance, replace AnimatedScale with conditional scaling
    final scale = isSelected ? 1.03 : 1.0;
    
    return Transform.scale(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
          border:
              isSelected
                  ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    width: 1.1,
                  )
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: AppColors.white.withValues(alpha: 0.10),
            splashColor: AppColors.white.withValues(alpha: 0.16),
            highlightColor: AppColors.white.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 18.0,
              ),
              child: Row(
                children: [
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      margin: const EdgeInsets.only(right: 12),
                    ),
                  if (!isSelected) const SizedBox(width: 15),
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primary : iconColor,
                    size: isSelected ? 22 : 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.85),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            letterSpacing: 0.05,
                          ) ??
                          TextStyle(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.85),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 15,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
