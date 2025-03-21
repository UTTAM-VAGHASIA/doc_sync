import 'package:doc_sync/common/styles/spacing_styles.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/device/device_utility.dart';
import 'package:doc_sync/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class AppLoginTemplate extends StatelessWidget {
  const AppLoginTemplate({super.key, required this.child});

  // Widget to be displayed inside the login template
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          (AppDeviceUtils.isDesktopScreen(context) ||
                  AppDeviceUtils.isTabletScreen(context))
              ? SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Container(
                    padding: AppSpacingStyle.paddingWithAppBarHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardRadiusLg,
                      ),
                      color:
                          AppHelperFunctions.isDarkMode(context)
                              ? AppColors.black
                              : AppColors.white,
                    ),

                    child: child,
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.defaultSpace),
                  child: child,
                ),
              ),
    );
  }
}
