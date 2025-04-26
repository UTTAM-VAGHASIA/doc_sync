import 'package:doc_sync/common/widgets/images/app_rounded_image.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:doc_sync/utils/popups/organization_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize =>
      Size.fromHeight(AppDeviceUtils.getAppBarHeight() + 15);
}

class _AppHeaderState extends State<AppHeader> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final sidebarController = SidebarController.instance;

    // Define the theme for the popup menu
    final popupMenuTheme = Theme.of(context).copyWith(
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.light, // Background color of the menu

        elevation: 4.0, // Shadow effect
        shape: RoundedRectangleBorder(
          // Custom shape
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5), // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
        ),
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // Text style for items
          color: AppColors.primary,
        ),
        // You can add more properties like surfaceTintColor, iconColor etc.
      ),
      // Optional: Customize the splash color when tapping menu items
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading:
            !AppDeviceUtils.isDesktopScreen(context)
                ? IconButton(
                  onPressed:
                      () => widget.scaffoldKey?.currentState?.openDrawer(),
                  icon: Icon(
                    Icons.segment,
                    size: 42,
                    color: AppColors.primary,
                  ),
                )
                : Obx(
                  () => IconButton(
                    onPressed: () {
                      sidebarController.toggleDrawer(); // Use the new method
                    },
                    icon: Icon(
                      (!sidebarController.isDrawerOpen.value)
                          ? Iconsax.menu_15
                          : Iconsax.close_square,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        title:
            (AppDeviceUtils.isDesktopScreen(context))
                ? Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (AppDeviceUtils.isDesktopScreen(context) &&
                          !sidebarController.isDrawerOpen.value)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Doc Sync',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0, // Reduced line height
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
                : null,
        actions: [
          // Notification Icon
          IconButton(onPressed: () {}, icon: Icon(Iconsax.notification)),
          const SizedBox(width: AppSizes.spaceBtwItems / 2),

          // --- Apply Theme to PopupMenuButton ---
          Theme(
            data: popupMenuTheme, // Apply the custom theme here
            child: PopupMenuButton<ProfileMenuAction>(
              tooltip: "User Menu",
              offset: const Offset(0, 60),
              // --- Callbacks to update the icon state ---
              onOpened: () {
                // Set state when menu opens
                setState(() {
                  _isMenuOpen = true;
                });
              },
              onSelected: (ProfileMenuAction result) async {
                // Set state when an item is selected (menu closes)
                setState(() {
                  _isMenuOpen = false;
                });
                // Handle the action
                switch (result) {
                  case ProfileMenuAction.changePassword:
                    print('Change Password Tapped');
                    break;
                  case ProfileMenuAction.changeOrganization:
                    final currentOrganization = ApiConstants().organization;
                    await OrganizationDialogService.showOrganizationDialog();
                    if(currentOrganization != ApiConstants().organization){
                      userController.clearUser();
                      Get.offAllNamed(AppRoutes.login);
                    }
                    break;
                  case ProfileMenuAction.logout:
                    print('Log Out Tapped');
                    userController.clearUser();
                    Get.offAllNamed(AppRoutes.login);
                    break;
                }
              },
              onCanceled: () {
                // Set state when menu is cancelled (menu closes)
                setState(() {
                  _isMenuOpen = false;
                });
              },
              // --- End of state callbacks ---
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<ProfileMenuAction>>[
                    PopupMenuItem<ProfileMenuAction>(
                      value: ProfileMenuAction.changeOrganization,
                      child: Text('Change Organization'),
                    ),
                    PopupMenuItem<ProfileMenuAction>(
                      value: ProfileMenuAction.changePassword,
                      child: Text('Change Password'),
                    ),
                    PopupMenuItem<ProfileMenuAction>(
                      value: ProfileMenuAction.logout,
                      child: Text('Log Out'),
                    ),
                  ],
              // The child is the widget that triggers the menu
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppRoundedImage(
                    width: 40,
                    padding: 2,
                    height: 40,
                    imageType: ImageType.asset,
                    image: AppImages.user,
                  ),
                  SizedBox(width: AppSizes.sm),

                  //Name and Email
                  if (!AppDeviceUtils.isMobileScreen(context))
                    Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userController.isLoading.value
                              ? AppShimmerEffect(width: 50, height: 13)
                              : Text(
                                userController.user.value.name ?? "Admin",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                          userController.isLoading.value
                              ? AppShimmerEffect(width: 50, height: 13)
                              : Text(
                                userController.user.value.email ??
                                    'admin@gmail.com',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                        ],
                      ),
                    ),
                  // Add a small down arrow indicator if desired (optional)
                  const SizedBox(width: AppSizes.sm), // Space before icon
                  Icon(
                    _isMenuOpen
                        ? Iconsax.arrow_up_2
                        : Iconsax.arrow_down_1, // Dynamically change icon
                    size: 18,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: AppSizes.xs), // Space before icon
                  // --- End of dynamic icon ---
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm), // Padding at the end
        ],
      ),
    );
  }
}
