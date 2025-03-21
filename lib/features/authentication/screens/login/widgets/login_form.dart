import 'package:doc_sync/features/authentication/controllers/login_controller.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:doc_sync/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
        child: Column(
          children: [
            // Email
            TextFormField(
              controller: controller.email,
              validator: AppValidator.validateEmail,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: AppTexts.email,
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwInputFields),

            // Password
            TextFormField(
              controller: controller.password,
              validator:
                  (value) => AppValidator.validateEmptyText('Password', value),
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.eye_slash),
                ),
                labelText: AppTexts.password,
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    Text(AppTexts.rememberMe),
                  ],
                ),

                // Forgot Password
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text(AppTexts.forgotPassword),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spaceBtwSections),

            // SignIn Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(AppTexts.signIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
