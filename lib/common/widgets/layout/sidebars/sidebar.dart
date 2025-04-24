import 'package:doc_sync/common/widgets/images/app_rounded_image.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/menu/menu_item.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: BeveledRectangleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(right: BorderSide(color: AppColors.grey, width: 1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: AppSizes.defaultSpace),
              // Image
              AppRoundedImage(
                width: 100,
                height: 100,
                image: AppImages.lightAppLogo,
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                fit: BoxFit.contain,
                imageType: ImageType.asset,
              ),
              SizedBox(height: AppSizes.defaultSpace),
              Padding(
                padding: EdgeInsets.all(AppSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Heading
                    Text(
                      'MENU',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.apply(letterSpacingDelta: 1.2),
                    ),

                    //Menu Items
                    AppMenuItem(
                      route: AppRoutes.dashboard,
                      icon: Iconsax.monitor3,
                      itemName: 'Dashboard',
                    ),
                    AppMenuItem(
                      route: AppRoutes.addNewTask,
                      icon: Iconsax.task,
                      itemName: 'New Task',
                    ),
                    AppMenuItem(
                      route: AppRoutes.tasks,
                      icon: Iconsax.task,
                      itemName: 'Created Tasks',
                    ),
                    AppMenuItem(
                      route: AppRoutes.adminVerfication,
                      icon: Iconsax.verify,
                      itemName: 'Admin Verification',
                    ),
                    AppMenuItem(
                      route: AppRoutes.taskHistory,
                      icon: Iconsax.verify,
                      itemName: 'Admin Verification',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
