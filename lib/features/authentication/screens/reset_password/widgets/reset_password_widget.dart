import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordWidget extends StatelessWidget {
  const ResetPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.parameters['email'] ?? '';
    return Column(
      children: [
        // Header
        Row(
          children: [
            IconButton(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              icon: Icon(CupertinoIcons.clear),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        // Image
        Image(
          image: AssetImage(AppImages.deliveredEmailIllustration),
          width: 256,
          height: 256,
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        // Title & Subtitle
        Text(
          AppTexts.changeYourPasswordTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Text(
          email,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Text(
          AppTexts.changeYourPasswordSubTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: AppSizes.spaceBtwSections),

        // Buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            child: Text(AppTexts.done),
          ),
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            child: Text(AppTexts.resendEmail),
          ),
        ),
        //
      ],
    );
  }
}
