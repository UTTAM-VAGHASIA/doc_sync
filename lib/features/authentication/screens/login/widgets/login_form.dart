import 'package:doc_sync/features/authentication/controllers/login_controller.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:doc_sync/utils/constants/text_strings.dart';
import 'package:doc_sync/utils/popups/organization_dialog.dart';
import 'package:doc_sync/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final currentOrganization = ApiConstants().organization.obs;

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
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator:
                    (value) =>
                        AppValidator.validateEmptyText('Password', value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed:
                        () =>
                            controller.hidePassword.value =
                                !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                  labelText: AppTexts.password,
                ),
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            // Organization Selector
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
              width: double.infinity,
              child: Row(
                children: [
                  Icon(
                    Iconsax.building_4,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Organization: ${currentOrganization.value.isEmpty ? 'Not set' : currentOrganization.value}",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await OrganizationDialogService.showOrganizationDialog();
                      // Update the displayed organization after dialog closes
                      currentOrganization.value = ApiConstants().organization;
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: Size(10, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text("Change"),
                  ),
                ],
              ),
            )),
            SizedBox(height: AppSizes.spaceBtwInputFields / 2),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged:
                            (value) =>
                                controller.rememberMe.value =
                                    !controller.rememberMe.value,
                        visualDensity: VisualDensity(horizontal: -4.0),
                      ),
                    ),
                    Text(AppTexts.rememberMe),
                  ],
                ),
            
                // Forgot Password
                TextButton(
                  // style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text(AppTexts.forgotPassword, style: TextStyle(color: AppColors.primary),),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spaceBtwSections),

            // SignIn Button
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () =>
                          (controller.isLoading.value)
                              ? null
                              : controller.emailAndPasswordSignIn(),
                  child:
                      (controller.isLoading.value)
                          ? CircularProgressIndicator(
                            color: AppColors.buttonDisabled,
                            strokeWidth: 4,
                            constraints: BoxConstraints(
                              minWidth: AppSizes.buttonHeight + 4.2,
                              maxWidth: AppSizes.buttonHeight + 4.2,
                              minHeight: AppSizes.buttonHeight + 4.2,
                              maxHeight: AppSizes.buttonHeight + 4.2,
                            ),
                          )
                          : Text(AppTexts.signIn),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
