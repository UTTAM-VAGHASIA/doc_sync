import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image(
                width: 100,
                height: 100,
                image: AssetImage(AppImages.lightAppLogo),
              ),
              // Expanded(child: SizedBox()),
              // Text(
              //   AppTexts.appName,
              //   style: Theme.of(context).textTheme.headlineLarge!.apply(
              //     fontSizeDelta: 40,
              //     color: AppColors.primary,
              //   ),
              // ),
              // Expanded(flex: 8, child: SizedBox()),
            ],
          ),
          SizedBox(height: AppSizes.spaceBtwSections),
          Text(
            AppTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            AppTexts.loginSubTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
