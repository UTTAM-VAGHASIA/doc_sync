import 'package:doc_sync/common/widgets/images/app_rounded_image.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                  icon: Icon(Iconsax.menu),
                )
                : null,
        actions: [
          // Notification Icon
          IconButton(onPressed: () {}, icon: Icon(Iconsax.notification)),
          const SizedBox(width: AppSizes.spaceBtwItems / 2),

          // User Data
          Row(
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pragma Admin",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "admin@gmail.com",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      Size.fromHeight(AppDeviceUtils.getAppBarHeight() + 15);
}
