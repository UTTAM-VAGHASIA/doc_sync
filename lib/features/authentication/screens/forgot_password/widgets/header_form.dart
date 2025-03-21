import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HeaderAndForm extends StatelessWidget {
  const HeaderAndForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        IconButton(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          icon: Icon(Iconsax.arrow_left),
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Text(
          AppTexts.forgotPasswordTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Text(
          AppTexts.forgotPasswordSubTitle,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: AppSizes.spaceBtwSections * 2),

        // Form
        Form(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: AppTexts.email,
              prefixIcon: Icon(Iconsax.direct_right),
            ),
          ),
        ),
        SizedBox(height: AppSizes.spaceBtwSections),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                () => Get.toNamed(
                  AppRoutes.resetPassword,
                  parameters: {'email': 'admin@gmail.com'},
                ),
            child: Text(AppTexts.submit),
          ),
        ),

        SizedBox(height: AppSizes.spaceBtwSections * 2),
      ],
    );
  }
}
