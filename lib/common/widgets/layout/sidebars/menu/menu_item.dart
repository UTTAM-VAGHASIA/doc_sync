import 'package:doc_sync/common/widgets/layout/sidebars/sidebar_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    super.key,
    required this.route,
    required this.icon,
    required this.itemName,
  });

  final String route;
  final IconData icon;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(SidebarController());

    return InkWell(
      onTap: () => menuController.menuOnTap(route),
      onHover:
          (hovering) =>
              hovering
                  ? menuController.changeHoverItem(route)
                  : menuController.changeHoverItem(''),
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
          child: Container(
            decoration: BoxDecoration(
              color:
                  (menuController.isHovering(route) ||
                          menuController.isActive(route))
                      ? AppColors.primary
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.md,
                    top: AppSizes.md,
                    bottom: AppSizes.md,
                    right: AppSizes.md,
                  ),
                  child:
                      (menuController.isActive(route))
                          ? Icon(icon, size: 22, color: AppColors.white)
                          : Icon(
                            icon,
                            size: 22,
                            color:
                                menuController.isHovering(route)
                                    ? AppColors.white
                                    : AppColors.darkGrey,
                          ),
                ),

                // Text
                (menuController.isHovering(route) ||
                        menuController.isActive(route))
                    ? Flexible(
                      child: Text(
                        itemName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.apply(color: AppColors.white),
                      ),
                    )
                    : Flexible(
                      child: Text(
                        itemName,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
